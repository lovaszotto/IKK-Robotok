# DuplikacioEllenorzesRobot
# 🤖 Robot Framework Plágium Ellenőrző Rendszer

[![Robot Framework](https://img.shields.io/badge/Robot- `status`: Kategorizálás (Rendben/Gyanús/Másolt)
- `file_name`: Dokumentum neve
- `max_ismetelt_karakterszam`: Legnagyobb redundancia
- `record_date`: Feldolgozás dátuma

### 🚫 Skip funkciók
- `hashValue`: MD5 hash kihagyandó szövegekhez (PRIMARY KEY)
- `line_content`: Átugrandó szöveg tartalom

## ⚙️ Konfigurációreen.svg)](https://robotframework.org/)
[![Python](https://img.shields.io/badge/Python-3.8%2B-blue.svg)](https://www.python.org/)
[![SQLite](https://img.shields.io/badge/SQLite-3.x-lightgrey.svg)](https://sqlite.org/)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

> 🔍 **Automatizált DOCX dokumentum plágium ellenőrzés** hash-alapú algoritmussal, Excel jelentéskészítéssel és automatikus email értesítéssel.

## ✨ Főbb funkciók

- 🔍 **Automatikus plágium detektálás** SHA-256 hash algoritmussal
- 📊 **Excel jelentések** színkódolt státusz kategóriákkal  
- 📧 **Automatikus email küldés** Outlook COM integrációval
- 🗄️ **SQLite adatbázis** teljes előzmény nyilvántartással
- 🎯 **Háromszintű kategorizálás**: Rendben / Gyanús / Másolt
- 🔄 **Batch feldolgozás** több dokumentum egyidejű kezelésére
- ⏭️ **Intelligens skip funkció** konfigurálható szövegszűréssel
- 🚫 **Duplikált tartalom kizárása** skip funkciókkal

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
# Duplikacio.config szerkesztése
email=your-email@company.com
input_folder=C:\Documents\ToCheck
output_folder=C:\Reports
```

```ini
# DuplikacioSkip.config - átugrandó szövegek
igaz vagy hamis a következő állítás?
válaszd ki a helyes megoldásokat!
válaszd ki a helyes választ!
```

### 3️⃣ Futtatás
```powershell
# Robot Framework teszt futtatása
rf_env\Scripts\robot.exe PLG-00-main.robot

# Vagy batch fájlon keresztül
start.bat
```

## 📊 Eredmény példa

### 📈 Konsol kimenet
```
=== DOCX FÁJLOK KERESÉSE ===
Talált DOCX fájlok száma: 6

🏆 VÉGSŐ ÖSSZESÍTÉS:
📊 Összes dokumentum: 45
🟢 Rendben: 41 dokumentum (91.1%)
🟡 Gyanús: 2 dokumentum (4.4%)  
🔴 Másolt: 2 dokumentum (4.4%)

✅ Excel fájl: plagium_eredmenyek_20250825_040223.xlsx
🎯 PLAGIUM ELLENORZÉS TELJES FOLYAMATA BEFEJEZVE! ✅
```

### 📧 Automatikus email
- **HTML formátumú jelentés** színkódolt státuszokkal
- **Excel melléklet** részletes adatokkal
- **Összesítő statisztikák** százalékos megoszlással

## 🏗️ Rendszer architektúra

```
📁 PlagiumEllenorzes/
├── 🤖 PLG-00-main.robot          # Fő Robot Framework teszt
├── ⚙️ Duplikacio.config          # Fő konfigurációs fájl
├── 🚫 DuplikacioSkip.config      # Skip szabályok konfigurációja
├── 📚 libraries/                 # Python modulok
│   ├── 🐍 DocxReader.py          # DOCX olvasó library
│   ├── 📧 send_email.py          # Email küldő rendszer
│   ├── 📊 excel_export_simple.py # Excel export engine
│   └── ⚙️ get_config.py          # Konfiguráció betöltő
├── 📂 resources/                 # Robot Framework erőforrások
│   ├── 🔑 keywords.robot         # Kulcsszó definíciók
│   └── 🔢 variables.robot        # Változó definíciók
├── 🗃️ test_database.db           # SQLite adatbázis
└── 🐍 rf_env/                    # Python virtuális környezet
```

## 🔍 Plágium algoritmus

### Hash-alapú összehasonlítás
1. **📄 DOCX beolvasás**: Szöveges tartalom kinyerése
2. **� Skip ellenőrzés**: DuplikacioSkip.config alapján szűrés
3. **🔐 MD5 hash**: Minden sorhoz egyedi hash generálás
4. **🔍 Összehasonlítás**: Hash értékek összevetése adatbázisban
5. **📊 Kategorizálás**: Redundancia hossz alapján értékelés

### Skip funkcionalitás
- **🚫 DuplikacioSkip.config**: Automatikusan kihagyandó szövegek
- **📝 Hash alapú**: MD5 hash generálás minden skip szabályhoz
- **🔄 Startup betöltés**: skip funkciók automatikus betöltése
- **⚡ Gyors szűrés**: Hash összehasonlítás alapján azonnali kihagyás

### Kategorizálási szabályok
- 🟢 **Rendben**: < 300 karakter redundancia
- 🟡 **Gyanús**: 300-1200 karakter redundancia
- 🔴 **Másolt**: > 1200 karakter redundancia

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
robotframework==6.1.1
robotframework-databaselibrary==1.2.4
python-docx==0.8.11
openpyxl==3.1.2
pywin32==306
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
notepad Duplikacio.config       # Email és könyvtárak beállítása
notepad DuplikacioSkip.config   # Skip szabályok konfigurálása
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

## ▶️ Futtatás és logok (aktuális mód)

Ebben a projektben a teljes folyamat egy közös Robot Framework suite-ból fut (PLG-00-main.robot), és a beépített Robot logok le vannak tiltva. Helyettük egy egyedi, időbélyeggel ellátott naplófájl készül a konfigurált kimeneti mappába.

### Hogyan futtasd

- PowerShell-ből (aktív virtuális környezet mellett):
	- rf_env\Scripts\activate; rf_env\Scripts\robot.exe --output NONE --log NONE --report NONE PLG-00-main.robot
- Vagy a mellékelt batch fájllal:
	- start.bat

### Hol találom a logot?

- A Duplikacio.config fájl `output_folder` beállítása határozza meg a kimeneti mappát.
- Futáskor ide kerül egy fájl: `RunLog_YYYYMMDD_HHMMSS.log` (példa: `RunLog_20250922_101530.log`).
- Ha a `start.bat`-ot használod, a futás végén kiírja ennek a pontos elérési útját.

Megjegyzés: A Robot Framework alapértelmezett `log.html` és `report.html` fájljai ebben a futtatási módban szándékosan ki vannak kapcsolva.

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

### v2.2.0 (2025-09-22)
- ✅ **ÚJ**: DuplikacioSkip.config támogatás hozzáadva
- ✅ **ÚJ**: skipHashCodes adatbázis tábla automatikus létrehozása
- ✅ **ÚJ**: MD5 hash alapú intelligens szövegszűrés
- ✅ **JAVÍTÁS**: Startup-kor automatikus skip szabályok betöltése
- ✅ **FEJLESZTÉS**: Hash táblák ellenőrzése keyword kibővítése

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

*🤖 Robot Framework Duplikáció Ellenőrző v2.2.0*  
*📅 Utolsó frissítés: 2025. szeptember 22.*
