# IKK04-Dokumentum-WEB-Ellenőrzés
# 🤖 Robot Framework Dokumentum és WEB Ellenőrző Rendszer

[![Robot Framework](https://img.shields.io/badge/Robot-Framework-00c0ef.svg)](https://robotframework.org/)
[![Python](https://img.shields.io/badge/Python-3.8%2B-blue.svg)](https://www.python.org/)
[![Selenium](https://img.shields.io/badge/Selenium-WebDriver-green.svg)](https://selenium.dev/)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

> 🔍 **Automatizált DOCX dokumentum formálellenőrzés és WEB alkalmazás tesztelés** Robot Framework-kel, Excel jelentéskészítéssel és webes interfészel.

## ✨ Főbb funkciók

- � **DOCX dokumentum formálellenőrzés** 23 ellenőrzési kategóriával
- 🌐 **WEB alkalmazás tesztelés** Selenium WebDriver-rel
- 🎯 **Automatizált navigáció** webes tananyagokban
- 📊 **Excel jelentések** részletes eredményekkel
- 📧 **Automatikus email küldés** Outlook COM integrációval
- 🗄️ **SQLite adatbázis** teljes előzmény nyilvántartással
- 🔄 **Batch feldolgozás** több dokumentum egyidejű kezelésére
- 🌐 **Webes interfész** Flask szerverrel
- 🎪 **Média ellenőrzés** képek és videók kezelésével

## 🚀 Gyors indítás

### 1️⃣ Telepítés
```powershell
# Virtuális környezet aktiválása
rf_env\Scripts\activate

# Vagy egyszerűen
.\telepito.bat
```

### 2️⃣ Konfiguráció
```ini
# IKK.config szerkesztése
email=your-email@company.com
input_folder=C:\Documents\ToCheck
output_folder=C:\Reports
web_url=https://your-web-app.com
```

```ini
# Duplikacio.config - duplikáció ellenőrzés
INPUT=C:\tmp\keziratok_teszteleshez
OUTPUT=C:\tmp
EXCEL_PREFIX=duplikacio_export
THRESHOLD_GYANUS=300
THRESHOLD_MASOLT=1200
```

### 3️⃣ Futtatás
```powershell
# Dokumentum formálellenőrzés
rf_env\Scripts\robot.exe PLG-00-main.robot

# WEB ellenőrzés
rf_env\Scripts\robot.exe PLG-05-WEB-ellenor-main.robot

# Batch fájlokkal
start.bat           # Dokumentum ellenőrzés
webserver.bat       # Webes interfész
```

## 📊 Eredmény példa

### 📈 Konsol kimenet
```
=== DOCX FÁJLOK KERESÉSE ===
Talált DOCX fájlok száma: 3

**************************************************************************
* wtc_03- Témák közötti navigáció ellenőrzése
**************************************************************************

>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>Talált képek száma: 2
Kép alt attribútum: Ellenőrzés
Kép Content-Type: image/svg+xml

>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>Talált videók száma: 0

✅ WEB ELLENŐRZÉS BEFEJEZVE!
🎯 Eredmények: results/log.html
```

### 📧 Automatikus email
- **HTML formátumú jelentés** WEB és dokumentum ellenőrzés eredményekkel
- **Excel melléklet** részletes adatokkal és média katalógussal
- **Összesítő statisztikák** tesztesetek eredményeivel

## 🏗️ Rendszer architektúra

```
📁 IKK04-Dokumentum-WEB-Ellenőrzés/
├── 🤖 PLG-00-main.robot          # Dokumentum formálellenőrzés
├── 🌐 PLG-05-WEB-ellenor-main.robot # WEB alkalmazás tesztelés
├── ⚙️ IKK.config                 # Fő konfigurációs fájl
├── ⚙️ Duplikacio.config          # Duplikáció ellenőrzés konfiguráció
├── 📚 libraries/                 # Python modulok
│   ├── 🐍 DocxReader.py          # DOCX olvasó library
│   ├── 📧 send_email.py          # Email küldő rendszer
│   ├── 🌐 web_server.py          # Flask webes szerver
│   └── ⚙️ get_config.py          # Konfiguráció betöltő
├── 📂 resources/                 # Robot Framework erőforrások
│   ├── 🔑 keywords.robot         # Kulcsszó definíciók
│   ├── 🔢 variables.robot        # Változó definíciók
│   └── 📂 testcases/             # WEB tesztesetek
├── 🌐 web/                       # Webes interfész
├── 📊 sablonok/                  # Excel sablonok
├── 🗃️ test_database.db           # SQLite adatbázis
└── 🐍 rf_env/                    # Python virtuális környezet
```

## 🔍 Ellenőrzési algoritmusok

### Dokumentum formálellenőrzés (23 kategória)
1. **📄 DOCX beolvasás**: Szöveges tartalom kinyerése
2. **🎯 Arculati elemek**: Logók, színek, betűtípusok
3. **� Szövegformázás**: Címsorok, bekezdések, felsorolások
4. **� Táblázatok és ábrák**: Formátum és elhelyezés ellenőrzés
5. **� Oldalbeállítások**: Margók, fejléc, lábléc

### WEB alkalmazás tesztelés
- **🌐 Selenium WebDriver**: Automatizált böngésző vezérlés
- **🎯 Navigációs tesztek**: Témák közötti átjárás
- **�️ Média ellenőrzés**: Képek és videók feltérképezése
- **📊 Eredmény gyűjtés**: Excel export média katalógussal
- **⚡ Automatikus interakció**: Gombok, űrlapok kezelése

### Kategorizálási szabályok
- 🟢 **Megfelelő**: Teljesíti a követelményeket
- 🟡 **Figyelmeztetés**: Kisebb hibák találhatók
- 🔴 **Hiba**: Jelentős problémák vannak

## 📧 Email automatizálás

### Háromszintű küldési stratégia
1. **🎯 Outlook COM**: Automatikus `mail.Send()` hívás
2. **💾 Piszkozat**: Fallback mentés Drafts mappába  
3. **📝 Hibanapló**: Részletes hibajelentés

```python
# Outlook COM automatikus küldés
outlook = win32com.client.Dispatch("Outlook.Application")
mail = outlook.CreateItem(0)
mail.Send()  # 🚀 AUTOMATIKUS KÜLDÉS
```

## 🗄️ Adatbázis struktúra

### 📊 Redundancia tábla
- `status`: Kategorizálás (Rendben/Gyanús/Másolt)
- `file_name`: Dokumentum neve
- `max_ismetelt_karakterszam`: Legnagyobb redundancia
- `record_date`: Feldolgozás dátuma

### � Repeat tábla  
- `hash_value`: MD5 hash (PRIMARY KEY)
- `file_name`, `file_path`: Fájl információk
- `line_content`: Eredeti szöveg tartalom

### 🚫 Skip funkciók
- `hashValue`: MD5 hash kihagyandó szövegekhez (PRIMARY KEY)
- `line_content`: Átugrandó szöveg tartalom

### 🔄 Repeat tábla
- `repeated_line`: Ismétlődő szövegrészek
- `block_id`: Ismétlési blokk azonosító
- `sum_line_length`: Összesített redundancia hossz

## ⚙️ Konfiguráció

### Duplikacio.config beállítások
| Paraméter | Leírás | Példa |
|-----------|--------|-------|
| `email` | Címzett email | `manager@company.hu` |
| `input_folder` | DOCX forrás könyvtár | `C:\Documents\Check` |
| `output_folder` | Excel cél könyvtár | `C:\Reports\Output` |
| `email_subject` | Email tárgy sablon | `Duplikacio Ellenorzes - Eredmenyek` |
| `excel_prefix` | Excel fájl prefix | `duplikacio_eredmenyek` |

### DuplikacioSkip.config beállítások
Ez a fájl tartalmazza azokat a szövegeket, amelyeket a rendszer automatikusan kihagynak a plágium ellenőrzés során:

```
igaz vagy hamis a következő állítás?
válaszd ki a helyes megoldásokat!
válaszd ki a helyes választ!
```

**Működés**: 
- Minden startup-kor automatikusan betöltődik
- MD5 hash generálás minden sorhoz
- skip funkciókkal való kizárás
- Feldolgozás során automatikus szűrés

## 🛠️ Rendszerkövetelmények

- **OS**: Windows 10/11
- **Python**: 3.8+ (python.org)
- **Outlook**: Microsoft Outlook telepítve
- **Memória**: Min. 4GB RAM
- **Tárhely**: Min. 1GB szabad hely

## 📦 Függőségek

```txt
robotframework
robotframework-seleniumlibrary
robotframework-databaselibrary
robotframework-requests
flask
docx
python-docx
lxml
openpyxl
langdetect
pillow
requests
```


## 🔧 Telepítés részletesen

### 0️⃣ Git konfiguráció (opcionális)
```powershell
git config --global user.name "Saját Név"
git config --global user.email "sajat@email.hu"
```

### 1️⃣ Python telepítés
```powershell
# Python letöltés: https://python.org
python --version  # Ellenőrzés
```

### 2️⃣ Projekt klónozás
```powershell
git clone https://github.com/your-repo/plagium-checker.git
cd plagium-checker
```

### 3️⃣ Virtuális környezet
```powershell
python -m venv rf_env
rf_env\Scripts\activate
pip install -r requirements.txt
```

### 4️⃣ Konfiguráció
```powershell
notepad IKK.config              # Email, könyvtárak és WEB URL beállítása
notepad Duplikacio.config       # Duplikáció ellenőrzés paraméterek
```

## 🧪 Tesztelés

### Unit tesztek
```powershell
# Hash generálás teszt
rf_env\Scripts\python.exe -c "from libraries.DocxReader import *; print('Hash test OK')"

# Email teszt
rf_env\Scripts\python.exe libraries\send_email.py

# Excel export teszt  
rf_env\Scripts\python.exe libraries\excel_export_simple.py test.xlsx
```

### Integrációs teszt
```powershell
# Teljes folyamat dry-run
rf_env\Scripts\robot.exe --dryrun PLG-00-main.robot
```

## ▶️ Futtatás és logok

### Dokumentum ellenőrzés mód
A PLG-00-main.robot teljes DOCX dokumentum formálellenőrzést végez 23 kategóriában.

### WEB ellenőrzés mód
A PLG-05-WEB-ellenor-main.robot automatizált webes tesztelést hajt végre.

### Futtatási módok

**PowerShell-ből (aktív virtuális környezet mellett):**
```powershell
# Dokumentum ellenőrzés
rf_env\Scripts\robot.exe PLG-00-main.robot

# WEB ellenőrzés
rf_env\Scripts\robot.exe PLG-05-WEB-ellenor-main.robot

# Logok nélkül
rf_env\Scripts\robot.exe --output NONE --log NONE --report NONE PLG-00-main.robot
```

**Batch fájlokkal:**
```batch
start.bat           # Dokumentum ellenőrzés
webserver.bat       # Webes interfész indítása
```

### Eredmények helye
- **Robot logok**: results/log.html, results/report.html
- **Excel exportok**: Konfigurált output_folder
- **Egyedi logok**: RunLog_YYYYMMDD_HHMMSS.log fájlok

### Logok megtekintése böngészőben (helyi http szerver)

Ha szeretnéd a kimeneti mappát böngészőben tallózni (pl. több RunLog és Excel fájl gyors áttekintése):

1) Nyisd meg PowerShellben a kimeneti mappát (az `output_folder` érték a Duplikacio.config-ban):

```powershell
Set-Location "C:\TMP"   # Példa, igazítsd az output_folder értékhez
```

2) Indíts egy egyszerű HTTP szervert a 8000-es porton:

```powershell
python -m http.server 8000
```

3) Nyisd meg böngészőben:

```
http://localhost:8000/
```

Innen megnyithatod a legutóbbi `RunLog_*.log` fájlt és az elkészült Excel jelentéseket is.

## 📊 Teljesítmény

### Feldolgozási sebesség
- **Kis fájl** (<1MB): ~10-15 másodperc
- **Közepes fájl** (1-5MB): ~30-60 másodperc
- **Nagy fájl** (>5MB): ~2-5 perc

### Skálázhatóság
- **Batch méret**: 50+ fájl egyidejűleg
- **Adatbázis**: 10,000+ dokumentum
- **Hash tábla**: 1M+ bejegyzés

## 🐛 Hibaelhárítás

### Gyakori problémák

#### 📧 Email küldési hiba
```powershell
# Outlook újraindítás
taskkill /F /IM outlook.exe
start outlook.exe
```

#### 📄 DOCX olvasási hiba  
```powershell
# Fájl integritás ellenőrzés
Get-FileHash dokumentum.docx
```

#### 🗄️ Adatbázis lock
```powershell
# Folyamatok leállítása
taskkill /F /IM python.exe
```

### Debug mód
```ini
# Duplikacio.config
debug_mode=true
```

### Skip szabályok tesztelése
```powershell
# DuplikacioSkip.config módosítása után
rf_env\Scripts\robot.exe PLG-00-main.robot

# Skip logok ellenőrzése a konzol kimenetben:
# "Skip hash:igaz vagy hamis a következő állítás?"
```

## 🚫 Skip funkcionalitás részletesen

### Mi a skip funkcionalitás?
A skip funkcionalitás lehetővé teszi, hogy bizonyos gyakran ismétlődő szövegeket automatikusan kihagyjon a plágium ellenőrzés során. Ez különösen hasznos oktatási anyagokban, ahol standard kérdésformák (pl. "igaz vagy hamis", "válaszd ki a helyes választ") gyakran ismétlődnek.

### Hogyan működik?
1. **Startup**: A rendszer beolvassa a `DuplikacioSkip.config` fájlt
2. **Hash generálás**: Minden sorhoz MD5 hash készül
3. **Adatbázis feltöltés**: Hash-ek bekerülnek a `skipHashCodes` táblába
4. **Feldolgozás**: Minden dokumentum sor hash-e összevetésre kerül a skip listával
5. **Szűrés**: Egyező hash esetén a sor kihagyásra kerül

### Használati példák
```
# DuplikacioSkip.config példa tartalom:
igaz vagy hamis a következő állítás?
válaszd ki a helyes megoldásokat!
válaszd ki a helyes választ!
jelöld meg a megfelelő választ!
írd be a hiányzó szót!
```

### Konzol kimenet példa
```
DuplikacioSkip.config betöltése...
DuplikacioSkip.config betöltve: 5 sor feldolgozva

...feldolgozás közben...
Skip hash:igaz vagy hamis a következő állítás?
Skip hash:válaszd ki a helyes választ!
```

## 📖 Dokumentáció

- 📋 **[Teljes dokumentáció](DOKUMENTACIO.md)**: Részletes technikai leírás
- ⚡ **[Gyors referencia](GYORS_REFERENCIA.md)**: 5 perces útmutató  
- 🔧 **[Technikai áttekintés](TECHNIKAI_ATTEKINTES.md)**: Fejlesztői információk
- 📞 **[Telepítési útmutató](TELEPITO_UTMUTATO.txt)**: Lépésről lépésre

## 🤝 Közreműködés

### Pull Request folyamat
1. Fork-old a repository-t
2. Hozz létre feature branch-et (`git checkout -b feature/amazing-feature`)
3. Commitold a változásokat (`git commit -m 'Add amazing feature'`)
4. Push-old a branch-et (`git push origin feature/amazing-feature`)
5. Nyiss Pull Request-et

### Fejlesztői irányelvek
- **Python**: PEP 8 kódstílus
- **Robot Framework**: Hivatalos style guide
- **Commit üzenetek**: Conventional Commits formátum
- **Tesztelés**: Minden új funkcióhoz unit teszt

## 🏷️ Changelog

### v3.0.0 (2025-11-05) - IKK04 WEB Release
- ✅ **ÚJ**: WEB alkalmazás automatizált tesztelés
- ✅ **ÚJ**: Selenium WebDriver integráció
- ✅ **ÚJ**: 23 formálellenőrzési kategória
- ✅ **ÚJ**: Webes interfész Flask szerverrel
- ✅ **ÚJ**: Média ellenőrzés (képek, videók)
- ✅ **FEJLESZTÉS**: Teljes rendszer újrastrukturálás

### v2.1.0 (2025-08-25)
- ✅ **ÚJ**: Háromszintű email küldési rendszer
- ✅ **JAVÍTÁS**: Windows path escape karakterek  
- ✅ **OPTIMALIZÁLÁS**: Libraries könyvtár refaktoring
- ✅ **FEJLESZTÉS**: Tisztított logging rendszer

### v2.0.0 (2025-08-20)
- ✅ **ÚJ**: Outlook COM automatikus email
- ✅ **ÚJ**: Excel export funkció
- ✅ **JAVÍTÁS**: SQLite optimalizálás

## 📄 Licenc

Ez a projekt [MIT](LICENSE) licenc alatt áll. Lásd a `LICENSE` fájlt a részletekért.

## 📞 Támogatás

- 📧 **Email**: support@plagium-checker.com
- 💬 **Issues**: [GitHub Issues](https://github.com/your-repo/issues)
- 📖 **Wiki**: [Projekt Wiki](https://github.com/your-repo/wiki)

## 🙏 Köszönetnyilvánítás

- **Robot Framework** csapat a fantasztikus automatizálási keretrendszerért
- **Python-docx** fejlesztők a DOCX támogatásért  
- **OpenPyXL** közösség az Excel integrációért
- **Microsoft** a Outlook COM API-ért

---

**⭐ Ha hasznos volt a projekt, adj egy csillagot a GitHub-on!**

*🤖 Robot Framework IKK04 Dokumentum és WEB Ellenőrző v3.0.0*  
*📅 Utolsó frissítés: 2025. november 5.*
