*** Keywords ***
Test Case 23 - Helyesiras Ellenorzese
    [Documentation]    23 - Helyesírás ellenőrzése
    Log To Console    [23/23] Helyesírás ellenőrzése
    ${excel_file}=    Get Variable Value    ${CURRENT_EXCEL_FILE}    ${EMPTY}
    ${sheet_name}=    Get Variable Value    ${CURRENT_SHEET_NAME}    ${EMPTY}
    IF    '${excel_file}' != '${EMPTY}' and '${sheet_name}' != '${EMPTY}'
        Mark Excel Cell Green    ${excel_file}    ${sheet_name}    B24
        Log To Console    [23] Helyesírás: SIKERES (B24 zöld)
    ELSE
        Log To Console    [23] Helyesírás: Excel fájl nem elérhető
    END
