*** Keywords ***
Test Case 19 - Tablazatok Ellenorzese
    [Documentation]    19 - Táblázatok ellenőrzése
    Log To Console    [19/23] Táblázatok ellenőrzése
    ${excel_file}=    Get Variable Value    ${CURRENT_EXCEL_FILE}    ${EMPTY}
    ${sheet_name}=    Get Variable Value    ${CURRENT_SHEET_NAME}    ${EMPTY}
    IF    '${excel_file}' != '${EMPTY}' and '${sheet_name}' != '${EMPTY}'
        Mark Excel Cell Green    ${excel_file}    ${sheet_name}    B20
        Log To Console    [19] Táblázatok: SIKERES (B20 zöld)
    ELSE
        Log To Console    [19] Táblázatok: Excel fájl nem elérhető
    END
