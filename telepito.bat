@echo off
REM =====================================================
REM  IKK04 DOKUMENTUM WEB-ELLENORZO RENDSZER - TELEPITO v3.0
REM  Robot Framework alapu automatizált dokumentum
REM  formálellenőrzés és WEB alkalmazás tesztelés
REM =====================================================
setlocal EnableDelayedExpansion

echo.
echo =====================================================
echo   IKK04 DOKUMENTUM WEB-ELLENORZO RENDSZER TELEPITO v3.0
echo   
echo   Funkcionalitas:
echo   - Automatikus DOCX formai ellenorzes (23 kategoria)
echo   - WEB alkalmazas automatizalt tesztelese
echo   - Selenium WebDriver integralas
echo   - Robot Framework tesztvezerlese  
echo   - Excel export es riportkeszites
echo   - Flask webes interfesz
echo   - Media ellenorzes (kepek, videok)
echo =====================================================
echo.

REM Telepitesi konyvtar bekeres
REM Automatikus telepitesi konyvtar beallitasa: az aktualis folder nevében a DownloadedRobots kifejezést InstalledRobots-ra cseréljük
set "CURDIR=%CD%"
echo [INFO] Alapértelmezett telepítési konyvtár: %TARGET_DIR%


REM Ellenorizzuk a Python megletet es verziot
echo Python verzio ellenorzese...
python --version >nul 2>&1
if errorlevel 1 (
    echo HIBA: Python nincs telepitve vagy nem elerheto a PATH-ban!
    echo.
    echo Megoldasok:
    echo 1. Telepitse a Python 3.8+ verzioit a python.org oldalrol
    echo 2. Vagy hasznaja az Install\python-3.13.7-amd64.exe fajlt
    echo 3. Adja hoza a Python-t a rendszer PATH valtozojához
    echo.
    pause
    exit /b 1
)

echo Python verzio:
python --version




REM Virtualis kornyezet letrehozasa
echo Virtualis kornyezet letrehozasa...
if not exist ".venv" (
    python -m venv .venv
    if errorlevel 1 (
        echo HIBA: Virtualis kornyezet letrehozasa sikertelen!
        pause
        exit /b 1
    )
    echo Virtualis kornyezet sikeresen letrehozva.
) else (
    echo Virtualis kornyezet mar letezik.
)
echo.

REM Virtualis kornyezet aktivalasa es csomagok telepitese
echo Csomagok telepitese...
REM .venv\Scripts\activate (nem szükséges, pip elérési út miatt)
.venv\Scripts\pip.exe install --upgrade pip
.venv\Scripts\pip.exe install robotframework
.venv\Scripts\pip.exe install robotframework-seleniumlibrary
.venv\Scripts\pip.exe install robotframework-databaselibrary
.venv\Scripts\pip.exe install robotframework-requests
.venv\Scripts\pip.exe install openpyxl
.venv\Scripts\pip.exe install python-docx
.venv\Scripts\pip.exe install pywin32
.venv\Scripts\pip.exe install lxml
.venv\Scripts\pip.exe install flask
.venv\Scripts\pip.exe install langdetect
.venv\Scripts\pip.exe install pillow
.venv\Scripts\pip.exe install requests

if errorlevel 1 (
    echo HIBA: Csomagok telepitese sikertelen!
    pause
    exit /b 1
)

