import zipfile
import xml.etree.ElementTree as ET

class DocxXmlReader:
    """
    Robot Framework library DOCX szöveg kiolvasásához XML-ből.
    Előnye: a Word text box / shape (w:drawing → w:txbxContent) szövegét is látja.
    """

    def _read_doc_parts_xml(self, path: str):
        """Beolvassa a releváns DOCX XML részeket (document, headers, footers, footnotes, endnotes)."""
        parts = []
        with zipfile.ZipFile(path) as z:
            names = set(z.namelist())
            wanted = []

            # fő dokumentum
            if "word/document.xml" in names:
                wanted.append("word/document.xml")

            # fejlécek/láblécek
            wanted += sorted([n for n in names if n.startswith("word/header") and n.endswith(".xml")])
            wanted += sorted([n for n in names if n.startswith("word/footer") and n.endswith(".xml")])

            # lábjegyzet/végjegyzet
            if "word/footnotes.xml" in names:
                wanted.append("word/footnotes.xml")
            if "word/endnotes.xml" in names:
                wanted.append("word/endnotes.xml")

            for n in wanted:
                try:
                    parts.append(z.read(n))
                except KeyError:
                    pass

        return parts

    def _extract_text_from_xml(self, xml_bytes: bytes) -> str:
        root = ET.fromstring(xml_bytes)

        # namespace-ek automatikus kinyerése (biztonságosabb)
        ns = {}
        for k, v in root.attrib.items():
            if k.startswith("{http://www.w3.org/2000/xmlns/}"):
                ns[k.split("}", 1)[1]] = v
        # tipikusan: w = http://schemas.openxmlformats.org/wordprocessingml/2006/main
        w = ns.get("w", "http://schemas.openxmlformats.org/wordprocessingml/2006/main")
        W = f"{{{w}}}"

        lines = []

        # MINDEN paragrafus (w:p) = egy új sor/blokk
        for p in root.iter(W + "p"):
            tokens = []
            for el in p.iter():
                tag = el.tag

                if tag == W + "t":  # szöveg
                    if el.text:
                        tokens.append(el.text)
                elif tag == W + "tab":
                    tokens.append("\t")
                elif tag in (W + "br", W + "cr"):
                    tokens.append("\n")

            text = "".join(tokens)

            # paragrafuson belüli \n-ekből több sor lehet
            for ln in text.splitlines():
                ln = ln.strip()
                if ln:
                    lines.append(ln)

        return "\n".join(lines)

    def read_all_text(self, path: str) -> str:
        """
        Keyword: Read All Text
        Kiolvassa a DOCX összes szövegét XML-ből (textbox/shape is).
        Mindes or végére \n kerül.
        """
        xml_parts = self._read_doc_parts_xml(path)
        lines = []
        for xml in xml_parts:
            text = self._extract_text_from_xml(xml)
            for line in text.splitlines():
                line = line.strip()
                if line:
                    lines.append(line)

        return " \n".join(lines) + "\n"

    def read_text_from_marker(self, path: str, marker: str, max_lines: int = 200) -> str:
        """
        Keyword: Read Text From Marker
        Marker-től kezdve visszaad max_lines sort.
        """
        text = self.read_all_text(path)
        idx = text.lower().find(marker.lower())
        if idx == -1:
            raise AssertionError(f"Marker nem található: {marker}")

        snippet = text[idx:]
        lines = [l for l in snippet.splitlines() if l.strip()]
        return "\n".join(lines[:int(max_lines)])
