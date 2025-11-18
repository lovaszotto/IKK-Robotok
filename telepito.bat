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
set "TARGET_DIR=%CURDIR%"
echo [INFO] Telepitesi konyvtar: %TARGET_DIR%


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


echo [2/4] pip csomag kezelo ellenorzese...
python -m pip --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] pip csomag kezelo nem elerheto!
    echo Probalja meg ujratelepiteni a Python-t pip tamogatassal.
    pause
    exit /b 1
)
echo [SUCCESS] pip csomag kezelo elerheto




echo.
echo RENDSZERKOVETELMENY ELLENORZESE BEFEJEZVE
echo.


echo PYTHON KORNYEZET ES FUGGOSEGEK TELEPITESE
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
if not exist ".venv" (
    echo [INFO] Virtualis kornyezet letrehozasa - .venv...
    python -m venv .venv
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



REM Fuggosegek telepitese
echo.
echo Robot Framework es fuggosegek telepitese...
echo [INFO] Ez eltarthat nehany percig, kerem varjon...

echo [1/6] Robot Framework telepitese...
.venv\Scripts\pip.exe install robotframework==7.3.2 --quiet
if errorlevel 1 (
    echo [ERROR] Robot Framework telepitese sikertelen!
    goto :pip_error
)

echo [2/6] Database Library telepitese...
.venv\Scripts\pip.exe install robotframework-databaselibrary==2.3.2 --quiet
if errorlevel 1 (
    echo [ERROR] Database Library telepitese sikertelen!
    goto :pip_error
)

echo [3/6] OpenPyXL Excel telepitese...
.venv\Scripts\pip.exe install openpyxl==3.1.5 --quiet
if errorlevel 1 (
    echo [ERROR] OpenPyXL telepitese sikertelen!
    goto :pip_error
)

echo [4/6] Python-docx telepitese...
.venv\Scripts\pip.exe install python-docx==1.2.0 --quiet
if errorlevel 1 (
    echo [ERROR] Python-docx telepitese sikertelen!
    goto :pip_error
)

echo [5/6] PyWin32 Windows telepitese...
.venv\Scripts\pip.exe install pywin32==311 --quiet
if errorlevel 1 (
    echo [ERROR] PyWin32 telepitese sikertelen!
    goto :pip_error
)

echo [6/6] RobotLibCore telepitese...
.venv\Scripts\pip.exe install robotframework-pythonlibcore==4.4.1 --quiet
if errorlevel 1 (
    echo [WARN] RobotLibCore telepites reszben sikertelen, folyatatas...
)

echo.
echo PYTHON CSOMAGOK TELEPITESE BEFEJEZVE
goto :continue_install

:pip_error
echo.   

:continue_install
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

echo A rendszer keszen all a hasznalatra!
echo.
echo KOVETKEZO LEPESEK:
echo 1. Menjen a %TARGET_DIR% konyvtarba
echo 2. Szerkessze a Duplikacio.config fajlt
echo 3. Helyezze be a vizsgalando DOCX fajlokat
echo 4. Futtassa a start.bat fajlt
echo.
echo Tovabbi segitsegert olvassa el a dokumentaciot!


