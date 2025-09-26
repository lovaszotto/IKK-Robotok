# 🚀 PLÁGIUM ELLENŐRZŐ ROBOT - GYORS REFERENCIA

## ⚡ GYORS INDÍTÁS
```powershell
# 📋 Konfiguráció módosítása
```
notepad Duplikacio.config
```

# 🚀 Gyors futtatás
```
.\start.bat
```

# Excel: d:	mp\duplikacio_eredmenyek_YYYYMMDD_HHMMSS.xlsx
notepad Plagium.config

# 2. DOCX fájlok bemásolása
copy *.docx d:\tmp\

# 3. Robot futtatása
rf_env\Scripts\robot.exe PLG-00-main.robot

# 4. Eredmények ellenőrzése
# Email: automatikusan elküldve
# Excel: d:\tmp\plagium_eredmenyek_YYYYMMDD_HHMMSS.xlsx
```

## 📋 ROBOT FRAMEWORK KULCSSZAVAK

### 🔧 Konfiguráció
| Kulcsszó | Funkció |
|----------|---------|
| `Konfiguracio Betoltese` | Duplikacio.config betöltés |
| `Kapcsolodas Az Adatbazishoz` | SQLite kapcsolat |
| `Hash táblák ellenőrzése` | Adatbázis inicializálás |

### 📄 DOCX Feldolgozás
| Kulcsszó | Funkció |
|----------|---------|
| `Beolvasom A DOCX Fájlt` | Szöveg kinyerés |
| `Batch DOCX ellenőrzés` | Több fájl feldolgozás |
| `Fájladatok Feldolgozása Redundancia Táblába` | Metaadatok mentés |

### 📊 Jelentések
| Kulcsszó | Funkció |
|----------|---------|
| `Redundancia Eredmények Ellenőrzése` | Statisztikák számítás |
| `Email Küldés Eredményekkel` | Automatikus email |

## 🗄️ SQL GYORS LEKÉRDEZÉSEK

### 📈 Statisztikák
```sql
-- Státusz összesítő
SELECT status, COUNT(*) FROM redundancia GROUP BY status;

-- Top 10 legnagyobb redundancia
SELECT file_name, max_ismetelt_karakterszam 
FROM redundancia 
ORDER BY max_ismetelt_karakterszam DESC 
LIMIT 10;

-- Mai feldolgozások
SELECT * FROM redundancia 
WHERE record_date = date('now');
```

### 🔍 Részletes keresés
```sql
-- Gyanús dokumentumok
SELECT file_name, max_ismetelt_karakterszam 
FROM redundancia 
WHERE status = 'Gyanús';

-- Duplikált hash-ek
SELECT hash_value, COUNT(*) as cnt 
FROM hashCodes 
GROUP BY hash_value 
HAVING cnt > 1;
```

## 🔧 PYTHON SCRIPTEK

### 📧 Email teszt
```python
# libraries/send_email.py tesztelés
rf_env\Scripts\python.exe libraries\send_email.py
```

### 📊 Excel export teszt
```python
# libraries/excel_export_simple.py tesztelés
rf_env\Scripts\python.exe libraries\excel_export_simple.py test.xlsx d:\tmp
```

### ⚙️ Konfiguráció teszt
```python
# libraries/get_config.py tesztelés
rf_env\Scripts\python.exe libraries\get_config.py
```

## 🎯 STATUS KÓDOK

| Státusz | Karakter határ | Színkód | Jelentés |
|---------|---------------|---------|----------|
| 🟢 **Rendben** | < status_threshold_gyanus | Zöld | Minimális redundancia |
| 🟡 **Gyanús** | status_threshold_gyanus - status_threshold_masolt-1 | Sárga | Jelentős átfedés |
| 🔴 **Másolt** | ≥ status_threshold_masolt | Piros | Kritikus plágium |

## 📁 FÁJL ÚTVONALAK

