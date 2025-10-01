from __future__ import annotations

import os
import zipfile
from typing import Optional

try:
    from docx import Document  # type: ignore
except Exception:  # pragma: no cover
    Document = None  # Fallback if python-docx is not available at import time


class DocxEditable:
    """
    Robot Framework library to determine if a DOCX file is editable.

    Heuristics:
    - Must have .docx extension
    - Must be readable by python-docx
    - word/settings.xml must not contain w:documentProtection
    """

    ROBOT_LIBRARY_SCOPE = "GLOBAL"

    def _is_docx_extension(self, path: str) -> bool:
        if not path:
            return False
        _, ext = os.path.splitext(path)
        return ext.lower() == ".docx"

    def _has_valid_docx_structure(self, path: str) -> bool:
        try:
            with zipfile.ZipFile(path, "r") as zf:
                names = set(zf.namelist())
                return (
                    "[Content_Types].xml" in names
                    and "word/document.xml" in names
                )
        except Exception:
            return False

    def _has_no_document_protection(self, path: str) -> bool:
        try:
            with zipfile.ZipFile(path, "r") as zf:
                if "word/settings.xml" not in zf.namelist():
                    # No settings.xml -> assume no explicit protection
                    return True
                data = zf.read("word/settings.xml")
        except Exception:
            # cannot read -> be conservative: consider protected/invalid
            return False
        text = data.decode("utf-8", errors="ignore").lower()
        return "documentprotection" not in text

    def _can_open_with_pythondocx(self, path: str) -> bool:
        if Document is None:
            return False
        try:
            Document(path)
            return True
        except Exception:
            return False

    def _is_writable_file(self, path: str) -> bool:
        if not path or not os.path.exists(path):
            return False
        # Quick permission check
        if not os.access(path, os.W_OK):
            return False
        # Attempt to open for read+write without truncating
        try:
            with open(path, "rb+"):
                pass
            return True
        except Exception:
            return False

    def _is_editable_docx(self, path: str) -> bool:
        """
        Returns True if the given file seems to be an editable DOCX.

        - Checks extension is .docx
        - Tries to open with python-docx
        - Parses word/settings.xml to ensure there's no document protection element
        """
        if not path or not os.path.exists(path):
            return False

        if not self._is_docx_extension(path):
            return False

        if not self._has_valid_docx_structure(path):
            return False

        if not self._can_open_with_pythondocx(path):
            return False

        if not self._has_no_document_protection(path):
            return False

        if not self._is_writable_file(path):
            return False

        return True

    # Expose as Robot keyword name "Is Editable Docx"
    # Robot keyword exports (spaces instead of underscores)
    def Is_Docx_Extension(self, path: str) -> bool:
        return self._is_docx_extension(path)

    def Has_Valid_Docx_Structure(self, path: str) -> bool:
        return self._has_valid_docx_structure(path)

    def Has_No_Document_Protection(self, path: str) -> bool:
        return self._has_no_document_protection(path)

    def Can_Open_With_PythonDocx(self, path: str) -> bool:
        return self._can_open_with_pythondocx(path)

    def Is_Writable_File(self, path: str) -> bool:
        return self._is_writable_file(path)

    def Is_Editable_Docx(self, path: str) -> bool:  # aggregate
        return self._is_editable_docx(path)
