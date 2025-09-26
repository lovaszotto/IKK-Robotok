import sys
import openpyxl
from openpyxl.utils import get_column_letter, column_index_from_string
import re

def main():
    # Paraméterek ellenőrzése
    if len(sys.argv) < 5:
        print("HIBA: Nem elegendő paraméter!")
        print("Használat:")
        print("  - Koordináta mód: python fill_excel_cell.py <excel_file> <sheet_name> <row> <col> <value>")
        print("  - Cell referencia mód: python fill_excel_cell.py <excel_file> <sheet_name> <cell_ref> <value>")
        sys.exit(1)
    
    excel_file = sys.argv[1]
    sheet_name = sys.argv[2]
    
    # Ellenőrizzük, hogy 4 vagy 5 paramétert kaptunk
    if len(sys.argv) == 5:
        # 4 paraméter: cell_ref formátum (pl. A1, B3)
        cell_ref = sys.argv[3]
        value = sys.argv[4]
        print(f"Cell referencia mód: {cell_ref} = '{value}'")
    else:
        # 5 paraméter: row, col, value formátum
        row = int(sys.argv[3])
        col = sys.argv[4]
        value = sys.argv[5]
        
        # Oszlop konvertálása
        if col.isdigit():
            col_letter = get_column_letter(int(col))
            cell_ref = f"{col_letter}{row}"
        else:
            cell_ref = f"{col}{row}"
        
        print(f"Koordináta mód: sor {row}, oszlop {col} -> {cell_ref} = '{value}'")
    
    try:
        print(f"Megnyitom az Excel fájlt: {excel_file}")
        wb = openpyxl.load_workbook(excel_file)
        
        # Sheet ellenőrzése
        if sheet_name not in wb.sheetnames:
            print(f"HIBA: Sheet '{sheet_name}' nem található!")
            print(f"Elérhető sheet-ek: {wb.sheetnames}")
            sys.exit(1)
        
        ws = wb[sheet_name]
        print(f"Sheet '{sheet_name}' megnyitva")
        
        # Eredeti érték lekérdezése és új érték beállítása
        old_value = ws[cell_ref].value
        ws[cell_ref] = value
        
        # Fájl mentése retry mechanizmussal
        import time
        max_retries = 3
        for retry in range(max_retries):
            try:
                wb.save(excel_file)
                wb.close()
                break
            except PermissionError as pe:
                if retry < max_retries - 1:
                    print(f"Excel fájl zárva, próbálkozás {retry + 1}/{max_retries} - várakozás 2 másodperc...")
                    wb.close()
                    time.sleep(2)
                    # Újra megnyitás a következő próbálkozáshoz
                    if retry < max_retries - 1:
                        wb = openpyxl.load_workbook(excel_file)
                        ws = wb[sheet_name]
                        ws[cell_ref] = value
                else:
                    print(f"KRITIKUS HIBA: Excel fájl nem menthető {max_retries} próbálkozás után: {str(pe)}")
                    wb.close()
                    # Folytatás a hiba ellenére, ne álljon le a teljes teszt
                    return
        
        print(f"Sikeres frissítés:")
        print(f"  Cella: {cell_ref}")
        print(f"  Régi érték: '{old_value}'")  
        print(f"  Új érték: '{value}'")
        print(f"Excel fájl mentve: {excel_file}")
        
    except Exception as e:
        print(f"HIBA: {str(e)}")
        import traceback
        traceback.print_exc()
        # Nem kilépünk hibával, folytatjuk a teszteket
        return

if __name__ == "__main__":
    main()