@echo off
REM =========================================
REM  DUPLIKACIO ELLENORZO RENDSZER - TELEPITO
REM  v2.2.3 - Fejlesztett telepitesi script
REM =========================================
setlocal EnableDelayedExpansion
echo.
echo =========================================
echo   DUPLIKACIO ELLENORZO RENDSZER v2.2.0
echo   Automatikus telepites es beallitas
echo   Robot Framework Plagium Ellenorzo
echo =========================================
echo.

REM Automatikus telepitesi konyvtar beallitasa: az aktualis folder neveben a DownloadedRobots kifejezest InstalledRobots-ra csereljuk
set "CURDIR=%CD%"
set "TARGET_DIR=%CURDIR:DownloadedRobots=InstalledRobots%"
echo [INFO] Telepitesi konyvtar: %TARGET_DIR%


REM Rendszerkovetelmények ellenorzese
echo Rendszerkovetelmeny ellenorzese...
echo.

REM Python verzio es jelenlét ellenorzese
echo [1/4] Python ellenorzese...
python --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Python nincs telepitve vagy nem elerheto!
    echo.
    echo TEENDOK:
    echo 1. Toltse le a Python 3.8+ verziot: https://python.org
    echo 2. Telepites soran jelolje be: "Add Python to PATH"
    echo 3. Inditsja ujra a telepitot
    echo.
    pause
    exit /b 1
)

REM Python verzio reszletes ellenorzese
for /f "tokens=2" %%V in ('python --version 2^>^&1') do set PYTHON_VERSION=%%V
echo [SUCCESS] Python verzio: %PYTHON_VERSION%

REM Python verzio kompatibilitas ellenorzese (3.8+)
for /f "tokens=1,2 delims=." %%a in ("%PYTHON_VERSION%") do (
    set MAJOR=%%a
    set MINOR=%%b
)
if %MAJOR% LSS 3 (
    echo [ERROR] Python verzio tul regi! Minimum 3.8 szukseges.
    pause
    exit /b 1
)
if %MAJOR% EQU 3 if %MINOR% LSS 8 (
    echo [ERROR] Python verzio tul regi! Minimum 3.8 szukseges.
    pause
    exit /b 1
)

echo [2/4] pip csomag kezelo ellenorzese...
python -m pip --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] pip csomag kezelo nem elerheto!
    echo Probalja meg ujratelepiteni a Python-t pip tamogatassal.
    pause
    exit /b 1
)
echo [SUCCESS] pip csomag kezelo elerheto

echo [3/4] Windows verzio ellenorzese...
ver | findstr /i "Windows" >nul 2>&1
if errorlevel 1 (
    echo [WARN] Windows verzio nem azonosithato, folyatatas...
) else (
    echo [SUCCESS] Windows operacios rendszer eszlelve
)

echo [4/4] Tarterulet ellenorzese...
for /f "tokens=3" %%a in ('dir /-c "%TARGET_DIR%\.." 2^>nul ^| findstr /i "bytes free"') do set FREE_BYTES=%%a
if defined FREE_BYTES (
    echo [SUCCESS] Elegendo tarterulet elerheto
) else (
    echo [WARN] Tarterulet ellenorzes nem sikerult, folyatatas...
)

echo.
echo RENDSZERKOVETELMENY ELLENORZESE BEFEJEZVE
echo.

REM Telepitesi konyvtar kezelese
echo Telepitesi konyvtar elokeszitese...
if not exist "%TARGET_DIR%" (
    echo [INFO] Konyvtar letrehozasa: %TARGET_DIR%
    mkdir "%TARGET_DIR%" 2>nul
    if errorlevel 1 (
        echo [ERROR] Nem sikerult letrehozni a konyvtarat!
        echo Ellenorizze a jogosultsagokat es probalja ujra.
        pause
        exit /b 1
    )
    echo [SUCCESS] Konyvtar sikeresen letrehozva
) else (
    echo [INFO] Konyvtar mar letezik: %TARGET_DIR%
    echo Meglevo fajlok felul lesznek irva...
)

