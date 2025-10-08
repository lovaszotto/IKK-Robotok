# 🤖 ROBOT FRAMEWORK PLÁGIUM ELLENŐRZŐ - TECHNIKAI ÁTTEKINTÉS

## 🎯 RENDSZER CÉLJA
Automatizált DOCX dokumentum plágium ellenőrzés hash-alapú algoritmussal, Excel jelentéskészítéssel és automatikus email értesítéssel.

## 🏗️ ARCHITEKTÚRA

### 🤖 Robot Framework Modulok
- **PLG-00-main.robot**: Főfolyamat vezérlő
- **PLG-02-read_docx.robot**: DOCX beolvasás és hash generálás

### 🐍 Python Backend
- **DocxReader.py**: DOCX tartalom kinyerés
- **send_email.py**: Outlook COM email automatizálás
- **excel_export_simple.py**: openpyxl alapú Excel generálás
- **plagium_config.py**: Konfigurációs osztály

### 🗄️ Adatbázis Réteg
- **SQLite**: Helyi adatbázis (test_database.db)
- **1 tábla**: redundancia
- **Egyszerűsített struktúra**: Csak a redundancia adatok

## 🔍 PLÁGIUM ALGORITMUS

### 1️⃣ Hash Generálás
```python
import hashlib
hash_value = hashlib.sha256(line_content.encode('utf-8')).hexdigest()
```

### 2️⃣ Összehasonlítás
```sql
SELECT file_name, max_ismetelt_karakterszam FROM redundancia 
WHERE overview LIKE '%keresett szöveg%'
```

### 3️⃣ Kategorizálás
- **🟢 Rendben**: < status_threshold_gyanus karakter redundancia
- **🟡 Gyanús**: status_threshold_gyanus - status_threshold_masolt karakter redundancia  
- **🔴 Másolt**: > status_threshold_masolt karakter redundancia

## 📧 EMAIL AUTOMATIZÁLÁS

### Outlook COM Integráció
```python
outlook = win32com.client.Dispatch("Outlook.Application")
mail = outlook.CreateItem(0)
mail.Send()  # Automatikus küldés
```

### Hibakezelés
- ✅ 3 próbálkozás exponenciális várakozással
- ✅ Piszkozat mentés fallback megoldás
- ✅ Részletes hibanaplózás

## 📊 KIMENETEK

### Excel Jelentés
- **Formátum**: .xlsx (openpyxl)
- **Tartalom**: Státusz, fájlnév, redundancia metrikák
- **Stílus**: Színkódolt státusz, formázott táblázat

### Email Template
- **HTML formátum**: Modern, reszponzív design
- **Melléklet**: Excel fájl automatikus csatolás
- **Tartalom**: Összesítő statisztikák + részletes lista

## ⚙️ KONFIGURÁLÁS

### Plagium.config
```ini
email=lovasz.otto@clarity.hu
input_folder=d:\tmp
output_folder=d:\tmp
email_subject=Plagium Ellenorzes - Eredmenyek
excel_prefix=plagium_eredmenyek
```

### Robot Framework változók
```robot
${SQLITE_DB_FILE}    test_database.db
${PYTHON_EXEC}       rf_env/Scripts/python.exe
${DOCUMENT_PATH}     ${CONFIG_INPUT_FOLDER}
```

## 🚀 FUTTATÁS

### Egyszerű futtatás
```powershell
rf_env\Scripts\robot.exe PLG-00-main.robot
```

### Batch futtatás
```robot
FOR    ${docx_file}    IN    @{docx_files}
    Fájladatok Feldolgozása Redundancia Táblába    ${docx_file}
    
END
```

## 🔧 TELJESÍTMÉNY

### Feldolgozási sebesség
- **Kis fájl** (<1MB): ~10-15 másodperc
- **Közepes fájl** (1-5MB): ~30-60 másodperc  
- **Nagy fájl** (>5MB): ~2-5 perc

### Memória használat
- **Alapfolyamat**: ~50-100 MB
- **Nagy dokumentum**: ~200-500 MB
- **Batch feldolgozás**: Lineáris skálázódás

## 🛡️ BIZTONSÁG

### Adatvédelem
- ✅ Helyi adatkezelés (nincs cloud)
- ✅ SHA-256 kriptográfiai hash
- ✅ Windows biztonsági modell

### Hibakezelés
- ✅ Try-except blokkok minden kritikus ponton
- ✅ Részletes error logging
- ✅ Graceful degradation

## 📋 FÜGGŐSÉGEK

### Python csomagok
```txt
robotframework==6.1.1
robotframework-databaselibrary==1.2.4
python-docx==0.8.11
openpyxl==3.1.2
pywin32==306
```

### Rendszerkövetelmények
- **OS**: Windows 10/11
- **Python**: 3.8+
- **Outlook**: Microsoft Outlook telepítve és konfigurálva
- **Memória**: Min. 4GB RAM
- **Tárhely**: Min. 1GB szabad hely

## 🔄 KARBANTARTÁS

### Adatbázis tisztítás
```sql
DELETE FROM redundancia WHERE record_date < date('now', '-90 days');
VACUUM;
```

### Log fájlok rotáció
```powershell
Get-ChildItem results\ -Name "*.html" | Where-Object {$_.LastWriteTime -lt (Get-Date).AddDays(-30)} | Remove-Item
```

## 🐛 HIBAELHÁRÍTÁS

### Gyakori hibák
1. **Email küldés hiba**: Outlook újraindítás
2. **DOCX olvasási hiba**: Fájl integritás ellenőrzés
3. **Adatbázis lock**: Kapcsolatok bezárása

### Debug mód
```robot
Log String To Console    ${variable_value}
Log    Detailed information    DEBUG
```

---

*🔧 Technikai dokumentáció - v2.1.0*  
*📅 Frissítve: 2025.08.25*
