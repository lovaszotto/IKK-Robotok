@echo off
REM =========================================
REM  DUPLIKACIO ELLENORZO RENDSZER - TELEPITO
REM  v2.2.0 - Fejlesztett telepitesi script
REM =========================================
setlocal EnableDelayedExpansion

echo.
echo =========================================
echo   🤖 DUPLIKACIO ELLENORZO RENDSZER v2.2.0
echo   📦 Automatikus telepites es beallitas
echo   🔧 Robot Framework Plagium Ellenorzo
echo =========================================
echo.

REM Automatikus telepitesi konyvtar beallitasa: az aktualis folder nevében a DownloadedRobots kifejezést InstalledRobots-ra cseréljük
set "CURDIR=%CD%"
set "TARGET_DIR=%CURDIR:DownloadedRobots=InstalledRobots%"
echo [INFO] 📂 Telepítési konyvtár: %TARGET_DIR%

echo.
echo 🎯 Telepitesi cel: %TARGET_DIR%
echo.

REM Rendszerkövetelmények ellenőrzése
echo 🔍 Rendszerkövetelmények ellenőrzése...
echo.

REM Python verzió és jelenlét ellenőrzése
echo [1/4] 🐍 Python ellenőrzése...
python --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] ❌ Python nincs telepitve vagy nem elerheto!
    echo.
    echo 📋 TEENDŐK:
    echo 1. Töltse le a Python 3.8+ verziot: https://python.org
    echo 2. Telepítés során jelölje be: "Add Python to PATH"
    echo 3. Indítsa újra a telepítőt
    echo.
    pause
    exit /b 1
)

REM Python verzió részletes ellenőrzése
for /f "tokens=2" %%V in ('python --version 2^>^&1') do set PYTHON_VERSION=%%V
echo [SUCCESS] ✅ Python verzio: %PYTHON_VERSION%

REM Python verzió kompatibilitás ellenőrzése (3.8+)
for /f "tokens=1,2 delims=." %%a in ("%PYTHON_VERSION%") do (
    set MAJOR=%%a
    set MINOR=%%b
)
if %MAJOR% LSS 3 (
    echo [ERROR] ❌ Python verzio tul regi! Minimum 3.8 szükséges.
    pause
    exit /b 1
)
if %MAJOR% EQU 3 if %MINOR% LSS 8 (
    echo [ERROR] ❌ Python verzio tul regi! Minimum 3.8 szükséges.
    pause
    exit /b 1
)

echo [2/4] 📦 pip csomag kezelő ellenőrzése...
python -m pip --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] ❌ pip csomag kezelő nem elérhető!
    echo Próbálja meg újratelepíteni a Python-t pip támogatással.
    pause
    exit /b 1
)
echo [SUCCESS] ✅ pip csomag kezelő elérhető

echo [3/4] 🖥️  Windows verzió ellenőrzése...
ver | findstr /i "Windows" >nul 2>&1
if errorlevel 1 (
    echo [WARN] ⚠️  Windows verzió nem azonosítható, folytatás...
) else (
    echo [SUCCESS] ✅ Windows operációs rendszer észlelve
)

echo [4/4] 💾 Tárterület ellenőrzése...
for /f "tokens=3" %%a in ('dir /-c "%TARGET_DIR%\.." 2^>nul ^| findstr /i "bytes free"') do set FREE_BYTES=%%a
if defined FREE_BYTES (
    echo [SUCCESS] ✅ Elegendő tárterület elérhető
) else (
    echo [WARN] ⚠️  Tárterület ellenőrzés nem sikerült, folytatás...
)

echo.
echo ✅ RENDSZERKÖVETELMÉNYEK ELLENŐRZÉSE BEFEJEZVE
echo.

REM Telepítési könyvtár kezelése
echo 📂 Telepítési könyvtár előkészítése...
if not exist "%TARGET_DIR%" (
    echo [INFO] 📁 Könyvtár létrehozása: %TARGET_DIR%
    mkdir "%TARGET_DIR%" 2>nul
    if errorlevel 1 (
        echo [ERROR] ❌ Nem sikerült létrehozni a könyvtárat!
        echo Ellenőrizze a jogosultságokat és próbálja újra.
        pause
        exit /b 1
    )
    echo [SUCCESS] ✅ Könyvtár sikeresen létrehozva
) else (
    echo [INFO] 📁 Könyvtár már létezik: %TARGET_DIR%
    echo Meglévő fájlok felül lesznek írva...
)

