*** Keywords ***
Test Case 15 - Sorkoze Ellenorzese
    [Documentation]    15 - Sorköze ellenőrzése
    Log To Console    [15/23] Sorköze ellenőrzése
    ${excel_file}=    Get Variable Value    ${CURRENT_EXCEL_FILE}    ${EMPTY}
    ${sheet_name}=    Get Variable Value    ${CURRENT_SHEET_NAME}    ${EMPTY}
    IF    '${excel_file}' != '${EMPTY}' and '${sheet_name}' != '${EMPTY}'
        Mark Excel Cell Green    ${excel_file}    ${sheet_name}    B16
        Log To Console    [15] Sorköze: SIKERES (B16 zöld)
    ELSE
        Log To Console    [15] Sorköze: Excel fájl nem elérhető
    END
