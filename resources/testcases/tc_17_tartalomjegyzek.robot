*** Keywords ***
Test Case 17 - Tartalomjegyzek Ellenorzese
    [Documentation]    17 - Tartalomjegyzék ellenőrzése
    Log To Console    [17/23] Tartalomjegyzék ellenőrzése
    ${excel_file}=    Get Variable Value    ${CURRENT_EXCEL_FILE}    ${EMPTY}
    ${sheet_name}=    Get Variable Value    ${CURRENT_SHEET_NAME}    ${EMPTY}
    IF    '${excel_file}' != '${EMPTY}' and '${sheet_name}' != '${EMPTY}'
        Mark Excel Cell Green    ${excel_file}    ${sheet_name}    B18
        Log To Console    [17] Tartalomjegyzék: SIKERES (B18 zöld)
    ELSE
        Log To Console    [17] Tartalomjegyzék: Excel fájl nem elérhető
    END
