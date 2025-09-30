*** Settings ***
Resource    resources/keywords.robot
Resource    resources/variables.robot
Resource    PLG-02-read_docx.robot   
Resource    PLG-04-Formai_ellenor.robot
Library     DatabaseLibrary
Library     String
Library     BuiltIn
Library     Collections
Library     OperatingSystem
Library     Process
Library    libraries/keep_awake.py

Suite Setup    Initialize Batch Processing
Suite Teardown    Finalize Batch Processing

*** Variables ***

*** Test Cases ***

Batch feldolgozás inicializálása
    [Documentation]    Batch feldolgozás előkészítése: konfiguráció, adatbázis kapcsolat
    ${start_time}=    Get Time    epoch
    Set Global Variable    ${BATCH_START_TIME}    ${start_time}

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

    # DOCX fájlok listájának előkészítése és test case-ek generálása
    Prepare DOCX Files And Test Cases

Batch feldolgozás befejezése
    [Documentation]    Batch feldolgozás lezárása: eredmények összesítése
    
    # Eredmények automatikus ellenőrzése
    Log String To Console    DUPLUM ELLENŐRZÉS BEFEJEZVE - EREDMÉNYEK ELEMZÉSE INDUL...
    Log String To Console    \n════════════════════════════════════════════════════════════════
    Run Keyword And Continue On Failure    Redundancia Eredmények Ellenőrzése

    # Feldolgozott dokumentumok számának és futásidőnek kiírása
    ${file_count}=    Get Variable Value    ${BATCH_FILE_COUNT}    0
    ${start_time}=    Get Variable Value    ${BATCH_START_TIME}    ${EMPTY}
    ${end_time}=    Get Time    epoch
    ${elapsed}=    Evaluate    int(${end_time} - ${start_time})
    ${hours}=    Evaluate    ${elapsed} // 3600
    ${minutes}=    Evaluate    (${elapsed} % 3600) // 60
    ${seconds}=    Evaluate    ${elapsed} % 60

    # Kapcsolat bezárása a legvégén
    Disconnect From Database
    
    Log String To Console    \nTELJES FELDOLGOZÁS KÉSZ!
    Log String To Console    \n════════════════════════════════
    Log String To Console    \nFeldolgozott dokumentumok száma: ${file_count}
    Log String To Console    \nFutás teljes ideje: ${hours} óra ${minutes} perc ${seconds} másodperc

*** Keywords ***

Initialize Batch Processing
    [Documentation]    Batch folyamat inicializálása
    Prevent Sleep
    Set Global Variable    ${BATCH_DOCX_FILES}    ${EMPTY}
    Set Global Variable    ${BATCH_FILE_COUNT}    0

Finalize Batch Processing
    [Documentation]    Batch folyamat befejezése
    Allow Sleep

Prepare DOCX Files And Test Cases
    [Documentation]    DOCX fájlok keresése és dinamikus test case-ek létrehozása
    
    # DOCX fájlok keresése a megadott útvonalon
    @{docx_files}=    Find Docx Files Recursively    ${DOCUMENT_PATH}
    
    # Ellenőrzés, hogy van-e DOCX fájl
    ${file_count}=    Get Length    ${docx_files}
    Set Global Variable    ${BATCH_FILE_COUNT}    ${file_count}
    Set Global Variable    ${BATCH_DOCX_FILES}    ${docx_files}
    Log String To Console    \n=== DOCX FÁJLOK KERESÉSE ===
    Log String To Console    Keresési útvonal: ${DOCUMENT_PATH}
    Log String To Console    Talált DOCX fájlok száma: ${file_count}

    
    IF    ${file_count} == 0
        Log String To Console    FIGYELMEZTETÉS: Nem találhatók DOCX fájlok a megadott útvonalon!
        Fail    Nincsenek DOCX fájlok a feldolgozásra
    END
    
    # Minden DOCX fájlhoz dinamikus test case-ek létrehozása
    ${index}=    Set Variable    1
    FOR    ${docx_file}    IN    @{docx_files}
        ${base_name}=    Get File Name Base    ${docx_file}
        Create Dynamic Test Case For DOCX    ${docx_file}    ${base_name}    ${index}    ${file_count}
        ${index}=    Evaluate    ${index} + 1
    END

