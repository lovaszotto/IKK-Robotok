@echo off
REM =====================================================
REM  TELEPITO v3.0
REM =====================================================
setlocal EnableDelayedExpansion


set "CURDIR=%CD%"
echo [INFO] Alapértelmezett telepítési konyvtár: %CURDIR%

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
        exit  1
    )
    echo Virtualis kornyezet sikeresen letrehozva.
) else (
    echo Virtualis kornyezet mar letezik.
)
echo.

REM Virtualis kornyezet aktivalasa es csomagok telepitese
echo szükséges csomagok telepitese...
.venv\Scripts\pip.exe install -r requirements.txt

if errorlevel 1 (
    echo HIBA: Csomagok telepitese sikertelen!
    pause
    exit  1
)

echo.
echo =========================================
echo TELEPITES SIKERES!
echo Telepitesi hely: %CURDIR%
exit 0