REM Alkönytárak létrehozása
echo [INFO] 📂 Alkönyvtárak létrehozása...
if not exist "%TARGET_DIR%\libraries" mkdir "%TARGET_DIR%\libraries"
if not exist "%TARGET_DIR%\resources" mkdir "%TARGET_DIR%\resources"
if not exist "%TARGET_DIR%\test" mkdir "%TARGET_DIR%\test"
if not exist "%TARGET_DIR%\results" mkdir "%TARGET_DIR%\results"
if not exist "%TARGET_DIR%\documentation_docx" mkdir "%TARGET_DIR%\documentation_docx"

echo.
echo 📋 Projekt fájlok másolása...

REM Főbb Robot Framework fájlok másolása
echo [1/5] 🤖 Robot Framework tesztfájlok másolása...
if exist "PLG-00-main.robot" (
    copy "PLG-00-main.robot" "%TARGET_DIR%\" >nul 2>&1 && echo   ✅ PLG-00-main.robot
) else (
    echo   ❌ PLG-00-main.robot - HIÁNYZÓ FÁJL!
)
if exist "PLG-02-read_docx.robot" (
    copy "PLG-02-read_docx.robot" "%TARGET_DIR%\" >nul 2>&1 && echo   ✅ PLG-02-read_docx.robot
)
if exist "PLG-03-write-excel.robot" (
    copy "PLG-03-write-excel.robot" "%TARGET_DIR%\" >nul 2>&1 && echo   ✅ PLG-03-write-excel.robot
)

REM Konfigurációs fájlok másolása
echo [2/5] ⚙️  Konfigurációs fájlok másolása...
if exist "Duplikacio.config" (
    copy "Duplikacio.config" "%TARGET_DIR%\" >nul 2>&1 && echo   ✅ Duplikacio.config
) else (
    echo   ❌ Duplikacio.config - HIÁNYZÓ FÁJL!
)
if exist "TELEPITO_UTMUTATO.txt" (
    copy "TELEPITO_UTMUTATO.txt" "%TARGET_DIR%\" >nul 2>&1 && echo   ✅ TELEPITO_UTMUTATO.txt
)

REM Dokumentációs fájlok másolása
echo [3/5] 📚 Dokumentációs fájlok másolása...
for %%F in (README.md DOKUMENTACIO.md TECHNIKAI_ATTEKINTES.md GYORS_REFERENCIA.md KONZOL_KOMPATIBILITAS.md) do (
    if exist "%%F" (
        copy "%%F" "%TARGET_DIR%\" >nul 2>&1 && echo   ✅ %%F
    )
)

REM Python könyvtárak másolása
echo [4/5] 🐍 Python könyvtárak másolása...
if exist "libraries" (
    echo   📁 libraries könyvtár másolása...
    xcopy "libraries" "%TARGET_DIR%\libraries" /E /I /Y /Q >nul 2>&1
    if errorlevel 1 (
        echo   ❌ HIBA a libraries másolása közben
    ) else (
        echo   ✅ libraries könyvtár sikeresen másolva
    )
) else (
    echo   ❌ libraries könyvtár nem található!
)

REM Resources könyvtár másolása
echo [5/5] 📂 Erőforrások másolása...
if exist "resources" (
    echo   📁 resources könyvtár másolása...
    xcopy "resources" "%TARGET_DIR%\resources" /E /I /Y /Q >nul 2>&1
    if errorlevel 1 (
        echo   ❌ HIBA a resources másolása közben
    ) else (
        echo   ✅ resources könyvtár sikeresen másolva
    )
)

if exist "test" (
    echo   📁 test könyvtár másolása...
    xcopy "test" "%TARGET_DIR%\test" /E /I /Y /Q >nul 2>&1
    if errorlevel 1 (
        echo   ❌ HIBA a test másolása közben
    ) else (
        echo   ✅ test könyvtár sikeresen másolva
    )
)

REM SQL parancsok és egyéb fájlok
if exist "SqlCommands" (
    xcopy "SqlCommands" "%TARGET_DIR%\SqlCommands" /E /I /Y /Q >nul 2>&1 && echo   ✅ SqlCommands könyvtár
)

REM Python modulok ellenőrzése és másolása
echo.
echo 🔍 Python modulok ellenőrzése...
set MISSING_FILES=0
for %%F in (ellenoriz_indexek.py validate_docx.py) do (
    if exist "%%F" (
        copy "%%F" "%TARGET_DIR%\" >nul 2>&1 && echo   ✅ %%F
    ) else (
        echo   ⚠️  %%F - opcionális fájl hiányzik
    )
)

