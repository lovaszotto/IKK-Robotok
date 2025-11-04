@echo off
REM =====================================================
REM  IKK02 FORMAI ELLENORZO RENDSZER - TELEPITO v2.0
REM  Robot Framework alapu automatizált dokumentum
REM  formálellenőrzés és plágium detektálás
REM =====================================================
setlocal EnableDelayedExpansion

echo.
echo =====================================================
echo   IKK02 FORMAI ELLENORZO RENDSZER TELEPITO v2.0
echo   
echo   Funkcionalitas:
echo   - Automatikus DOCX formai ellenorzes
echo   - Robot Framework tesztvezerlese  
echo   - Excel export es riportkeszites
echo   - Web interfesz tamogatas
echo =====================================================
echo.

REM Telepitesi konyvtar bekeres
REM Automatikus telepitesi konyvtar beallitasa: az aktualis folder nevében a DownloadedRobots kifejezést InstalledRobots-ra cseréljük
set "CURDIR=%CD%"
set "TARGET_DIR=%CURDIR:DownloadedRobots=InstalledRobots%"
set "TARGET_DIR=%CURDIR:SandboxRobots=InstalledRobots%"
echo [INFO] Alapértelmezett telepítési konyvtár: %TARGET_DIR%

REM Ha nem letezik a konyvtar, hozzuk letre
if not exist "%TARGET_DIR%" (
    echo [INFO] Telepitesi konyvtar letrehozasa: %TARGET_DIR%
    mkdir "%TARGET_DIR%"
)


echo.
echo Telepitesi cel: %TARGET_DIR%
echo.

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

REM Python verzió ellenőrzés (3.8+ ajánlott)
for /f "tokens=2" %%i in ('python --version 2^>^&1') do set PYTHON_VERSION=%%i
echo Talalt Python verzio: %PYTHON_VERSION%

echo.
echo Python modullok ellenorzese...
python -c "import sys; print('Python executable:', sys.executable)"
echo.

REM Konyvtar letrehozasa ha nem letezik
if not exist "%TARGET_DIR%" (
    echo Konyvtar letrehozasa: %TARGET_DIR%
    mkdir "%TARGET_DIR%"
    if errorlevel 1 (
        echo HIBA: Nem sikerult letrehozni a konyvtarat!
        pause
        exit /b 1
    )
) else (
    echo Konyvtar mar letezik: %TARGET_DIR%
)

echo.
echo Fajlok masolasa...

REM Szukseges robot fajlok masolasa
copy "*.robot" "%TARGET_DIR%\"


REM Konfiguracios fajlok masolasa
copy "IKK.config" "%TARGET_DIR%\"
copy "TELEPITO_UTMUTATO.txt" "%TARGET_DIR%\"
copy "start.bat" "%TARGET_DIR%\"

REM Markdown dokumentacio fajlok masolasa
copy "README.md" "%TARGET_DIR%\"
copy "DOKUMENTACIO.md" "%TARGET_DIR%\"
copy "TECHNIKAI_ATTEKINTES.md" "%TARGET_DIR%\"
copy "GYORS_REFERENCIA.md" "%TARGET_DIR%\"
copy "KONZOL_KOMPATIBILITAS.md" "%TARGET_DIR%\"
copy "WEBES_INDITASI_UTMUTATO.md" "%TARGET_DIR%\"

REM További fájlok másolása
copy "_VERSION.rtf" "%TARGET_DIR%\"


REM Libraries mappa masolasa
if exist "libraries" (
    echo Konyvtarak konyvtar masolasa...
    xcopy "libraries" "%TARGET_DIR%\libraries" /E /I /Y
)

REM Resources mappa masolasa
if exist "resources" (
    echo Eroforras konyvtar masolasa...
    xcopy "resources" "%TARGET_DIR%\resources" /E /I /Y
)

REM Test mappa masolasa
if exist "test" (
    echo Teszt konyvtar masolasa...
    xcopy "test" "%TARGET_DIR%\test" /E /I /Y
)
REM testcases mappa masolasa
if exist "testcases" (
    echo TesztCases konyvtar masolasa...
    xcopy "testcases" "%TARGET_DIR%\testcases" /E /I /Y
)

