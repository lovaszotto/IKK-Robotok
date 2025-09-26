*** Settings ***
Resource    resources/keywords.robot
Resource    resources/variables.robot
Resource    PLG-02-read_docx.robot   
Library     DatabaseLibrary
Library     String
Library     BuiltIn
Library     Collections
Library     OperatingSystem
Library     Process
Library    libraries/keep_awake.py

Suite Setup    Prevent Sleep
Suite Teardown    Allow Sleep

*** Variables ***

*** Test Cases ***

Redundancia ellenőrzése
    [Documentation]    Dokumentumokban ismétlődések keresése
    ${start_time}=    Get Time    epoch

    # Globális log fájl inicializálása (a gyökérben)
    Initialize Global Log File

    # Konfiguracio betöltése minden futás elején
    Konfiguráció Betöltése

    # Log fájl áthelyezése az output mappába
    Move Log File To Output Folder

    # Kapcsolódás SQLite adatbázishoz (létrehozza ha nem létezik)
    Connect To Database    sqlite3    ${SQLITE_DB_FILE}

    # Táblák meglétének ellenőrzése, ha nincs, akkor létrehozás
    Hash táblák ellenőrzése

    #Docx beolvasása és feldolgozása
    DOCX fájlok olvasása

    # Eredmények automatikus ellenőrzése
    Log String To Console    DUPLUM ELLENŐRZÉS BEFEJEZVE - EREDMÉNYEK ELEMZÉSE INDUL...
    Log String To Console    \n════════════════════════════════════════════════════════════════
    Run Keyword And Continue On Failure    Redundancia Eredmények Ellenőrzése

    # Excel export automatikus futtatása
    #Log To Console    EXCEL EXPORT INDÍTÁSA...
    #Log To Console    \n════════════════════════════════
    # Feldolgozott dokumentumok számának és futásidőnek kiírása
    ${file_count}=    Get Variable Value    ${file_count}    0
    ${end_time}=    Get Time    epoch
    ${elapsed}=    Evaluate    int(${end_time} - ${start_time})
    ${hours}=    Evaluate    ${elapsed} // 3600
    ${minutes}=    Evaluate    (${elapsed} % 3600) // 60
    ${seconds}=    Evaluate    ${elapsed} % 60

    # Kapcsolat bezárása a legvégén
    Disconnect From Database

        # Run Keyword And Continue On Failure    Email Küldés Eredményekkel
    ${file_count}=    Get Variable Value    ${file_count}    0
    ${end_time}=    Get Time    epoch
    ${elapsed}=    Evaluate    int(${end_time} - ${start_time})
    ${hours}=    Evaluate    ${elapsed} // 3600
    ${minutes}=    Evaluate    (${elapsed} % 3600) // 60
    ${seconds}=    Evaluate    ${seconds} % 60
    
    Log String To Console    \nTELJES FELDOLGOZÁS KÉSZ!
    Log String To Console    \n════════════════════════════════
    Log String To Console    \nFeldolgozott dokumentumok száma: ${file_count}
    Log String To Console    \nFutás teljes ideje: ${hours} óra ${minutes} perc ${seconds} másodperc