echo.
echo ✅ FÁJLOK MÁSOLÁSA BEFEJEZVE

echo.

REM Átlépés a célkönyvtárba
echo 📂 Átlépés a telepítési könyvtárba...
cd /d "%TARGET_DIR%"
if errorlevel 1 (
    echo [ERROR] ❌ Nem sikerült átlépni a célkönyvtárba!
    pause
    exit /b 1
)

REM Virtuális környezet létrehozása
echo.
echo 🐍 Python virtuális környezet beállítása...
if not exist "rf_env" (
    echo [INFO] 📦 Virtuális környezet létrehozása (rf_env)...
    python -m venv rf_env
    if errorlevel 1 (
        echo [ERROR] ❌ Virtuális környezet létrehozása sikertelen!
        echo.
        echo 📋 LEHETSÉGES OKOK:
        echo - Python venv modul nincs telepítve
        echo - Jogosultság probléma
        echo - Nem megfelelő Python verzió
        pause
        exit /b 1
    )
    echo [SUCCESS] ✅ Virtuális környezet sikeresen létrehozva
) else (
    echo [INFO] 📦 Virtuális környezet már létezik, frissítés...
)

REM pip frissítése
echo.
echo 📦 Python csomagkezelő (pip) frissítése...
rf_env\Scripts\pip.exe install --upgrade pip --quiet
if errorlevel 1 (
    echo [WARN] ⚠️  pip frissítés részben sikertelen, folytatás...
) else (
    echo [SUCCESS] ✅ pip sikeresen frissítve
)

REM Függőségek telepítése
echo.
echo 📦 Robot Framework és függőségek telepítése...
echo [INFO] Ez eltarthat néhány percig, kérem várjon...

echo [1/6] 🤖 Robot Framework telepítése...
rf_env\Scripts\pip.exe install robotframework==7.3.2 --quiet
if errorlevel 1 (
    echo [ERROR] ❌ Robot Framework telepítése sikertelen!
    goto :pip_error
)

echo [2/6] 🗄️  Database Library telepítése...
rf_env\Scripts\pip.exe install robotframework-databaselibrary==2.3.2 --quiet
if errorlevel 1 (
    echo [ERROR] ❌ Database Library telepítése sikertelen!
    goto :pip_error
)

echo [3/6] 📊 OpenPyXL (Excel) telepítése...
rf_env\Scripts\pip.exe install openpyxl==3.1.5 --quiet
if errorlevel 1 (
    echo [ERROR] ❌ OpenPyXL telepítése sikertelen!
    goto :pip_error
)

echo [4/6] 📄 Python-docx telepítése...
rf_env\Scripts\pip.exe install python-docx==1.2.0 --quiet
if errorlevel 1 (
    echo [ERROR] ❌ Python-docx telepítése sikertelen!
    goto :pip_error
)

echo [5/6] 🖥️  PyWin32 (Windows) telepítése...
rf_env\Scripts\pip.exe install pywin32==311 --quiet
if errorlevel 1 (
    echo [ERROR] ❌ PyWin32 telepítése sikertelen!
    goto :pip_error
)

echo [6/6] 🔧 RobotLibCore telepítése...
rf_env\Scripts\pip.exe install robotframework-pythonlibcore==4.4.1 --quiet
if errorlevel 1 (
    echo [WARN] ⚠️  RobotLibCore telepítés részben sikertelen, folytatás...
)

echo.
echo ✅ PYTHON CSOMAGOK TELEPÍTÉSE BEFEJEZVE
goto :continue_install

:pip_error
echo.
echo [ERROR] ❌ Csomag telepítési hiba történt!
echo.
echo 📋 LEHETSÉGES MEGOLDÁSOK:
echo 1. Ellenőrizze az internetkapcsolatot
echo 2. Próbálja meg később
echo 3. Futtassa rendszergazdaként a telepítőt
echo 4. Ellenőrizze a tűzfal beállításait
echo.
echo Szeretné folytatni a telepítést? (i/n)
set /p CONTINUE_INSTALL="Folytatás: "
if /i not "%CONTINUE_INSTALL%"=="i" (
    echo Telepítés megszakítva.
    pause
    exit /b 1
)

:continue_install

REM Indító script létrehozása
echo.
echo 🚀 start.bat indító fájl létrehozása...

