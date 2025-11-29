*** Settings ***
Resource    resources/keywords.robot
Resource    resources/variables.robot
Resource    resources/IKK02-Kurzusaim-bejarasa.robot
Resource    resources/IKK03-Kurzus-ellenorzo.robot
Resource    PLG-05-WEB-ellenor-main.robot
Library     String
Library     BuiltIn
Library     Collections
Library     OperatingSystem
Library     Process
Library    libraries/keep_awake.py
# Removed SeleniumLibrary and RPA.RobotLogListener to avoid missing module errors

Suite Setup    Prevent Sleep
Suite Teardown    Allow Sleep
Test Teardown    Update Test Counters

*** Variables ***

*** Test Cases ***

Batch inicializálás
    [Documentation]    Dokumentum feldolgozás inicializálása
    ${start_time}=    Get Time    epoch
    Set Global Variable    ${BATCH_START_TIME}    ${start_time}

    # Globális log fájl inicializálása (a gyökérben)
    Initialize Global Log File

    # Teszt számlálók nullázása
   Initialize Test Counters

    # Formálellenőrzés számlálók nullázása
    Initialize Check Counters

    # Konfiguracio betöltése minden futás elején
    Konfiguráció Betöltése

    # Log fájl áthelyezése az output mappába
    Move Log File To Output Folder


    # DOCX fájlok keresése és globális változók beállítása
    Log String To Console With File    ===Initialize DOCX Files List ===
    Initialize DOCX Files List
    
    # *RRF221_tema.kezirata.docx létezés ellenőrzés 

Összes DOCX feldolgozása
    [Documentation]    Minden talált DOCX dokumentum feldolgozása formálellenőrzéssel
    @{docx_files}=    Set Variable    ${BATCH_DOCX_FILES}
    ${file_count}=    Get Length    ${docx_files}
      #selenium-screenshot törlése selenium-screenshot*.png fájlok törlése
    ${SELENIUM_SCREENSHOT_FILE}=    Set Variable    selenium-screenshot*.png
    Run Keyword And Ignore Error    Remove File    ${SELENIUM_SCREENSHOT_FILE}
    
    Log String To Console With File    \n=== ÖSSZES DOCX FELDOLGOZÁSA ===
    Log String To Console With File    Talált fájlok száma: ${file_count}
    
    FOR    ${index}    IN RANGE    ${file_count}
        ${docx_file}=    Get From List    ${docx_files}    ${index}
        ${file_number}=    Evaluate    ${index} + 1
        
        # Fájl név kinyerése az elnevezéshez
        ${file_parts}=    Split String    ${docx_file}    ${/}
        ${file_parts_len}=    Get Length    ${file_parts}
        Log String To Console With File    -----------------------${docx_file}-------------- Fájl részek száma: ${file_parts_len}
        ${file_name}=    Get From List    ${file_parts}    -1
        ${docx_file_fixed}=    Replace String    ${docx_file}    \\    /
        # A warning elkerülésére: minden backslash /-re cserélve, így nem lesz invalid escape sequence
        ${CURRENT_DIR}=    Evaluate    __import__('os').path.dirname('${docx_file_fixed}')    modules=os
        
        
        Log String To Console With File    \n\n>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
        Log String To Console With File    >>> FELDOLGOZÁS: (${file_number}/${file_count}) ${docx_file}
        IF    '${docx_file}' != '' and 'docx.docx' in '${docx_file}'
          ${docx_file_fixed}=    Replace String    ${docx_file}    \\    /
          # A warning elkerülésére: minden backslash /-re cserélve
          ${new_file_name}=    Replace String    ${docx_file_fixed}    .docx.docx    .docx
          Move File    ${docx_file_fixed}    ${new_file_name}
          Log String To Console With File    Átnevezve: ${docx_file_fixed} -> ${new_file_name}
          ${docx_file}=    Set Variable    ${new_file_name}
        END
        # van-e azonos nevű de .v1 névvel mentett fájl
        ${only_file_name}=    Replace String    ${docx_file}    .docx    ${EMPTY}
        #van -e az adott könyvtárban .v1 fájl
        ${v1_file}=    Set Variable    ${only_file_name}.v1.docx    
        Log String To Console With File    .v1 fájl: ${v1_file} 
    
        #létezik-e a fájl
        ${v1_exists}=    Run Keyword And Return Status    File Should Exist    ${v1_file}
        IF    ${v1_exists}
          Log String To Console With File    [WARNING] Létezik az azonos nevű .v1 fájl: ${v1_file} 
         Move File    ${docx_file}    ${docx_file}_old
        #az adott docx-et kihagyjuk
        CONTINUE
        END

        

        Log String To Console With File    >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  
        #${name_ok}=    Run Keyword And Return Status    Should Contain    ${file_name}    RRF221_tema_kezirata.docx
        ${name_ok}=    Run Keyword And Return Status    Should Contain    ${file_name}    RRF221_tema_kezirat
        IF    not ${name_ok}
            ${is_fogalomtar1}=    Run Keyword And Return Status    Should Contain    ${file_name}    fogalomtar
            ${is_fogalomtar2}=    Run Keyword And Return Status    Should Contain    ${file_name}    fogalomtár
            ${is_kompetencia}=    Run Keyword And Return Status    Should Contain    ${file_name}    kompetencia
            IF     $is_fogalomtar1 or $is_fogalomtar2 or $is_kompetencia
              Log String To Console With File    [SKIP] Fájl kihagyva (fogalomtár/kompetencia): ${file_name} 
              CONTINUE
            END
            #tema_kezirat név hibás
            Log String To Console With File    [SKIP] Fájl kihagyva (név nem egyezik): ${file_name} 
            Write SumError fájl    ${EMPTY}    ${EMPTY}    tc-0    Fájlnév nem tartalmazza az RRF221_tema_kezirat szöveget;${file_name}
            CONTINUE
        END

        Process Single DOCX File As Test Case    ${docx_file}    ${file_number}    ${file_count}    Formálellenőrzés - ${file_name}
        Log String To Console With File    <<<  BEFEJEZVE: ${docx_file}
        
        #WEB-es ellenőrzés indítása
        IF    ${RUN_WEB_CHECK}==${True}
          Log String To Console With File    \n---------------------------------------WEB---------------------------------------------\n
          PLG-05-WEB-ellenor-main.Web-alkalmazás indítása és bejelentkezés
        END

       #selenium-screenshot törlése selenium-screenshot*.png fájlok törlése
       ${SELENIUM_SCREENSHOT_FILE}=    Set Variable    selenium-screenshot*.png
      Run Keyword And Ignore Error    Remove File    ${SELENIUM_SCREENSHOT_FILE}
   END

