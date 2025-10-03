*** Settings ***
Documentation    Formálellenőrzési Test Suite - minden DOCX fájlhoz külön test case-eket generál
Resource         resources/keywords.robot
Resource         resources/variables.robot
Resource         PLG-04-Formai_ellenor.robot
Resource         PLG-02-Excel-kitolto.robot

*** Variables ***
@{DOCX_FILES}    ${EMPTY}
${CURRENT_DOCX_FILE}    ${EMPTY}
${CURRENT_EXCEL_FILE}    ${EMPTY}
${CURRENT_SHEET_NAME}    ${EMPTY}

*** Test Cases ***

Generate Format Check Tests
    [Documentation]    Generálja a formálellenőrzési test case-eket minden DOCX fájlhoz
    [Tags]    setup
    
    # Get the list of DOCX files to process
    @{docx_files}=    Get Global Variable Value    @{PROCESSED_DOCX_FILES}    @{EMPTY}
    
    IF    @{docx_files} == @{EMPTY}
        Log    Nincs DOCX fájl feldolgozásra    console=yes
        Pass Execution    message=Nincs DOCX fájl
    END
    
    # Create test cases for each DOCX file
    FOR    ${docx_file}    IN    @{docx_files}
        Run Formai Ellenorzes For File    ${docx_file}
    END

*** Keywords ***

Run Formai Ellenorzes For File
    [Documentation]    Futtatja a 23 formálellenőrzést egy DOCX fájlhoz
    [Arguments]    ${docx_file}
    
    Log    === DOCX FÁJL FORMÁLELLENŐRZÉSE: ${docx_file} ===    console=yes
    
    # Set current file variables
    Set Test Variable    ${CURRENT_DOCX_FILE}    ${docx_file}
    
    # Run all 23 format checks as individual test cases
    @{test_case_names}=    Create List
    ...    Test Case 01 - Arculati Elemek Ellenorzese
    ...    Test Case 02 - Kompetencia Teszt Ellenorzese  
    ...    Test Case 03 - Fogalomtar Ellenorzese
    ...    Test Case 04 - Szerkesztoi Instrukciok Ellenorzese
    ...    Test Case 05 - Internet Hivatkozasok Ellenorzese
    ...    Test Case 06 - Szerzo Lektor Ellenorzese
    ...    Test Case 07 - Hosszu Idezetek Ellenorzese
    ...    Test Case 08 - Tordeles Ellenorzese
    ...    Test Case 09 - Abrak Fotok Ellenorzese
    ...    Test Case 10 - Felsorolas Ellenorzese
    ...    Test Case 11 - Ures Negyzetek Ellenorzese
    ...    Test Case 12 - Cimek Formatuma Ellenorzese
    ...    Test Case 13 - Oldalhatar Ellenorzese
    ...    Test Case 14 - Betutipus Ellenorzese
    ...    Test Case 15 - Sorkoze Ellenorzese
    ...    Test Case 16 - Labjegyzetek Ellenorzese
    ...    Test Case 17 - Tartalomjegyzek Ellenorzese
    ...    Test Case 18 - Irodalomjegyzek Ellenorzese
    ...    Test Case 19 - Tablazatok Ellenorzese
    ...    Test Case 20 - Szoveg Igazitas Ellenorzese
    ...    Test Case 21 - Oldalszamozas Ellenorzese
    ...    Test Case 22 - Fejlec Lablec Ellenorzese
    ...    Test Case 23 - Helyesiras Ellenorzese
    
    ${passed}=    Set Variable    0
    ${failed}=    Set Variable    0
    ${test_num}=    Set Variable    1
    
    FOR    ${test_case_name}    IN    @{test_case_names}
        ${status}=    Run Keyword And Return Status    
        ...    Run Keyword    ${test_case_name}
        
        IF    ${status}
            ${passed}=    Evaluate    ${passed} + 1
            Log    [${test_num}/24] ${test_case_name} - PASSED    console=yes    level=INFO
        ELSE
            ${failed}=    Evaluate    ${failed} + 1  
            Log    [${test_num}/24] ${test_case_name} - FAILED    console=yes    level=WARN
        END
        
        ${test_num}=    Evaluate    ${test_num} + 1
    END
    
    Log    === ÖSSZESÍTŐ - ${docx_file} ===    console=yes
    Log    Összes teszt: 23 | Sikeres: ${passed} | Sikertelen: ${failed}    console=yes