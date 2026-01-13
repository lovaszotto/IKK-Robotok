from zipfile import ZipFile, BadZipFile
try:
    from lxml import etree
except Exception:
    etree = None  # lxml opcionális
import json
import os
import sys


class DocxReader:
    def _print_json_console(self, text: str) -> None:
        """Biztonságos UTF-8 kiírás a konzolra (Windows kódlap hibák elkerülése)."""
        try:
            if hasattr(sys.stdout, "buffer"):
                sys.stdout.buffer.write((text + os.linesep).encode("utf-8", errors="replace"))
            else:
                print(text)
        except Exception:
            pass

    def read_docx_all(self, filepath, extract_images_to=None):
        """
        Visszaad minden fontos tartalmat egy dict-ben:
        {
          "core_properties": {...},
          "app_properties": {...},
          "paragraphs": ["...", ...],
          "runs": [["Run1 a 1. bekezdésben", ...], ...],
          "paragraph_in_cells": ["...", ...],
          "tables": [[["cell(0,0)","cell(0,1)"],["cell(1,0)","..."]], ...],
          "headers": ["...", ...],
          "footers": ["...", ...],
          "footnotes": ["...", ...],
          "endnotes": ["...", ...],
          "images": [{"name": "...", "path": "...", "bytes": <len>}, ...],
          "styles": ["Normal", "Heading 1", ...]
        }
        """
        if not os.path.isfile(filepath):
            raise FileNotFoundError(filepath)

        # Alapértelmezett értékek (hogy kivételnél is legyen visszatérő struktúra)
        core_props = {}
        app_props = {}
        footnotes = []
        endnotes = []
        images = []

        # DOCX tartalom beolvasása (lazy import, hogy a modul import ne bukjon, ha nincs python-docx)
        try:
            from docx import Document  # type: ignore
        except Exception as e:
            raise ImportError("A 'python-docx' csomag nincs telepítve. Telepítsd: pip install python-docx") from e
        doc = Document(filepath)

        # Szöveg: bekezdések + run-ok
        paragraphs = [p.text for p in doc.paragraphs]
        runs = [[r.text for r in p.runs] for p in doc.paragraphs]
   
        #Paragraph in cell
        paragraph_in_cells = []
        for table in doc.tables:
            for row in table.rows:
                for cell in row.cells:
                    for p in cell.paragraphs:
                        text = p.text.strip()
                        if text:
                            paragraph_in_cells.append(text)        
        # Táblák
        tables = []
        for t in doc.tables:
            table_rows = []
            for row in t.rows:
                table_rows.append([cell.text for cell in row.cells])
            tables.append(table_rows)

        # Stílusok nevei
        styles = []
        try:
            styles = [s.name for s in doc.styles if hasattr(s, "name")]
        except Exception:
            pass

        # Fejlécek/láblécek
        headers, footers = [], []
        try:
            for s in doc.sections:
                try:
                    headers.append("\n".join(p.text for p in s.header.paragraphs))
                except Exception:
                    pass
                try:
                    footers.append("\n".join(p.text for p in s.footer.paragraphs))
                except Exception:
                    pass
        except Exception:
            pass

        # ZIP: képek + opcionális XML alapú adatok
        try:
            with ZipFile(filepath) as z:
                # Képek
                for info in z.infolist():
                    if info.filename.startswith("word/media/"):
                        img_bytes = z.read(info)
                        out_path = None
                        if extract_images_to:
                            os.makedirs(extract_images_to, exist_ok=True)
                            out_path = os.path.join(extract_images_to, os.path.basename(info.filename))
                            with open(out_path, "wb") as f:
                                f.write(img_bytes)
                        images.append({
                            "name": os.path.basename(info.filename),
                            "path": out_path,
                            "bytes": len(img_bytes)
                        })

                # Metaadatok és jegyzetek csak ha lxml elérhető
                if etree is not None:
                    def _read_xml(path):
                        try:
                            with z.open(path) as f:
                                return etree.parse(f)
                        except KeyError:
                            return None

                    core_xml = _read_xml("docProps/core.xml")
                    app_xml  = _read_xml("docProps/app.xml")
                    foot_xml = _read_xml("word/footnotes.xml")
                    end_xml  = _read_xml("word/endnotes.xml")

                    def _xml_to_dict(tree):
                        if tree is None:
                            return {}
                        d = {}
                        for elem in tree.getroot().iter():
                            tag = elem.tag.split("}")[-1]
                            if elem.text and elem.text.strip():
                                d[tag] = elem.text.strip()
                        return d

                    core_props = _xml_to_dict(core_xml)
                    app_props  = _xml_to_dict(app_xml)

                    def _notes_to_list(tree, note_tag):
                        if tree is None:
                            return []
                        ns = {"w": "http://schemas.openxmlformats.org/wordprocessingml/2006/main"}
                        out = []
                        for n in tree.findall(f".//w:{note_tag}", ns):
                            texts = [t.text for t in n.findall(".//w:t", ns) if t.text]
                            out.append("".join(texts))
                        return out

                    footnotes = _notes_to_list(foot_xml, "footnote")
                    endnotes  = _notes_to_list(end_xml, "endnote")
        except BadZipFile:
            # Hibás DOCX/ZIP – az XML/kepek kimaradnak
            pass
        except Exception:
            # Egyéb ZIP olvasási hiba esetén is folytatunk
            pass

        return {
            "core_properties": core_props,
            "app_properties": app_props,
            "paragraphs": paragraphs,
            "runs": runs,
            "tables": tables,
            "paragraphs_in_cells": paragraph_in_cells,
            "headers": headers,
            "footers": footers,
            "footnotes": footnotes,
            "endnotes": endnotes,
            "images": images,
            "styles": styles,
        }

        # ...existing code...

    def read_docx_all_as_json(self, filepath, extract_images_to=None, debug=False):
        """JSON-ként adja vissza. debug=True esetén a teljes JSON a konzolra is kiíródik."""
        data = self.read_docx_all(filepath, extract_images_to)
        result = json.dumps(data, ensure_ascii=False, indent=2)
        if debug:
            self._print_json_console(result)
        return result

# ===== Modul szintű wrapper függvények Robot Framework-höz =====
def read_docx_all(filepath, extract_images_to=None):
    """Wrapper: Read Docx All

    Robot Framework modul import esetén a modul-szintű függvények lesznek kulcsszavak.
    Ez a wrapper biztosítja, hogy a 'Read Docx All' kulcsszó elérhető legyen.
    """
    return DocxReader().read_docx_all(filepath, extract_images_to)


def read_docx_all_as_json(filepath, extract_images_to=None, debug=False):
    """Wrapper: Read Docx All As Json"""
    return DocxReader().read_docx_all_as_json(filepath, extract_images_to, debug)