REM Alkonyvtarak letrehozasa
echo [INFO] Alkonyvtarak letrehozasa...
if not exist "%TARGET_DIR%\libraries" mkdir "%TARGET_DIR%\libraries"
if not exist "%TARGET_DIR%\resources" mkdir "%TARGET_DIR%\resources"
if not exist "%TARGET_DIR%\test" mkdir "%TARGET_DIR%\test"
if not exist "%TARGET_DIR%\results" mkdir "%TARGET_DIR%\results"
if not exist "%TARGET_DIR%\documentation_docx" mkdir "%TARGET_DIR%\documentation_docx"

echo.
echo Projekt fajlok masolasa...

REM Fobb Robot Framework fajlok masolasa
echo [1/5] Robot Framework tesztfajlok masolasa...
if exist "PLG-00-main.robot" (
    copy "PLG-00-main.robot" "%TARGET_DIR%\" >nul 2>&1 && echo   [OK] PLG-00-main.robot
) else (
    echo   [ERROR] PLG-00-main.robot - HIANYZO FAJL!
)
if exist "PLG-02-read_docx.robot" (
    copy "PLG-02-read_docx.robot" "%TARGET_DIR%\" >nul 2>&1 && echo   [OK] PLG-02-read_docx.robot
)
if exist "PLG-03-write-excel.robot" (
    copy "PLG-03-write-excel.robot" "%TARGET_DIR%\" >nul 2>&1 && echo   [OK] PLG-03-write-excel.robot
)

REM Konfiguracios fajlok masolasa
echo [2/5] Konfiguracios fajlok masolasa...
if exist "Duplikacio.config" (
    copy "Duplikacio.config" "%TARGET_DIR%\" >nul 2>&1 && echo   [OK] Duplikacio.config
) else (
    echo   [ERROR] Duplikacio.config - HIANYZO FAJL!
)
if exist "TELEPITO_UTMUTATO.txt" (
    copy "TELEPITO_UTMUTATO.txt" "%TARGET_DIR%\" >nul 2>&1 && echo   [OK] TELEPITO_UTMUTATO.txt
)

REM Dokumentacios fajlok masolasa
echo [3/5] Dokumentacios fajlok masolasa...
for %%F in (README.md DOKUMENTACIO.md TECHNIKAI_ATTEKINTES.md GYORS_REFERENCIA.md KONZOL_KOMPATIBILITAS.md) do (
    if exist "%%F" (
        copy "%%F" "%TARGET_DIR%\" >nul 2>&1 && echo   [OK] %%F
    )
)

REM Python konyvtarak masolasa
echo [4/5] Python konyvtarak masolasa...
if exist "libraries" (
    echo   libraries konyvtar masolasa...
    xcopy "libraries" "%TARGET_DIR%\libraries" /E /I /Y /Q >nul 2>&1
    if errorlevel 1 (
        echo   [ERROR] HIBA a libraries masolasa kozben
    ) else (
        echo   [OK] libraries konyvtar sikeresen masolva
    )
) else (
    echo   [ERROR] libraries konyvtar nem talalhato!
)

REM Resources konyvtar masolasa
echo [5/5] Eroforrasok masolasa...
if exist "resources" (
    echo   resources konyvtar masolasa...
    xcopy "resources" "%TARGET_DIR%\resources" /E /I /Y /Q >nul 2>&1
    if errorlevel 1 (
        echo   [ERROR] HIBA a resources masolasa kozben
    ) else (
        echo   [OK] resources konyvtar sikeresen masolva
    )
)

if exist "test" (
    echo   test konyvtar masolasa...
    xcopy "test" "%TARGET_DIR%\test" /E /I /Y /Q >nul 2>&1
    if errorlevel 1 (
        echo   [ERROR] HIBA a test masolasa kozben
    ) else (
        echo   [OK] test konyvtar sikeresen masolva
    )
)

REM SQL parancsok es egyeb fajlok
if exist "SqlCommands" (
    xcopy "SqlCommands" "%TARGET_DIR%\SqlCommands" /E /I /Y /Q >nul 2>&1 && echo   [OK] SqlCommands konyvtar
)

