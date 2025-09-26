*** Settings ***
Documentation    Main Test Suite - minden DOCX fájlhoz külön formálellenőrzési test case-eket generál
Resource         resources/keywords.robot
Resource         resources/variables.robot  
Resource         PLG-04-Formai_ellenor.robot
Resource         PLG-02-Excel-kitolto.robot
Library          DatabaseLibrary
Library          String
Library          BuiltIn
Library          Collections
Library          OperatingSystem
Library          Process
Library          libraries/keep_awake.py

Suite Setup      Main Suite Setup
Suite Teardown   Main Suite Teardown

*** Variables ***
@{ALL_DOCX_FILES}    ${EMPTY}

*** Test Cases ***

Main Processing and Setup
    [Documentation]    Fő feldolgozás és beállítások
    [Tags]    setup
    
    ${start_time}=    Get Time    epoch
    Set Suite Variable    ${START_TIME}    ${start_time}

    # Globális log fájl inicializálása
    Initialize Global Log File

    # Konfiguracio betöltése
    Konfiguráció Betöltése

    # Log fájl áthelyezése az output mappába  
    Move Log File To Output Folder

    # Kapcsolódás SQLite adatbázishoz
    Connect To Database    sqlite3    ${SQLITE_DB_FILE}

    # Táblák ellenőrzése
    Hash táblák ellenőrzése

    # DOCX fájlok feldolgozása és formálellenőrzés
    DOCX fájlok olvasása

Final Processing and Cleanup
    [Documentation]    Végső feldolgozás és cleanup
    [Tags]    cleanup
    
    # Eredmények ellenőrzése
    Log String To Console    DUPLUM ELLENŐRZÉS BEFEJEZVE - EREDMÉNYEK ELEMZÉSE INDUL...
    Log String To Console    \n════════════════════════════════════════════════════════════════
    Run Keyword And Continue On Failure    Redundancia Eredmények Ellenőrzése

    # Futásidő számítás
    ${file_count}=    Get Variable Value    ${file_count}    0
    ${end_time}=    Get Time    epoch
    ${elapsed}=    Evaluate    int(${end_time} - ${START_TIME})
    ${hours}=    Evaluate    ${elapsed} // 3600
    ${minutes}=    Evaluate    (${elapsed} % 3600) // 60
    ${seconds}=    Evaluate    ${elapsed} % 60

    # Kapcsolat bezárása
    Disconnect From Database
    
    Log String To Console    \nTELJES FELDOLGOZÁS KÉSZ!
    Log String To Console    \n════════════════════════════════
    Log String To Console    \nFeldolgozott dokumentumok száma: ${file_count}
    Log String To Console    \nFutás teljes ideje: ${hours} óra ${minutes} perc ${seconds} másodperc

*** Keywords ***

Main Suite Setup
    [Documentation]    Main suite setup
    Prevent Sleep

Main Suite Teardown  
    [Documentation]    Main suite teardown
    Allow Sleep