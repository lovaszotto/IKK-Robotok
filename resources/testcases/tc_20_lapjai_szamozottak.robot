*** Settings ***
Library    ${CURDIR}/../../libraries/DocxPageNumbers.py
Resource   ${CURDIR}/../keywords.robot
Resource   ${CURDIR}/../../PLG-02-Excel-kitolto.robot

*** Keywords ***
Test Case 20 - Lapjai Szamozottak Ellenorzese
    [Documentation]    20 - Lapjai számozottak
    Log To Console     \n\[20/24] Lapjai Szamozottak Ellenorzese
 
   ${excel_file}=    Get Variable Value    ${CURRENT_EXCEL_FILE}    ${EMPTY}
    ${sheet_name}=    Get Variable Value    ${CURRENT_SHEET_NAME}    ${EMPTY}
    ${docx_file}=    Get Variable Value    ${DOCX_FILE}    ${EMPTY}

    ${question_row}=    Set Variable    22

    ${err_msg}=    Has Page Numbers    ${docx_file}
    IF    '${err_msg}' != ''
        Log To Console     \n\[ERROR] Oldalszámozás: HIBA - ${err_msg}
    #ELSE
    #    Log To Console     \n\[20] Oldalszámozás: Megtalálható
    END

    # Teszt státusz és Excel jelölés végrehajtása a megadott soron
    Mark Test Status    ${excel_file}    ${sheet_name}    ${question_row}    ${err_msg}

 