REM Sablonok mappa masolasa
if exist "sablonok" (
    echo Sablonok konyvtar masolasa...
    xcopy "sablonok" "%TARGET_DIR%\sablonok" /E /I /Y
)



echo Fajlok sikeresen masolva.

REM Ellenorizzuk es javitsuk a hianyzo fajlokat
echo Hianyzo fajlok ellenorzese es potellepites...

REM Fontos library fajlok ellenorzese
if not exist "%TARGET_DIR%\libraries\duplikacio_config.py" (
    echo duplikacio_config.py hianyzo, ujra letrehozas...
    copy "libraries\duplikacio_config.py" "%TARGET_DIR%\libraries\"
)

if not exist "%TARGET_DIR%\libraries\DocxReader.py" (
    echo DocxReader.py hianyzo, ujra letrehozas...
    copy "libraries\DocxReader.py" "%TARGET_DIR%\libraries\"
)

if not exist "%TARGET_DIR%\libraries\web_server.py" (
    echo web_server.py hianyzo, ujra letrehozas...
    copy "libraries\web_server.py" "%TARGET_DIR%\libraries\"
)

REM Results es output konyvtarak letrehozasa
if not exist "%TARGET_DIR%\results" (
    echo Results konyvtar letrehozasa...
    mkdir "%TARGET_DIR%\results"
)

if not exist "%TARGET_DIR%\results\docx_dump" (
    echo DOCX dump konyvtar letrehozasa...
    mkdir "%TARGET_DIR%\results\docx_dump"
)

echo.

REM Atlepunk a cel konyvtarba
cd /d "%TARGET_DIR%"

