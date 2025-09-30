*** Settings ***
Library    ${CURDIR}/../../libraries/DocxPageNumbers.py
Resource   ${CURDIR}/../keywords.robot
Resource   ${CURDIR}/../../PLG-02-Excel-kitolto.robot

*** Keywords ***
Test Case 21 - Oldalszamozas Ellenorzese
    [Documentation]    21 - Oldalszámozás ellenőrzése. Ellenőrizendő, hogy a kézirat oldalai egységes formátumban számozottak-e. 

    ${excel_file}=    Get Variable Value    ${CURRENT_EXCEL_FILE}    ${EMPTY}
    ${sheet_name}=    Get Variable Value    ${CURRENT_SHEET_NAME}    ${EMPTY}
    ${docx_file}=    Get Variable Value    ${DOCX_FILE}    ${EMPTY}

    ${question_row}=    Set Variable    22
    ${col_present}=    Set Variable    3
    ${col_missing}=    Set Variable    4

    Log To Console    [21] Ellenőrzött DOCX: ${docx_file}
    ${has}=    Has Page Numbers    ${docx_file}
    Log To Console    [21] Oldalszámozás detektálás eredménye: ${has}
    #Dokumentum Oldalszámozás Kötelező
    IF    ${has}
        Log To Console    [21] Oldalszámozás: Megtalálható
        Fill Excel Cell    ${excel_file}    ${sheet_name}    ${question_row}    ${col_present}    X
        Log To Console    [21] Jelölés: X beírva a C${question_row} cellába
    ELSE
        Log To Console    [21] Oldalszámozás: NINCS megadva
        Fill Excel Cell    ${excel_file}    ${sheet_name}    ${question_row}    ${col_missing}    X
        Log To Console    [21] Jelölés: X beírva a D${question_row} cellába
        #Hiba jelzés, fail de fut tovább
        Run Keyword And Continue On Failure    Fail    [21] Oldalszámozás: HIBA (X a D${question_row})
    END

 


 
