*** Variables ***
${EMPTY}    
${DOCX_FILE}        Test.docx
${DOCUMENT_PATH}    ./test  # Ezt a konfiguracios fajlbol toltjuk be
${DOCX_JSON}        ${None} # az aktuálisan beolvasott docx json tartalom
${szoveg}           NONE
${WAS_ERROR}        ${False} #volt-e hiba a futás során egy dokumentum feldolgozásakor

# Python executable változó (Robot Framework környezetben)
${PYTHON_EXEC}      ${CURDIR}/../venv/Scripts/python.exe


# Konfiguracios fajl beallitasai - ezeket a duplikacio_config.py tölti be
${CONFIG_INPUT_FOLDER}  c:\\tmp\\keziratok_teszteleshez
${CONFIG_OUTPUT_FOLDER}    c:\\tmp
${CONFIG_EXCEL_PREFIX}  duplikacio_eredmenyek

# SQLite Database Connection Variables
${DB_MODULE}        sqlite3
${DB_HOST}          test_database.db
${DB_NAME}          ${EMPTY}
${DB_USERNAME}      
${DB_PASSWORD}      
${DB_PORT}  

${SQLITE_DB_FILE}    ${EMPTY}

# Dinamikus adatbázis elérési út betöltése a Python configból
${DB_PATH_FROM_CONFIG}=    Evaluate    __import__('libraries.duplikacio_config').DuplikacioConfig().get_database_file()    modules=libraries.duplikacio_config



${APP_URL}        https://account.nexiuslearning.com/login
${USERNAME}       benedek.panna@clarity.hu
${PASSWORD}       KisKecske123!

${REMOTE_URL}     http://127.0.0.1:9222


#Documentum téma szerinti szűréshez használható változó értékek:
#${DTEM}           DTEM-*        #Minden kurzus megjelenítése a keresőben
${DTEM}          DTEM-1.*      #egy konkrét témához tartozó kurzusok
#${DTEM}          DTEM-1.5      #Egy konkrét kurzushoz tartozó Leckék



#Kurzusok szűrésenél használható változó értékek:
#${KURZUS}      ${EMPTY}         #Nem megy le a kurzus ellenőrzésre
${KURZUS}      DTEM-*       #Minden kurzus megjelenítése a keresőben
#${KURZUS}      DTEM-1.5.*   #Egy konkrét kurzushoz tartozó Leckék
#${KURZUS}       DTEM-1.5.1   #egy konkrét lecke
