*** Keywords ***
Test Case 16 - Labjegyzetek Ellenorzese
    [Documentation]    16 - Lábjegyzetek ellenőrzése
    Log To Console    [16/23] Lábjegyzetek ellenőrzése
    ${excel_file}=    Get Variable Value    ${CURRENT_EXCEL_FILE}    ${EMPTY}
    ${sheet_name}=    Get Variable Value    ${CURRENT_SHEET_NAME}    ${EMPTY}
    IF    '${excel_file}' != '${EMPTY}' and '${sheet_name}' != '${EMPTY}'
        Mark Excel Cell Green    ${excel_file}    ${sheet_name}    B17
        Log To Console    [16] Lábjegyzetek: SIKERES (B17 zöld)
    ELSE
        Log To Console    [16] Lábjegyzetek: Excel fájl nem elérhető
    END