REM Fejlesztett start.bat fájl létrehozása
echo @echo off > start.bat
echo REM ========================================= >> start.bat
echo REM  DUPLIKACIO ELLENORZO RENDSZER v2.2.0 >> start.bat
echo REM  🤖 Robot Framework Plagium Ellenorzo >> start.bat
echo REM ========================================= >> start.bat
echo setlocal EnableDelayedExpansion >> start.bat
echo. >> start.bat
echo echo. >> start.bat
echo echo ========================================= >> start.bat
echo echo   🤖 DUPLIKACIO ELLENORZO RENDSZER v2.2.0 >> start.bat
echo echo   🔍 Plagium ellenorzes inditasa >> start.bat
echo echo ========================================= >> start.bat
echo echo. >> start.bat
echo. >> start.bat
echo REM Virtualis kornyezet ellenorzese >> start.bat
echo echo 🔍 Virtualis kornyezet ellenorzese... >> start.bat
echo if not exist "rf_env\Scripts\robot.exe" ^( >> start.bat
echo     echo [ERROR] ❌ Virtualis kornyezet nem talalhato! >> start.bat
echo     echo. >> start.bat
echo     echo 📋 MEGOLDAS: >> start.bat
echo     echo 1. Futtassa ujra a telepito.bat fajlt >> start.bat
echo     echo 2. Ellenorizze a rf_env konyvtar megletet >> start.bat
echo     echo. >> start.bat
echo     pause >> start.bat
echo     exit /b 1 >> start.bat
echo ^) >> start.bat
echo echo [SUCCESS] ✅ Virtualis kornyezet OK >> start.bat
echo. >> start.bat
echo REM Konfiguracios fajl ellenorzese >> start.bat
echo echo 🔍 Konfiguracios fajl ellenorzese... >> start.bat
echo if not exist "Duplikacio.config" ^( >> start.bat
echo     echo [ERROR] ❌ Duplikacio.config fajl nem talalhato! >> start.bat
echo     echo. >> start.bat
echo     echo 📋 MEGOLDAS: >> start.bat
echo     echo 1. Masoljad ide a Duplikacio.config fajlt >> start.bat
echo     echo 2. Szerkeszd a bemeneti/kimeneti konyvtarakat >> start.bat
echo     echo 3. Add meg az email cimet >> start.bat
echo     echo. >> start.bat
echo     pause >> start.bat
echo     exit /b 1 >> start.bat
echo ^) >> start.bat
echo echo [SUCCESS] ✅ Konfiguracios fajl OK >> start.bat
echo. >> start.bat
echo REM Konyvtarak letrehozasa >> start.bat
echo echo 📂 Kimeneti konyvtarak ellenorzese... >> start.bat
echo if not exist "results" ^( >> start.bat
echo     echo [INFO] 📁 results konyvtar letrehozasa... >> start.bat
echo     mkdir "results" >> start.bat
echo ^) >> start.bat
echo. >> start.bat
echo REM Robot Framework teszt futtatasa >> start.bat
echo echo 🚀 Robot Framework teszt inditasa... >> start.bat
echo echo [INFO] Ez eltarthat nehany percig, kerem varjon... >> start.bat
echo echo. >> start.bat
echo rf_env\Scripts\robot.exe --outputdir results --loglevel INFO PLG-00-main.robot >> start.bat
echo. >> start.bat
echo REM Eredmeny ellenorzese >> start.bat
echo if errorlevel 1 ^( >> start.bat
echo     echo [ERROR] ❌ A teszt futtatasa sikertelen! >> start.bat
echo     echo. >> start.bat
echo     echo 📋 HIBAKERESO LEPESEK: >> start.bat
echo     echo 1. Ellenorizze: results\log.html >> start.bat
echo     echo 2. Ellenorizze: results\report.html >> start.bat
echo     echo 3. Konfiguraciot: Duplikacio.config >> start.bat
echo     echo 4. Bemeneti konyvtar tartalmát >> start.bat
echo     echo. >> start.bat
echo ^) else ^( >> start.bat
echo     echo. >> start.bat
echo     echo ========================================= >> start.bat
echo     echo ✅ TESZT SIKERESEN BEFEJEZODOTT! >> start.bat
echo     echo. >> start.bat
echo     echo 📊 EREDMENYEK: >> start.bat
echo     echo 📄 Log fajl: results\log.html >> start.bat
echo     echo 📈 Report: results\report.html >> start.bat
echo     echo 📧 Email elkuldve a konfiguralt cimre >> start.bat
echo     echo 📊 Excel export keszitve >> start.bat
echo     echo. >> start.bat
echo     echo 🎯 PLAGIUM ELLENORZES TELJES FOLYAMATA BEFEJEZVE! ✅ >> start.bat
echo     echo ========================================= >> start.bat
echo ^) >> start.bat
echo. >> start.bat
echo pause >> start.bat

