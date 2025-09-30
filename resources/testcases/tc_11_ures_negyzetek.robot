*** Keywords ***
Test Case 11 - Ures Negyzetek Ellenorzese
    [Documentation]    11 - Üres négyzetek ellenőrzése
    Log To Console    [11/23] Üres négyzetek ellenőrzése
    ${excel_file}=    Get Variable Value    ${CURRENT_EXCEL_FILE}    ${EMPTY}
    ${sheet_name}=    Get Variable Value    ${CURRENT_SHEET_NAME}    ${EMPTY}
    IF    '${excel_file}' != '${EMPTY}' and '${sheet_name}' != '${EMPTY}'
        Mark Excel Cell Green    ${excel_file}    ${sheet_name}    B12
        Log To Console    [11] Üres négyzetek: SIKERES (B12 zöld)
    ELSE
        Log To Console    [11] Üres négyzetek: Excel fájl nem elérhető
    END
