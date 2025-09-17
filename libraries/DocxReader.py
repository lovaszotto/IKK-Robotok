
from docx import Document
import re
try:
    from robot.api import logger
    def log_console(msg):
        logger.console(msg)
except ImportError:
    def log_console(msg):
        print(msg)

def read_docx(file_path):
    try:
        doc = Document(file_path)
        # DOCX body elemek típusainak kilistázása
        log_console("[DEBUG] DOCX body elemek:")
        for i, el in enumerate(doc.element.body):
            log_console(f"  - Body elem {i}: tag={el.tag}")
        # Hibakeresés: összes reláció és objektum kilistázása
        #log_console("[DEBUG] DOCX relációk és objektumok:")
        #for rel in doc.part.rels.values():
        #    log_console(f"  - rel type: {rel.reltype}, target_ref: {rel.target_ref}")
        log_console(f"[DEBUG] Paragraphs száma: {len(doc.paragraphs)}")
        for i, para in enumerate(doc.paragraphs):
            log_console(f"  - Paragraph {i}: '{para.text[:100]}'")
        full_text = []
        seen = set()
        # Táblák olvasása
        table_count = len(doc.tables)
        log_console(f"[DEBUG] Talált táblázatok száma: {table_count}")
        for table in doc.tables:
            for row in table.rows:
                for cell in row.cells:
                    if id(cell) not in seen:
                        seen.add(id(cell))
                        text = cell.text.strip()
                        if text:
                            full_text.append(text + ". \n")
        # Paragrafusok olvasása
        for para in doc.paragraphs:
            if para.text.strip():
                full_text.append(para.text)
        # Képek és egyéb objektumok detektálása
        image_count = 0
        for rel in doc.part.rels.values():
            if "image" in rel.target_ref:
                image_count += 1
        # Normalizálás
        result = "\n".join(full_text)
        # Sortörések egységesítése, de nem töröljük ki őket
        result = result.replace('\r\n', '\n').replace('\r', '\n')
        result = re.sub(r'\?\s*(?=[A-ZÁÉÍÓÖŐÚÜŰ])', '?\n', result)
        result = re.sub(r'\!\s*(?=[A-ZÁÉÍÓÖŐÚÜŰ])', '!\n', result)
        result = re.sub(r'\.\s*(?=[A-ZÁÉÍÓÖŐÚÜŰ])', '.\n', result)
        # Beolvasott szöveg naplózása
        #log_console(f"[DEBUG] Beolvasott szöveg (első 500 karakter): {result[:500]}")
        # Részletes naplózás
        if not result.strip():
            msg = f"[INFO] Üres szöveg: {file_path} | Képek száma: {image_count}"
            log_console(msg)
            return msg
        if image_count > 0:
            msg = f"[INFO] Szöveg + képek: {file_path} | Képek száma: {image_count}"
            log_console(msg)
        return result
    except Exception as e:
        #import traceback
        #tb = traceback.format_exc()
        log_console(f"[HIBA] DOCX beolvasás sikertelen: {file_path} ({e})")
        return f"[HIBA] DOCX beolvasás sikertelen: {file_path} ({e})"

