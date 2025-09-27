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

*** Variables ***

*** Test Cases ***

Batch inicializálás
    [Documentation]    Dokumentum feldolgozás inicializálása
    ${start_time}=    Get Time    epoch
    Set Global Variable    ${BATCH_START_TIME}    ${start_time}

    # Globális log fájl inicializálása (a gyökérben)
    Initialize Global Log File

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
    
    # Egyszer feldolgozandó könyvtárak listája
    ${DoneDirs}=    Create List
    
    FOR    ${index}    IN RANGE    ${file_count}
        ${docx_file}=    Get From List    ${docx_files}    ${index}
        ${file_number}=    Evaluate    ${index} + 1
        
        # Fájl név kinyerése az elnevezéshez
        ${file_parts}=    Split String    ${docx_file}    ${/}
        ${file_name}=    Get From List    ${file_parts}    -1
        
        ${CURRENT_DIR}=    Evaluate    __import__('os').path.dirname(r'''${docx_file}''')    modules=os
     
        # Csak egyszer feldolgozni egy könyvtárat: ha már szerepel, folytatás
        ${already_done}=    Run Keyword And Return Status    List Should Contain Value    ${DoneDirs}    ${CURRENT_DIR}
        
        #IF    ${already_done} 
            #Log String To Console    >>>>>>>>>>>>>>>>>>>>>>>>>>>>>A fájl kihagyva<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
            #Log String To Console    ${docx_file}
            #CONTINUE
       #ELSE
            Log String To Console    \n\n>>> FELDOLGOZÁS: (${file_number}/${file_count}) ${docx_file}
            #Log String To Console       -------------------------------> ${CURRENT_DIR} <-------------------------------\n

            Append To List    ${DoneDirs}    ${CURRENT_DIR}
            #Log String To Console    <<<  FELDOLGOZÁS indul...
            Process Single DOCX With Format Checks    ${docx_file}    ${file_number}    ${file_count}
            Log String To Console    <<<  BEFEJEZVE: ${docx_file}
        #END

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