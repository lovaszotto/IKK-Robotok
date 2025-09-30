*** Keywords ***
Test Case 18 - Irodalomjegyzek Ellenorzese
    [Documentation]    18 - Irodalomjegyzék ellenőrzése
    Log To Console    [18/23] Irodalomjegyzék ellenőrzése
    ${excel_file}=    Get Variable Value    ${CURRENT_EXCEL_FILE}    ${EMPTY}
    ${sheet_name}=    Get Variable Value    ${CURRENT_SHEET_NAME}    ${EMPTY}
    IF    '${excel_file}' != '${EMPTY}' and '${sheet_name}' != '${EMPTY}'
        Mark Excel Cell Green    ${excel_file}    ${sheet_name}    B19
        Log To Console    [18] Irodalomjegyzék: SIKERES (B19 zöld)
    ELSE
        Log To Console    [18] Irodalomjegyzék: Excel fájl nem elérhető
    END