REM Virtualis kornyezet letrehozasa
echo Virtualis kornyezet letrehozasa...
if not exist "rf_env" (
    python -m venv rf_env
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
REM rf_env\Scripts\activate (nem szükséges, pip elérési út miatt)
rf_env\Scripts\pip.exe install --upgrade pip
rf_env\Scripts\pip.exe install robotframework
rf_env\Scripts\pip.exe install robotframework-databaselibrary
rf_env\Scripts\pip.exe install openpyxl
rf_env\Scripts\pip.exe install python-docx
rf_env\Scripts\pip.exe install pywin32
rf_env\Scripts\pip.exe install lxml
rf_env\Scripts\pip.exe install flask
rf_env\Scripts\pip.exe install pillow
rf_env\Scripts\pip.exe install requests

if errorlevel 1 (
    echo HIBA: Csomagok telepitese sikertelen!
    pause
    exit /b 1
)

echo.
rem echo start.bat fajl letrehozasa...

REM start.bat fajl letrehozasa
rem echo @echo off > start.bat
rem echo REM ========================================= >> start.bat
rem echo REM  FORMAI ELLENORZO RENDSZER FUTTATAS >> start.bat
rem echo REM ========================================= >> start.bat
rem echo echo. >> start.bat
rem echo echo ========================================= >> start.bat
rem echo echo   FORMAI ELLENORZO RENDSZER >> start.bat
rem echo echo   Main robot futtatas >> start.bat
rem echo echo ========================================= >> start.bat
rem echo echo. >> start.bat
rem echo. >> start.bat
rem echo REM Ellenorizzuk a virtualis kornyezet megletet >> start.bat
rem echo if not exist "rf_env\Scripts\robot.exe" ^( >> start.bat
rem echo     echo HIBA: Virtualis kornyezet nem talalhato! >> start.bat
rem echo     echo Futtassa eloszor a telepito.bat fajlt! >> start.bat
rem echo     pause >> start.bat
rem echo     exit /b 1 >> start.bat
rem echo ^) >> start.bat
rem echo. >> start.bat
rem echo echo Konfiguracio ellenorzese... >> start.bat
rem echo if not exist "IKK.config" ^( >> start.bat
rem echo     echo HIBA: IKK.config fajl nem talalhato! >> start.bat
rem echo     echo Ellenorizze a konfiguracios fajlt! >> start.bat
rem echo     pause >> start.bat
rem echo     exit /b 1 >> start.bat
rem echo ^) >> start.bat
rem echo. >> start.bat
rem echo REM Results konyvtar letrehozasa ha nem letezik >> start.bat
rem echo if not exist "results" ^( >> start.bat
rem echo     echo Results konyvtar letrehozasa... >> start.bat
rem echo     mkdir "results" >> start.bat
rem echo ^) >> start.bat
rem echo. >> start.bat
rem echo echo Robot Framework teszt futtatasa... >> start.bat
rem echo echo Formai ellenorzes futtatasa ^(PLG-00-main.robot^)... >> start.bat
rem echo. >> start.bat
rem echo rf_env\Scripts\robot.exe --outputdir results PLG-00-main.robot >> start.bat
rem echo. >> start.bat
rem echo if errorlevel 1 ^( >> start.bat
rem echo     echo HIBA: A teszt futtatasa sikertelen! >> start.bat
rem echo     echo Ellenorizze a results\log.html fajlt a reszletekert. >> start.bat
rem echo ^) else ^( >> start.bat
rem echo     echo. >> start.bat
rem echo     echo ========================================= >> start.bat
rem echo     echo TESZT SIKERESEN BEFEJEZODOTT! >> start.bat
rem echo     echo. >> start.bat
rem echo     echo Eredmenyek: >> start.bat
rem echo     echo - Log: results\log.html >> start.bat
rem echo     echo - Report: results\report.html >> start.bat
rem echo     echo - Email elkuldve a konfiguralt cimre >> start.bat
rem echo     echo ========================================= >> start.bat
rem echo ^) >> start.bat
rem echo. >> start.bat
rem echo exit >> start.bat

echo.
echo =========================================
echo TELEPITES SIKERES!
echo.
echo Telepitesi hely: %TARGET_DIR%
echo.
echo Telepitett komponensek:
echo - Robot Framework (tesztvezerlesi keretrendszer)
echo - Database Library (adatbazis kezeles)
echo - OpenPyXL (Excel export es kezeles)
echo - Python-docx (DOCX olvasas es iras)
echo - PyWin32 (Windows COM objektumok - email kuldes)
echo - LXML (XML/HTML feldolgozo)
echo - Flask (webes szerver)
echo - Pillow (kepfeldolgozo)
echo - Requests (HTTP kliens)
echo - Teljes projekt fajlok (robot, libraries, resources)
echo - Web interfesz (robot_runner.html)
echo - Sablonok es dokumentacio
echo - start.bat futtato script
echo.
echo Hasznalat:
echo 1. Konzol modu: Menjen a telepitesi konyvtarba: %TARGET_DIR%
echo    Es futtassa: start.bat
echo 2. Webes modu: Nyissa meg: web\robot_runner.html
echo    Vagy futtassa: rf_env\Scripts\python.exe libraries\web_server.py
echo.
echo Konfiguracio: 
echo - IKK.config fajl szerkesztese ( mappak)
echo - Sablonok: sablonok\ konyvtar
echo - Tesztfajlok: test\ konyvtar
echo - Eredmenyek: results\ konyvtar
echo - Dokumentacio: README.md, DOKUMENTACIO.md
echo.
echo Webes inditas: WEBES_INDITASI_UTMUTATO.md
echo =========================================
echo.
echo webserver.bat fajl letrehozasa webes inditashoz...

REM webserver.bat fajl letrehozasa
echo @echo off > webserver.bat
echo REM ========================================= >> webserver.bat
echo REM  FORMAI ELLENORZO RENDSZER - WEB SZERVER >> webserver.bat
echo REM ========================================= >> webserver.bat
echo echo. >> webserver.bat
echo echo ========================================= >> webserver.bat
echo echo   WEBES ROBOT FRAMEWORK INDITO >> webserver.bat
echo echo   Flask szerver port: 5000 >> webserver.bat
echo echo ========================================= >> webserver.bat
echo echo. >> webserver.bat
echo. >> webserver.bat
echo echo Web szerver inditasa... >> webserver.bat
echo echo Nyissa meg a bongeszoben: http://localhost:5000 >> webserver.bat
echo echo Vagy nyissa meg a web\robot_runner.html fajlt >> webserver.bat
echo echo. >> webserver.bat
echo rf_env\Scripts\python.exe libraries\web_server.py >> webserver.bat


