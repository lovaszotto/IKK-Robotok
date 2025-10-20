*** Variables ***
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