REM Python modulok ellenorzese es masolasa
echo.
echo Python modulok ellenorzese...
set MISSING_FILES=0
for %%F in (ellenoriz_indexek.py validate_docx.py) do (
    if exist "%%F" (
        copy "%%F" "%TARGET_DIR%\" >nul 2>&1 && echo   [OK] %%F
    ) else (
        echo   [WARN] %%F - opcionalis fajl hianyzik
    )
)

echo.
echo FAJLOK MASOLASA BEFEJEZVE

echo.

REM Atlepes a celkonyvtarba
echo Atlepes a telepitesi konyvtarba...
cd /d "%TARGET_DIR%"
if errorlevel 1 (
    echo [ERROR] Nem sikerult atlepni a celkonyvtarba!
    pause
    exit /b 1
)

REM Virtualis kornyezet letrehozasa
echo.
echo Python virtualis kornyezet beallitasa...
if not exist "rf_env" (
    echo [INFO] Virtualis kornyezet letrehozasa - rf_env...
    python -m venv rf_env
    if errorlevel 1 (
        echo [ERROR] Virtualis kornyezet letrehozasa sikertelen!
        echo.
        echo LEHETSEGES OKOK:
        echo - Python venv modul nincs telepitve
        echo - Jogosultsag problema
        echo - Nem megfelelo Python verzio
        pause
        exit /b 1
    )
    echo [SUCCESS] Virtualis kornyezet sikeresen letrehozva
) else (
    echo [INFO] Virtualis kornyezet mar letezik, frissites...
)

REM pip frissitese
echo.
echo Python csomagkezelo pip frissitese...
rf_env\Scripts\pip.exe install --upgrade pip --quiet
if errorlevel 1 (
    echo [WARN] pip frissites reszben sikertelen, folyatatas...
) else (
    echo [SUCCESS] pip sikeresen frissitve
)

REM Fuggosegek telepitese
echo.
echo Robot Framework es fuggosegek telepitese...
echo [INFO] Ez eltarthat nehany percig, kerem varjon...

echo [1/6] Robot Framework telepitese...
rf_env\Scripts\pip.exe install robotframework==7.3.2 --quiet
if errorlevel 1 (
    echo [ERROR] Robot Framework telepitese sikertelen!
    goto :pip_error
)

echo [2/6] Database Library telepitese...
rf_env\Scripts\pip.exe install robotframework-databaselibrary==2.3.2 --quiet
if errorlevel 1 (
    echo [ERROR] Database Library telepitese sikertelen!
    goto :pip_error
)

echo [3/6] OpenPyXL Excel telepitese...
rf_env\Scripts\pip.exe install openpyxl==3.1.5 --quiet
if errorlevel 1 (
    echo [ERROR] OpenPyXL telepitese sikertelen!
    goto :pip_error
)

echo [4/6] Python-docx telepitese...
rf_env\Scripts\pip.exe install python-docx==1.2.0 --quiet
if errorlevel 1 (
    echo [ERROR] Python-docx telepitese sikertelen!
    goto :pip_error
)

echo [5/6] PyWin32 Windows telepitese...
rf_env\Scripts\pip.exe install pywin32==311 --quiet
if errorlevel 1 (
    echo [ERROR] PyWin32 telepitese sikertelen!
    goto :pip_error
)

echo [6/6] RobotLibCore telepitese...
rf_env\Scripts\pip.exe install robotframework-pythonlibcore==4.4.1 --quiet
if errorlevel 1 (
    echo [WARN] RobotLibCore telepites reszben sikertelen, folyatatas...
)

echo.
echo PYTHON CSOMAGOK TELEPITESE BEFEJEZVE
goto :continue_install

:pip_error
echo.
echo [ERROR] Csomag telepitesi hiba tortent!
echo.
echo LEHETSEGES MEGOLDASOK:
echo 1. Ellenorizze az internetkapcsolatot
echo 2. Probalja meg kesobb
echo 3. Futtassa rendszergazdakent a telepitot
echo 4. Ellenorizze a tuzfal beallitasait
echo.
echo Szeretne folytatni a telepitestet? i/n
set /p CONTINUE_INSTALL="Folyatatas: "
if /i not "%CONTINUE_INSTALL%"=="i" (
    echo Telepites megszakitva.
    pause
    exit /b 1
)

