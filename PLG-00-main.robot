*** Settings ***
Resource    resources/keywords.robot
Resource    resources/variables.robot
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
    Initialize DOCX Files List
    
    # *RRF221_tema.kezirata.docx létezés ellenőrzés 

Összes DOCX feldolgozása
    [Documentation]    Minden talált DOCX dokumentum feldolgozása formálellenőrzéssel
    @{docx_files}=    Set Variable    ${BATCH_DOCX_FILES}
    ${file_count}=    Get Length    ${docx_files}
    
    Log String To Console    \n=== ÖSSZES DOCX FELDOLGOZÁSA ===
    Log String To Console    Talált fájlok száma: ${file_count}
    
    FOR    ${index}    IN RANGE    ${file_count}
        ${docx_file}=    Get From List    ${docx_files}    ${index}
        ${file_number}=    Evaluate    ${index} + 1
        
        # Fájl név kinyerése az elnevezéshez
        ${file_parts}=    Split String    ${docx_file}    ${/}
        ${file_name}=    Get From List    ${file_parts}    -1
        
        ${CURRENT_DIR}=    Evaluate    __import__('os').path.dirname(r'''${docx_file}''')    modules=os
        
        Log String To Console    \n\n>>> FELDOLGOZÁS: (${file_number}/${file_count}) ${docx_file}
         #todo docx_file név ellenőrzés
        ${name_ok}=    Run Keyword And Return Status    Should Contain    ${file_name}    RRF221_tema_kezirata.docx
        IF    not ${name_ok}
            Log String To Console    [SKIP] Fájl kihagyva (név nem egyezik): ${file_name}
            ${subname_ok}=    Run Keyword And Return Status    Should Contain    ${file_name}    tema_kezirat
            IF    ${subname_ok}
                Log String To Console    [WARNING${:}] A fájl név nem pontosan egyezik, de tartalmazza a 'tema_kezirat' részt: ${file_name}
                ${missing_file_name}=    Replace String    ${file_name}    .docx     .txt
                Create File   ${CONFIG_OUTPUT_FOLDER}\\Hiányzó-${missing_file_name}     A fájl név nem pontosan egyezik, de tartalmazza a 'tema_kezirat' részt
            END    
            CONTINUE
        END

        Process Single DOCX File As Test Case    ${docx_file}    ${file_number}    ${file_count}    Formálellenőrzés - ${file_name}
        Log String To Console    <<<  BEFEJEZVE: ${docx_file}
    END

Batch lezárás
    [Documentation]    Batch feldolgozás lezárása: eredmények összesítése
    
    # Eredmények automatikus ellenőrzése
    Log String To Console    DUPLUM ELLENŐRZÉS BEFEJEZVE - EREDMÉNYEK ELEMZÉSE INDUL...
    Log String To Console    \n════════════════════════════════════════════════════════════════
    # Redundancia Eredmények Ellenőrzése eltávolítva (adatbázis kezelés végleg letiltva)

    # Feldolgozott dokumentumok számának és futásidőnek kiírása
    ${file_count}=    Get Variable Value    ${BATCH_FILE_COUNT}    0
    ${start_time}=    Get Variable Value    ${BATCH_START_TIME}    ${EMPTY}
    ${end_time}=    Get Time    epoch
    ${elapsed}=    Evaluate    int(${end_time} - ${start_time})
    ${hours}=    Evaluate    ${elapsed} // 3600
    ${minutes}=    Evaluate    (${elapsed} % 3600) // 60
    ${seconds}=    Evaluate    ${elapsed} % 60

    
    Log String To Console    \nTELJES FELDOLGOZÁS KÉSZ!
    Log String To Console    \n════════════════════════════════
    Log String To Console    \nFeldolgozott dokumentumok száma: ${file_count}
    Log String To Console    \nFutás teljes ideje: ${hours} óra ${minutes} perc ${seconds} másodperc

    # Dinamikus (valós) összesítés a saját logba (Robot TC-k és 23-as ellenőrzések)
    ${TC_TOTAL}=    Get Variable Value    ${TC_TOTAL}    0
    ${TC_PASSED}=   Get Variable Value    ${TC_PASSED}   0
    ${TC_FAILED}=   Get Variable Value    ${TC_FAILED}   0
    ${CHECK_TOTAL}=    Get Variable Value    ${CHECK_TOTAL}    0
    ${CHECK_PASSED}=   Get Variable Value    ${CHECK_PASSED}   0
    ${CHECK_FAILED}=   Get Variable Value    ${CHECK_FAILED}   0
    Log String To Console    \nROBOT ÖSSZESÍTÉS
    Log String To Console    Robot testcases: ${TC_TOTAL} tests, ${TC_PASSED} passed, ${TC_FAILED} failed
    Log String To Console    Formálellenőrzések: ${CHECK_TOTAL} tests, ${CHECK_PASSED} passed, ${CHECK_FAILED} failed