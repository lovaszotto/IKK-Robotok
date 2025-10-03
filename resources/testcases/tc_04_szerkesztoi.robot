*** Settings ***
Library     Collections
Resource    ${CURDIR}/../keywords.robot
Resource    ${CURDIR}/../../PLG-02-Excel-kitolto.robot
   
*** Keywords ***
Test Case 04 - Szerkesztoi Instrukciok Ellenorzese
    [Documentation]    04 - Szerkesztői instrukciók ellenőrzése
    Log To Console    [04/23] Szerkesztői instrukciók ellenőrzése
    ${excel_file}=    Get Variable Value    ${CURRENT_EXCEL_FILE}    ${EMPTY}
    ${sheet_name}=    Get Variable Value    ${CURRENT_SHEET_NAME}    ${EMPTY}
    ${testCase_row}=    Set Variable    6

    ${path_part}=    Get Variable Value    ${CURRENT_PATH_PART}    ${EMPTY}
    ${filename_part}=    Get Variable Value    ${CURRENT_FILENAME_PART}    ${EMPTY}
    ${docx_file}=    Get Variable Value    ${DOCX_FILE}    ${EMPTY}
    ${docx_json}=    Get Variable Value    ${DOCX_JSON}    ${EMPTY}
    ${err_msg}=    Set Variable    ${EMPTY}
    ${CR}=    Evaluate    chr(13)

    # Szerkesztői instrukciók, megjegyzések/korrektúrák ellenőrzése a DOCX_JSON alapján
    ${docx_json}=    Get Variable Value    ${DOCX_JSON}    ${EMPTY}
    ${err_msg}=    Set Variable    ${EMPTY}
    # Feltételezzük, hogy a DOCX_JSON tartalmaz egy 'comments' vagy 'tracked_changes' kulcsot, ha van ilyen
    ${has_comments}=    Run Keyword And Return Status    Dictionary Should Contain Key    ${docx_json}    comments
    ${has_tracked}=    Run Keyword And Return Status    Dictionary Should Contain Key    ${docx_json}    tracked_changes
    IF    ${has_comments}
        ${comments}=    Get From Dictionary    ${docx_json}    comments
        ${len_comments}=    Get Length    ${comments}
        IF    ${len_comments} > 0
            ${err_msg}=    Set Variable    Szerkesztői megjegyzés található a dokumentumban!
        END
    END
    IF    ${has_tracked}
        ${tracked}=    Get From Dictionary    ${docx_json}    tracked_changes
        ${len_tracked}=    Get Length    ${tracked}
        IF    ${len_tracked} > 0
            ${err_msg}=    Set Variable    Szerkesztői korrektúra található a dokumentumban!
        END
    END
    Mark Test Status    ${excel_file}    ${sheet_name}    ${testCase_row}    ${err_msg}
