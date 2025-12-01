

from robot.api.deco import keyword
import os

@keyword('Find Doc Files Recursively')
def find_doc_files_recursively(directory):
    doc_files = []
    for root, dirs, files in os.walk(directory):
        for file in files:
            if file.lower().endswith('.doc') and not file.lower().endswith('.docx') and not file.startswith('~$'):
                doc_files.append(os.path.abspath(os.path.join(root, file)))
            elif file.endswith('.DOC') and not file.endswith('.DOCX') and not file.startswith('~$'):
                doc_files.append(os.path.abspath(os.path.join(root, file)))
    return doc_files

@keyword('Find Docx Files Recursively')
def find_docx_files_recursively(directory):
    docx_files = []
    for root, dirs, files in os.walk(directory):
        for file in files:
            if file.lower().endswith('.docx') and not file.startswith('~$'):
                docx_files.append(os.path.abspath(os.path.join(root, file)))
    return docx_files
