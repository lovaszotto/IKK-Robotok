# --- Globális számlálók és log változók (linter hibák elkerülésére) ---
${GLOBAL_LOG_FILENAME}    NONE
${LOG_FILENAME_ONLY}      NONE
${TC_TOTAL}               0
${TC_PASSED}              0
${TC_FAILED}              0
${CHECK_TOTAL}            0
${CHECK_PASSED}           0
${CHECK_FAILED}           0
${BATCH_FILE_COUNT}       0
${BATCH_DOCX_FILES}       []
${CURRENT_EXCEL_FILE}     NONE
${CURRENT_SHEET_NAME}     NONE
${CURRENT_PATH_PART}      NONE
${CURRENT_FILENAME_PART}  NONE
${RENAME_PREFIX}          NONE
${HIBA_LISTA}             []
${CURRENT_DOCX_FILE}      NONE
*** Variables ***
${EMPTY}    
${DOCX_FILE}        Test.docx
${DOCUMENT_PATH}    ./test  # Ezt a konfiguracios fajlbol toltjuk be
${DOCX_JSON}        ${None} # az aktuálisan beolvasott docx json tartalom
${szoveg}           NONE
${WAS_ERROR}        ${False} #volt-e hiba a futás során egy dokumentum feldolgozásakor

# Python executable változó (Robot Framework környezetben)
${PYTHON_EXEC}      python


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

# Futtassunk web-ellenőrzést (konfigból)
# A változót egy kulcsszóval kell beállítani a suite setup-ban:
# Példa:
#    Beállítom a RUN_WEB_CHECK-et konfigból
#
# Majd a kulcsszó:
# *** Keywords ***
# Beállítom a RUN_WEB_CHECK-et konfigból
#     ${val}=    Evaluate    __import__('libraries.duplikacio_config').DuplikacioConfig().is_web_check_enabled()    modules=libraries.duplikacio_config
#     Set Suite Variable    ${RUN_WEB_CHECK}    ${val}

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
