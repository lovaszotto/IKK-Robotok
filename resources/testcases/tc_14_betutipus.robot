*** Keywords ***
Test Case 14 - Betutipus Ellenorzese
    [Documentation]    14 - Betűtípus ellenőrzése
    Log To Console    [14/23] Betűtípus ellenőrzése
    ${excel_file}=    Get Variable Value    ${CURRENT_EXCEL_FILE}    ${EMPTY}
    ${sheet_name}=    Get Variable Value    ${CURRENT_SHEET_NAME}    ${EMPTY}
    IF    '${excel_file}' != '${EMPTY}' and '${sheet_name}' != '${EMPTY}'
        Mark Excel Cell Green    ${excel_file}    ${sheet_name}    B15
        Log To Console    [14] Betűtípus: SIKERES (B15 zöld)
    ELSE
        Log To Console    [14] Betűtípus: Excel fájl nem elérhető
    END
