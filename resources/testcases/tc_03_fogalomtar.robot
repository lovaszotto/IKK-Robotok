*** Keywords ***
Test Case 03 - Fogalomtar Ellenorzese
    [Documentation]    03 - Fogalomtár ellenőrzése
    Log To Console    [03/23] Fogalomtár ellenőrzése
    ${excel_file}=    Get Variable Value    ${CURRENT_EXCEL_FILE}    ${EMPTY}
    ${sheet_name}=    Get Variable Value    ${CURRENT_SHEET_NAME}    ${EMPTY}
    IF    '${excel_file}' != '${EMPTY}' and '${sheet_name}' != '${EMPTY}'
        Mark Excel Cell Green    ${excel_file}    ${sheet_name}    B4
        Log To Console    [03] Fogalomtár: SIKERES (B4 zöld)
    ELSE
        Log To Console    [03] Fogalomtár: Excel fájl nem elérhető
    END
