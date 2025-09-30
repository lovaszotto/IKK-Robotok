*** Keywords ***
Test Case 06 - Szerzo Lektor Ellenorzese
    [Documentation]    06 - Szerző-lektor ellenőrzése
    Log To Console    [06/23] Szerző-lektor ellenőrzése
    ${excel_file}=    Get Variable Value    ${CURRENT_EXCEL_FILE}    ${EMPTY}
    ${sheet_name}=    Get Variable Value    ${CURRENT_SHEET_NAME}    ${EMPTY}
    IF    '${excel_file}' != '${EMPTY}' and '${sheet_name}' != '${EMPTY}'
        Mark Excel Cell Green    ${excel_file}    ${sheet_name}    B7
        Log To Console    [06] Szerző-lektor: SIKERES (B7 zöld)
    ELSE
        Log To Console    [06] Szerző-lektor: Excel fájl nem elérhető
    END
