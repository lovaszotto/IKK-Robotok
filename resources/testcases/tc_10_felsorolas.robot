*** Keywords ***
Test Case 10 - Felsorolas Ellenorzese
    [Documentation]    10 - Felsorolások ellenőrzése
    Log To Console    [10/23] Felsorolások ellenőrzése
    ${excel_file}=    Get Variable Value    ${CURRENT_EXCEL_FILE}    ${EMPTY}
    ${sheet_name}=    Get Variable Value    ${CURRENT_SHEET_NAME}    ${EMPTY}
    IF    '${excel_file}' != '${EMPTY}' and '${sheet_name}' != '${EMPTY}'
        Mark Excel Cell Green    ${excel_file}    ${sheet_name}    B11
        Log To Console    [10] Felsorolások: SIKERES (B11 zöld)
    ELSE
        Log To Console    [10] Felsorolások: Excel fájl nem elérhető
    END