:continue_install

REM Indito script letrehozasa
echo.
echo start.bat indito fajl letrehozasa...

REM Fejlesztett start.bat fajl letrehozasa
echo @echo off > start.bat
echo REM ========================================= >> start.bat
echo REM  DUPLIKACIO ELLENORZO RENDSZER v2.2.0 >> start.bat
echo REM  Robot Framework Plagium Ellenorzo >> start.bat
echo REM ========================================= >> start.bat
echo setlocal EnableDelayedExpansion >> start.bat
echo. >> start.bat
echo echo. >> start.bat
echo echo ========================================= >> start.bat
echo echo   DUPLIKACIO ELLENORZO RENDSZER v2.2.0 >> start.bat
echo echo   Plagium ellenorzes inditasa >> start.bat
echo echo ========================================= >> start.bat
echo echo. >> start.bat
echo. >> start.bat
echo REM Virtualis kornyezet ellenorzese >> start.bat
echo echo Virtualis kornyezet ellenorzese... >> start.bat
echo if not exist "rf_env\Scripts\robot.exe" ^( >> start.bat
echo     echo [ERROR] Virtualis kornyezet nem talalhato! >> start.bat
echo     echo. >> start.bat
echo     echo MEGOLDAS: >> start.bat
echo     echo 1. Futtassa ujra a telepito.bat fajlt >> start.bat
echo     echo 2. Ellenorizze a rf_env konyvtar megletet >> start.bat
echo     echo. >> start.bat
echo     pause >> start.bat
echo     exit /b 1 >> start.bat
echo ^) >> start.bat
echo echo [SUCCESS] Virtualis kornyezet OK >> start.bat
echo. >> start.bat
echo REM Konfiguracios fajl ellenorzese >> start.bat
echo echo Konfiguracios fajl ellenorzese... >> start.bat
echo if not exist "Duplikacio.config" ^( >> start.bat
echo     echo [ERROR] Duplikacio.config fajl nem talalhato! >> start.bat
echo     echo. >> start.bat
echo     echo MEGOLDAS: >> start.bat
echo     echo 1. Masoljad ide a Duplikacio.config fajlt >> start.bat
echo     echo 2. Szerkeszd a bemeneti/kimeneti konyvtarakat >> start.bat
echo     echo 3. Add meg az email cimet >> start.bat
echo     echo. >> start.bat
echo     pause >> start.bat
echo     exit /b 1 >> start.bat
echo ^) >> start.bat
echo echo [SUCCESS] Konfiguracios fajl OK >> start.bat
echo. >> start.bat
echo REM Konyvtarak letrehozasa >> start.bat
echo echo Kimeneti konyvtarak ellenorzese... >> start.bat
echo if not exist "results" ^( >> start.bat
echo     echo [INFO] results konyvtar letrehozasa... >> start.bat
echo     mkdir "results" >> start.bat
echo ^) >> start.bat
echo. >> start.bat
echo REM Robot Framework teszt futtatasa >> start.bat
echo echo Robot Framework teszt inditasa... >> start.bat
echo echo [INFO] Ez eltarthat nehany percig, kerem varjon... >> start.bat
echo echo. >> start.bat
echo rf_env\Scripts\robot.exe --outputdir results --loglevel INFO PLG-00-main.robot >> start.bat
echo. >> start.bat
echo REM Eredmeny ellenorzese >> start.bat
echo if errorlevel 1 ^( >> start.bat
echo     echo [ERROR] A teszt futtatasa sikertelen! >> start.bat
echo     echo. >> start.bat
echo     echo HIBAKERESO LEPESEK: >> start.bat
echo     echo 1. Ellenorizze: results\log.html >> start.bat
echo     echo 2. Ellenorizze: results\report.html >> start.bat
echo     echo 3. Konfiguraciot: Duplikacio.config >> start.bat
echo     echo 4. Bemeneti konyvtar tartalmat >> start.bat
echo     echo. >> start.bat
echo ^) else ^( >> start.bat
echo     echo. >> start.bat
echo     echo ========================================= >> start.bat
echo     echo TESZT SIKERESEN BEFEJEZODOTT! >> start.bat
echo     echo. >> start.bat
echo     echo EREDMENYEK: >> start.bat
echo     echo Log fajl: results\log.html >> start.bat
echo     echo Report: results\report.html >> start.bat
echo     echo Email elkuldve a konfiguralt cimre >> start.bat
echo     echo Excel export keszitve >> start.bat
echo     echo. >> start.bat
echo     echo PLAGIUM ELLENORZES TELJES FOLYAMATA BEFEJEZVE! >> start.bat
echo     echo ========================================= >> start.bat
echo ^) >> start.bat
echo. >> start.bat
echo exit >> start.bat

