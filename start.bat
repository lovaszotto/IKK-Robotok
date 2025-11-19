@echo off
cd /d %~dp0
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
if not exist ".venv\Scripts\robot.exe" ( 
    echo HIBA: Virtualis kornyezet nem talalhato 
    echo Futtassa eloszor a telepito.bat fajlt 
    pause 
    exit /b 1 
) 
 
echo Konfiguracio ellenorzese... 
if not exist "IKK.config" ( 
    echo HIBA: IKK.config fajl nem talalhato 
    echo Ellenorizze a konfiguracios fajlt 
    pause 
    exit /b 1 
) 
 
REM Results konyvtar letrehozasa ha nem letezik 
if not exist "results" ( 
    echo Results konyvtar letrehozasa... 
    mkdir "results" 
) 
 
echo Robot Framework teszt futtatasa... 
echo Formai ellenorzes futtatasa (PLG-00-main.robot)... 
 
.venv\Scripts\robot.exe --outputdir results PLG-00-main.robot 
 
if errorlevel 1 ( 
    echo HIBA: A teszt futtatasa sikertelen 
    echo Ellenorizze a results\log.html fajlt a reszletekert. 
) else ( 
    echo. 
    echo ========================================= 
    echo TESZT SIKERESEN BEFEJEZODOTT 
    echo. 
    echo Eredmenyek: 
    echo - Log: results\log.html 
    echo - Report: results\report.html 
    echo - Email elkuldve a konfiguralt cimre 
    echo ========================================= 
) 
 
exit 0