Batch lezárás
    [Documentation]    Batch feldolgozás lezárása: eredmények összesítése
    
    # Eredmények automatikus ellenőrzése
    Log String To Console With File    DUPLUM ELLENŐRZÉS BEFEJEZVE - EREDMÉNYEK ELEMZÉSE INDUL...
    Log String To Console With File    \n════════════════════════════════════════════════════════════════
    # Redundancia Eredmények Ellenőrzése eltávolítva (adatbázis kezelés végleg letiltva)

    # Feldolgozott dokumentumok számának és futásidőnek kiírása
    ${file_count}=    Get Variable Value    ${BATCH_FILE_COUNT}    0
    ${start_time}=    Get Variable Value    ${BATCH_START_TIME}    ${EMPTY}
    ${end_time}=    Get Time    epoch
    ${elapsed}=    Evaluate    int(${end_time} - ${start_time})
    ${hours}=    Evaluate    ${elapsed} // 3600
    ${minutes}=    Evaluate    (${elapsed} % 3600) // 60
    ${seconds}=    Evaluate    ${elapsed} % 60

    
    Log String To Console With File    \nTELJES FELDOLGOZÁS KÉSZ!
    Log String To Console With File    \n════════════════════════════════
    Log String To Console With File    \nFeldolgozott dokumentumok száma: ${file_count}
    Log String To Console With File    \nFutás teljes ideje: ${hours} óra ${minutes} perc ${seconds} másodperc

    # Dinamikus (valós) összesítés a saját logba (Robot TC-k és 23-as ellenőrzések)
    ${TC_TOTAL}=    Get Variable Value    ${TC_TOTAL}    0
    ${TC_PASSED}=   Get Variable Value    ${TC_PASSED}   0
    ${TC_FAILED}=   Get Variable Value    ${TC_FAILED}   0
    ${CHECK_TOTAL}=    Get Variable Value    ${CHECK_TOTAL}    0
    ${CHECK_PASSED}=   Get Variable Value    ${CHECK_PASSED}   0
    ${CHECK_FAILED}=   Get Variable Value    ${CHECK_FAILED}   0
    Log String To Console With File    \nROBOT ÖSSZESÍTÉS
    Log String To Console With File    Robot testcases: ${TC_TOTAL} tests, ${TC_PASSED} passed, ${TC_FAILED} failed
    Log String To Console With File    Formálellenőrzések: ${CHECK_TOTAL} tests, ${CHECK_PASSED} passed, ${CHECK_FAILED} failed