### 🔧 Fő komponensek
```
PLG-00-main.robot           # Fő teszt
Duplikacio.config              # Konfiguráció
test_database.db            # Adatbázis
```

### 📚 Libraries
```
libraries/DocxReader.py          # DOCX olvasó
libraries/send_email.py          # Email küldő  
libraries/excel_export_simple.py # Excel export
libraries/get_config.py          # Konfig betöltő
libraries/duplikacio_config.py      # Python konfig
```

### 📂 Resources
```
resources/keywords.robot    # Robot kulcsszavak
resources/variables.robot   # Robot változók
```

## ⚡ HIBAELHÁRÍTÁS EXPRESS

### 🚨 Email nem megy
```powershell
# 1. Outlook újraindítás
taskkill /F /IM outlook.exe
start outlook.exe

# 2. COM objektum regisztráció
regsvr32 /s mso.dll
```

### 🚨 DOCX nem olvasható
```powershell
# 1. Fájl integritás
Get-FileHash dokumentum.docx

# 2. Word-ben megnyitás és újramentés
# 3. Jogosultságok ellenőrzése
icacls dokumentum.docx
```

### 🚨 Adatbázis locked
```powershell
# 1. Folyamatok leállítása
taskkill /F /IM python.exe
taskkill /F /IM robot.exe

# 2. Adatbázis unlock
rf_env\Scripts\python.exe -c "import sqlite3; conn=sqlite3.connect('test_database.db'); conn.close()"
```

## 📊 TELJESÍTMÉNY BENCHMARK

### ⏱️ Átlagos feldolgozási idők
| Fájl méret | Feldolgozási idő | Memória |
|------------|------------------|---------|
| < 1 MB | 10-15 sec | ~100 MB |
| 1-5 MB | 30-60 sec | ~200 MB |
| 5-10 MB | 1-3 min | ~300 MB |
| > 10 MB | 3-10 min | ~500 MB |

### 🔍 Hash teljesítmény
- **SHA-256 generálás**: ~1000 sor/sec
- **Adatbázis összehasonlítás**: ~5000 hash/sec
- **Excel export**: ~100 sor/sec

## 🔄 BATCH MŰVELETEK

### 📦 Tömeges feldolgozás
```robot
# 50+ fájl feldolgozása
@{large_batch}=    List Files In Directory    ${DOCUMENT_PATH}    *.docx
Log    Feldolgozandó fájlok: ${large_batch.__len__()}
```

### 🧹 Adatbázis karbantartás
```sql
-- Régi rekordok törlése (30 naponként)
DELETE FROM redundancia WHERE record_date < date('now', '-30 days');
VACUUM;
```

## 📧 EMAIL TEMPLATE TESTRESZABÁS

### 🎨 CSS módosítás
```css
/* send_email.py CSS szekció */
.status-ok { color: #28a745; font-weight: bold; }
.status-suspicious { color: #ffc107; font-weight: bold; }
.status-copied { color: #dc3545; font-weight: bold; }
```

### 📝 Szöveg módosítás
```python
# Email tárgy template
subject = f"🔍 Plágium Ellenőrzés - {total_docs} dokumentum - {current_date}"

# Email fejléc
header = f"<h2>📋 Plágium Ellenőrzés Eredményei - {current_date}</h2>"
```

## 🔧 KONFIGURÁCIÓS SABLONOK

### 🏢 Vállalati használat
```ini
email=quality@company.hu
input_folder=\\server\documents\incoming
output_folder=\\server\reports\plagium
email_subject=Vállalati Plágium Ellenőrzés - {date}
excel_prefix=company_plagium_report
```

### 🎓 Oktatási intézmény
```ini
email=teacher@university.edu
input_folder=C:\Students\Submissions
output_folder=C:\Reports\PlagiumCheck
email_subject=Hallgatói Dolgozatok Ellenőrzése
excel_prefix=student_plagium_check
```

---

*⚡ Gyors referencia - v2.1.0*  
*🕒 5 perces gyors útmutató a napi használathoz*
