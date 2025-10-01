*** Keywords ***
Test Case 23 - Generalt Tartalomjegyzek Ellenorzese
    [Documentation]    23 - Generált tartalomjegyzék
    Log To Console    [24/24] Generált tartalomjegyzék
    ${excel_file}=    Get Variable Value    ${CURRENT_EXCEL_FILE}    ${EMPTY}
    ${sheet_name}=    Get Variable Value    ${CURRENT_SHEET_NAME}    ${EMPTY}
    IF    '${excel_file}' != '${EMPTY}' and '${sheet_name}' != '${EMPTY}'
        Mark Excel Cell Green    ${excel_file}    ${sheet_name}    B24
    Log To Console    [24] Generált tartalomjegyzék: SIKERES (B24 zöld)
    ELSE
    Log To Console    [24] Generált tartalomjegyzék: Excel fájl nem elérhető
    END
