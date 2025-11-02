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


#Excel fájlok nevei
${KEZIRAT_EXCEL_FILE}    ${EMPTY}
${DIGITALIS_EXCEL_FILE}    ${EMPTY}
${DIGITALIS_EXCEL_SHEET}    ${EMPTY}
${DIGITALIS_EXCEL_SHEET_MK}    ${EMPTY}


${CR}=    Set Variable    ;

#Media katalógus változói
${MEDIA_ROW_INDEX}            5

# Futtassunk média ellenőrzést
${RUN_MEDIA_CHECK}          ${True}

# Van kép és más típusú média
${MEDIA_HAS_PICTURE}          ${False}
${MEDIA_HAS_OTHER_TYPE}          ${False}




# Dinamikus adatbázis elérési út betöltése a Python configból
${DB_PATH_FROM_CONFIG}=    Evaluate    __import__('libraries.duplikacio_config').DuplikacioConfig().get_database_file()    modules=libraries.duplikacio_config

# Dokumentumból elmentett értékek
${DOKUMENTUM_SZERZO}              ${EMPTY}
${DOKUMENTUM_SZAKMAI_LEKTOR}      ${EMPTY}


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