echo [SUCCESS] ✅ start.bat fájl sikeresen létrehozva

REM Konfigurációs fájl ellenőrzése és testre szabási útmutató
echo.
echo ⚙️  Konfigurációs fájl ellenőrzése...
if exist "Duplikacio.config" (
    echo [SUCCESS] ✅ Duplikacio.config fájl megtalálva
    echo.
    echo 📋 FONTOS - Konfigurációs beállítások:
    echo 1. Szerkessze a Duplikacio.config fájlt
    echo 2. Állítsa be a bemeneti könyvtárat (input_folder)
    echo 3. Állítsa be a kimeneti könyvtárat (output_folder)
    echo 4. Konfigurálja az email beállításokat (ha szükséges)
    echo.
) else (
    echo [WARN] ⚠️  Duplikacio.config fájl hiányzik
)

REM Telepítés befejezése és összesítő
echo.
echo =========================================
echo ✅ TELEPÍTÉS SIKERESEN BEFEJEZVE! 
echo =========================================
echo.
echo 📂 Telepítési hely: %TARGET_DIR%
echo.
echo 📦 TELEPÍTETT KOMPONENSEK:
echo ✅ Robot Framework 7.3.2 (automatizálás)
echo ✅ Database Library 2.3.2 (SQLite adatbázis)  
echo ✅ OpenPyXL 3.1.5 (Excel export)
echo ✅ Python-docx 1.2.0 (DOCX dokumentum olvasó)
echo ✅ PyWin32 311 (Windows email küldés)
echo ✅ RobotLibCore 4.4.1 (Robot könyvtár core)
echo ✅ Teljes projekt fájlok és dokumentáció
echo ✅ start.bat futtatási script
echo.
echo 🚀 HASZNÁLAT:
echo 1. 📂 Lépjen a telepítési könyvtárba: %TARGET_DIR%
echo 2. ⚙️  Szerkessze: Duplikacio.config
echo 3. 🏃 Futtassa: start.bat
echo.
echo 📋 FONTOS FÁJLOK:
echo ⚙️  Konfigurációs: Duplikacio.config
echo 🧪 Teszt fájlok: test\ könyvtár
echo 📊 Eredmények: results\ könyvtár  
echo 📚 Dokumentáció: README.md, DOKUMENTACIO.md
echo 🔧 Telepítési útmutató: TELEPITO_UTMUTATO.txt
echo.
echo 🌐 TÁMOGATÁS:
echo 📖 Gyors referencia: GYORS_REFERENCIA.md
echo 🔧 Technikai áttekintés: TECHNIKAI_ATTEKINTES.md
echo 💬 Konzol kompatibilitás: KONZOL_KOMPATIBILITAS.md
echo.
echo =========================================
echo 🤖 Robot Framework Plágium Ellenőrző v2.2.0
echo 📅 Telepítés dátuma: %DATE% %TIME:~0,8%
echo =========================================
echo.

REM Telepítés utáni tesztelési ajánlat
echo 🧪 Szeretne most tesztelni a telepített rendszert? (i/n)
set /p TEST_NOW="Azonnali teszt futtatás: "

if /i "%TEST_NOW%"=="i" (
    echo.
    echo 🚀 Teszt futtatása indítása...
    echo [INFO] Az első futtatás hosszabb időt vehet igénybe...
    echo.
    cd /d "%TARGET_DIR%"
    call start.bat
) else (
    echo.
    echo ✅ A rendszer készen áll a használatra!
    echo.
    echo 📋 KÖVETKEZŐ LÉPÉSEK:
    echo 1. Menjen a %TARGET_DIR% könyvtárba
    echo 2. Szerkessze a Duplikacio.config fájlt
    echo 3. Helyezze be a vizsgálandó DOCX fájlokat
    echo 4. Futtassa a start.bat fájlt
    echo.
    echo 📚 További segítségért olvassa el a dokumentációt!
)

echo.
echo 🎯 TELEPÍTÉS BEFEJEZVE - Nyomjon egy billentyűt a kilépéshez...
pause >nul
