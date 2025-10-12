@echo off
REM =========================================
REM  FORMAI ELLENORZO RENDSZER FUTTATAS
REM =========================================
echo.
echo =========================================
echo   FORMAI ELLENORZO RENDSZER
echo   Main robot futtatas
echo =========================================
echo.

REM Ellenorizzuk a virtualis kornyezet megletet
if not exist "rf_env\Scripts\robot.exe" (
    echo HIBA: Virtualis kornyezet nem talalhato!
    echo Futtassa eloszor a telepito.bat fajlt!
    pause
    exit /b 1
)

echo Konfiguracio ellenorzese...
if not exist "Duplikacio.config" (
    echo HIBA: Duplikacio.config fajl nem talalhato!
    echo Ellenorizze a konfiguracios fajlt!
    pause
    exit /b 1
)

REM Results konyvtar letrehozasa ha nem letezik
if not exist "results" (
    echo Results konyvtar letrehozasa...
    mkdir "results"
)

echo Robot Framework teszt futtatasa...
rf_env\Scripts\robot.exe --output NONE --log NONE --report NONE PLG-00-main.robot

REM Olvassuk ki a Duplikacio.config-bol az output_folder erteket
set "OUT_DIR="
for /f "usebackq tokens=1,* delims==" %%A in ("Duplikacio.config") do (
    if /I "%%A"=="output_folder" set "OUT_DIR=%%B"
)

REM Ha nincs explicit kimeneti mappa a configban, essunk vissza a .\results mappara
if not defined OUT_DIR set "OUT_DIR=%cd%\results"

REM Keressuk meg a legutobb keszult RunLog_*.log fajlt az OUT_DIR-ben
set "LAST_LOG="
if exist "%OUT_DIR%\RunLog_*.log" (
    for /f "delims=" %%F in ('dir /b /a:-d /o:-d "%OUT_DIR%\RunLog_*.log" 2^>nul') do if not defined LAST_LOG set "LAST_LOG=%%F"
)

if errorlevel 1 (
    echo HIBA: A teszt futtatasa sikertelen!
    if defined LAST_LOG (
        echo Reszletek: "%OUT_DIR%\%LAST_LOG%"
    ) else (
        echo Ellenorizze a konfiguralt kimeneti konyvtarat: "%OUT_DIR%"
    )
) else (
    echo.
    echo =========================================
    echo TESZT SIKERESEN BEFEJEZODOTT!
    echo.
    echo Eredmenyek:
    if defined LAST_LOG (
        echo - Egyedi log: "%OUT_DIR%\%LAST_LOG%"
    ) else (
        echo - Egyedi log: "%OUT_DIR%\RunLog_YYYYMMDD_HHMMSS.log" (fajlnev idoponttol fuggo)
    )
    echo - Excel jelentések: "%OUT_DIR%" (prefix a Duplikacio.config 'excel_prefix' szerint)
    echo Megjegyzes: A Robot Framework alap log.html/report.html fajlok ki vannak kapcsolva ebben a futtatasi modban.
    echo =========================================
)
pause
