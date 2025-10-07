import zipfile
import re
import xml.etree.ElementTree as ET
from robot.api.deco import keyword

__all__ = [
    'extract_toc_entries_from_docx_file',
]
@keyword('Extract TOC Entries From Docx File')
def extract_toc_entries_from_docx_file(docx_path):
    """
    Kicsomagolja a DOCX-ből a word/document.xml-t, eltávolítja a vezérlőkaraktereket, és visszaadja a TOC bejegyzések listáját.
    """
    with zipfile.ZipFile(docx_path, 'r') as z:
        xml = z.read('word/document.xml').decode('utf-8')
    xml_clean = re.sub(r'[\x00-\x08\x0B\x0C\x0E-\x1F\x7F\u00A0]', '', xml)
    root = ET.fromstring(xml_clean)
    W = 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'
    entries = []
    instr_buffer = ''
    in_toc = False
    collect = False
    current = ''
    nodes = list(root.iter())
    n = len(nodes)
    i = 0
    while i < n:
        node = nodes[i]
        tag = node.tag if isinstance(node.tag, str) else None
        fld = tag == '{'+W+'}fldChar'
        instr = tag == '{'+W+'}instrText'
        txt = tag == '{'+W+'}t'
        if fld:
            ftype = node.attrib.get('{'+W+'}fldCharType')
            if ftype == 'begin':
                instr_buffer = ''
                in_toc = False
                collect = False
            elif ftype == 'separate':
                is_toc = 'toc' in instr_buffer.lower()
                in_toc = is_toc
                collect = is_toc
            elif ftype == 'end':
                if in_toc:
                    text = current.strip()
                    if text:
                        entries.append(text)
                in_toc = False
                collect = False
                instr_buffer = ''
                current = ''
        elif instr:
            t = node.text or ''
            instr_buffer += t
        elif txt and collect:
            t = node.text or ''
            current += t
        i += 1
    return entries

