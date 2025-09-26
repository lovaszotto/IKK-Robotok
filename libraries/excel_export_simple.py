import sys, os
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

import os
from datetime import datetime
from openpyxl import Workbook
from openpyxl.styles import Font, PatternFill, Border, Side, Alignment
from openpyxl.utils import get_column_letter
from libraries.duplikacio_config import DuplikacioConfig

def create_excel_export_legacy_disabled(excel_filename=None, output_folder=None):
    """
    LEGACY EXCEL EXPORT - LETILTVA
    Az adatbázisból történő Excel export funkcionalitás jelenleg nem aktív.
    Az adatbázis kezelést eltávolítottuk a rendszerből.
    A formálellenőrzés most közvetlenül Excel-be ír.
    """
    print("[INFO] Excel export funkció jelenleg nem aktív (legacy)")
    print("[INFO] Az adatbázis kezelést eltávolítottuk a rendszerből")
    print("[INFO] A formálellenőrzés eredményeit közvetlenül az Excel fájlba írjuk")
    return False

# Régi funkcionalitás kompatibilitásért
def create_excel_export(excel_filename=None, output_folder=None):
    """Kompatibilitási wrapper a legacy funkcióért"""
    return create_excel_export_legacy_disabled(excel_filename, output_folder)

# --- Főprogram blokk a közvetlen futtatáshoz ---
if __name__ == "__main__":
    print("[INFO] excel_export_simple.py - LEGACY verzió")
    print("[INFO] Az adatbázis kezelést eltávolítottuk a rendszerből")
    create_excel_export()
