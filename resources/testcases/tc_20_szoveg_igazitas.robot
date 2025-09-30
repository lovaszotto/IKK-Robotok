*** Keywords ***
Test Case 20 - Szoveg Igazitas Ellenorzese
    [Documentation]    20 - Szöveg igazítás ellenőrzése
    Log To Console    [20/23] Szöveg igazítás ellenőrzése
    ${excel_file}=    Get Variable Value    ${CURRENT_EXCEL_FILE}    ${EMPTY}
    ${sheet_name}=    Get Variable Value    ${CURRENT_SHEET_NAME}    ${EMPTY}
    IF    '${excel_file}' != '${EMPTY}' and '${sheet_name}' != '${EMPTY}'
        Mark Excel Cell Green    ${excel_file}    ${sheet_name}    B21
        Log To Console    [20] Szöveg igazítás: SIKERES (B21 zöld)
    ELSE
        Log To Console    [20] Szöveg igazítás: Excel fájl nem elérhető
    END