Create Dynamic Test Case For DOCX
    [Documentation]    Dinamikus test case létrehozása egyetlen DOCX fájlhoz
    [Arguments]    ${docx_file}    ${base_name}    ${index}    ${total}
    
    # Test case név generálása
    ${test_name}=    Set Variable    DOCX Feldolgozás ${index} - ${base_name}
    
    Log String To Console    \n>>> DINAMIKUS TEST CASE: ${test_name}
    
    # Process the DOCX file with all format checks
    Process Single DOCX With All Checks    ${docx_file}    ${index}    ${total}

Process Single DOCX With All Checks
    [Documentation]    Egyetlen DOCX fájl teljes feldolgozása (redundancia + 23 formálellenőrzés)
    [Arguments]    ${docx_file}    ${file_index}    ${total_files}
    
    Log String To Console    \n>>> FELDOLGOZÁS2: (${file_index}/${total_files}) ${docx_file}
    
    # PLG-01-Excel.robot meghívása
    ${activeExcelFile}    ${activeSheetName}=    Create_K_ell_Excel    ${docx_file}
    
    # Globális változók beállítása a formálellenőrzéshez
    Set Global Variable    ${CURRENT_EXCEL_FILE}    ${activeExcelFile}
    Set Global Variable    ${CURRENT_SHEET_NAME}    ${activeSheetName}
    Set Global Variable    ${CURRENT_DOCX_FILE}    ${docx_file}
    
    # Beállítja az aktuális DOCX fájlt változóban
    Set Global Variable    ${DOCX_FILE}    ${docx_file}
    
    # DOCX beolvasás és hibastátusz lekérdezése
    ${szoveg}=    Beolvasom A DOCX Fájlt
    Set Global Variable    ${SZOVEG}    ${szoveg}

    ${is_error}=    Run Keyword And Return Status    Should Start With    ${szoveg}    [HIBA]
    ${is_empty}=    Run Keyword And Return Status    Should Be Empty    ${szoveg}
    ${is_none}=    Run Keyword And Return Status    Should Be Equal    ${szoveg}    None
    # Bármelyik igaz, akkor is_error legyen igaz
    IF    ${is_error} or ${is_empty} or ${is_none}
        ${is_error}=    Set Variable    ${True}
    ELSE
        ${is_error}=    Set Variable    ${False}
    END

    # Először redundancia rekordot beszúrjuk, majd átadjuk az ID-t a DOCX feldolgozásnak
    #${redundancia_id}=    Fájladatok Feldolgozása Redundancia Táblába    ${docx_file}    ${is_error}    ${szoveg}
    #Run Keyword If    '${redundancia_id}' != ''    DOCX Beolvasás Teszt    ${docx_file}    ${redundancia_id}
    
    # Mind a 23 formálellenőrzés közvetlenül (nem subprocess-ként)
    Log String To Console    \n=== 23 FORMÁLELLENŐRZÉS INDÍTÁSA ===
    Log String To Console    Excel fájl: ${activeExcelFile}
    Log String To Console    Sheet név: ${activeSheetName}
    
    # 23 formálellenőrzés egyenként
    Test Case 01 - Arculati Elemek Ellenorzese
    Test Case 02 - Kompetencia Teszt Ellenorzese
    Test Case 03 - Fogalomtar Ellenorzese
    Test Case 04 - Szerkesztoi Instrukciok Ellenorzese
    Test Case 05 - Internet Hivatkozasok Ellenorzese
    Test Case 06 - Szerzo Lektor Ellenorzese
    Test Case 07 - Hosszu Idezetek Ellenorzese
    Test Case 08 - Tordeles Ellenorzese
    Test Case 09 - Abrak Fotok Ellenorzese
    Test Case 10 - Felsorolas Ellenorzese
    Test Case 11 - Ures Negyzetek Ellenorzese
    Test Case 12 - Cimek Formatuma Ellenorzese
    Test Case 13 - Oldalhatar Ellenorzese
    Test Case 14 - Betutipus Ellenorzese
    Test Case 15 - Sorkoze Ellenorzese
    Test Case 16 - Labjegyzetek Ellenorzese
    Test Case 17 - Tartalomjegyzek Ellenorzese
    Test Case 18 - Irodalomjegyzek Ellenorzese
    Test Case 19 - Tablazatok Ellenorzese
    Test Case 20 - Szoveg Igazitas Ellenorzese
    Test Case 21 - Oldalszamozas Ellenorzese
    Test Case 22 - Fejlec Lablec Ellenorzese
    Test Case 23 - Helyesiras Ellenorzese
    
    Log String To Console    \n<<< BEFEJEZVE: ${docx_file}