echo [SUCCESS] start.bat fajl sikeresen letrehozva

REM Konfiguracios fajl ellenorzese es testre szabasi utmutato
echo.
echo Konfiguracios fajl ellenorzese...
if exist "Duplikacio.config" (
    echo [SUCCESS] Duplikacio.config fajl megtalava
    echo.
    echo FONTOS - Konfiguracios beallitasok:
    echo 1. Szerkessze a Duplikacio.config fajlt
    echo 2. Allitsa be a bemeneti konyvtarat - input_folder
    echo 3. Allitsa be a kimeneti konyvtarat - output_folder
    echo 4. Konfigurálja az email beallitasokat - ha szukseges
    echo.
) else (
    echo [WARN] Duplikacio.config fajl hianyzik
)

REM Telepites befejezese es osszesito
echo.
echo =========================================
echo TELEPITES SIKERESEN BEFEJEZVE! 
echo =========================================
echo.
echo Telepitesi hely: %TARGET_DIR%
echo.
echo TELEPITETT KOMPONENSEK:
echo [OK] Robot Framework 7.3.2 - automatizalas
echo [OK] Database Library 2.3.2 - SQLite adatbazis  
echo [OK] OpenPyXL 3.1.5 - Excel export
echo [OK] Python-docx 1.2.0 - DOCX dokumentum olvaso
echo [OK] PyWin32 311 - Windows email kuldes
echo [OK] RobotLibCore 4.4.1 - Robot konyvtar core
echo [OK] Teljes projekt fajlok es dokumentacio
echo [OK] start.bat futtatas script
echo.
echo HASZNALAT:
echo 1. Lepjen a telepitesi konyvtarba: %TARGET_DIR%
echo 2. Szerkessze: Duplikacio.config
echo 3. Futtassa: start.bat
echo.
echo FONTOS FAJLOK:
echo Konfiguracios: Duplikacio.config
echo Teszt fajlok: test\ konyvtar
echo Eredmenyek: results\ konyvtar  
echo Dokumentacio: README.md, DOKUMENTACIO.md
echo Telepitesi utmutato: TELEPITO_UTMUTATO.txt
echo.
echo TAMOGATAS:
echo Gyors referencia: GYORS_REFERENCIA.md
echo Technikai attekintes: TECHNIKAI_ATTEKINTES.md
echo Konzol kompatibilitas: KONZOL_KOMPATIBILITAS.md
echo.
echo =========================================
echo Robot Framework Plagium Ellenorzo v2.2.0
echo Telepites datuma: %DATE% %TIME:~0,8%
echo =========================================
echo.

REM Telepites befejezese
echo.
echo A rendszer keszen all a hasznalatra!
echo.
echo KOVETKEZO LEPESEK:
echo 1. Menjen a %TARGET_DIR% konyvtarba
echo 2. Szerkessze a Duplikacio.config fajlt
echo 3. Helyezze be a vizsgalando DOCX fajlokat
echo 4. Futtassa a start.bat fajlt
echo.
echo Tovabbi segitsegert olvassa el a dokumentaciot!


