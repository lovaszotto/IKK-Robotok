import os
import re
import zipfile
from docx import Document
from robot.api import logger
from robot.api.deco import keyword

@keyword("Has Page Numbers")
def has_page_numbers(docx_path):
    logger.debug(f"[DocxPageNumbers] Ellenőrzés indul: {docx_path}")

    if not docx_path or not os.path.exists(docx_path):
        logger.warn(f"[DocxPageNumbers] Fájl nem található: {docx_path}")
        return False

    try:
        doc = Document(docx_path)

        # Ellenőrzés a fejlécben és láblécben
        for idx, section in enumerate(doc.sections):
            # Fejlécek
            for name, header in (
                ("header", section.header),
                ("first_page_header", section.first_page_header),
                ("even_page_header", section.even_page_header),
            ):
                if _contains_page_field(header):
                    logger.debug(f"[DocxPageNumbers] Találat a {name} részben (section #{idx}).")
                    return True
            # Láblécek
            for name, footer in (
                ("footer", section.footer),
                ("first_page_footer", section.first_page_footer),
                ("even_page_footer", section.even_page_footer),
            ):
                if _contains_page_field(footer):
                    logger.debug(f"[DocxPageNumbers] Találat a {name} részben (section #{idx}).")
                    return True
    except Exception as e:
        logger.warn(f"[DocxPageNumbers] python-docx hiba: {e}. Átváltás ZIP-alapú ellenőrzésre...")

    # Fallback: ZIP/XML alapú ellenőrzés
    try:
        if _has_page_numbers_by_zip(docx_path):
            logger.debug("[DocxPageNumbers] Találat ZIP/XML ellenőrzéssel.")
            return True
    except Exception as e:
        logger.warn(f"[DocxPageNumbers] ZIP ellenőrzés hiba: {e}")

    logger.debug("[DocxPageNumbers] Oldalszámozás nem található.")
    return False

def _contains_page_field(container):
    """Segédfüggvény: PAGE/NUMPAGES mező keresése az XML-ben"""
    for paragraph in container.paragraphs:
        xml = paragraph._element.xml
        if "PAGE" in xml or "NUMPAGES" in xml:
            return True
    return False

def _has_page_numbers_by_zip(docx_path: str) -> bool:
    """ZIP szintű vizsgálat: a header/footer XML-ekben keresi a PAGE/NUMPAGES mezőket."""
    patterns = (
        re.compile(r'w:fldSimple[^>]+w:instr="[^"]*\b(PAGE|NUMPAGES)\b', re.IGNORECASE),
        re.compile(r'<w:instrText[^>]*>[^<]*(PAGE|NUMPAGES)[^<]*</w:instrText>', re.IGNORECASE),
    )
    with zipfile.ZipFile(docx_path, 'r') as z:
        names = [n for n in z.namelist() if n.startswith('word/') and ('header' in n or 'footer' in n)]
        for name in names:
            try:
                xml = z.read(name).decode('utf-8', errors='ignore')
                if any(p.search(xml) for p in patterns):
                    logger.debug(f"[DocxPageNumbers] Találat: {name}")
                    return True
            except Exception as e:
                logger.warn(f"[DocxPageNumbers] Nem olvasható {name}: {e}")
    return False
