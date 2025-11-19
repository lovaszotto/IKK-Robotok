@echo off 
REM ========================================= 
REM  FORMAI ELLENORZO RENDSZER - WEB SZERVER 
REM ========================================= 
echo. 
echo ========================================= 
echo   WEBES ROBOT FRAMEWORK INDITO 
echo   Flask szerver port: 5000 
echo ========================================= 
echo. 
 
echo Web szerver inditasa... 
echo Nyissa meg a bongeszoben: http://localhost:5000 
echo Vagy nyissa meg a web\robot_runner.html fajlt 
echo. 
.venv\Scripts\python.exe libraries\web_server.py 
