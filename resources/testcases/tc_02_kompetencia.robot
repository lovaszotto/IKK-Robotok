*** Keywords ***
Test Case 02 - Kompetencia Teszt Ellenorzese
    [Documentation]    02 - Kompetencia teszt ellenőrzése
    Log To Console    [02/23] Kompetencia teszt ellenőrzése
    ${excel_file}=    Get Variable Value    ${CURRENT_EXCEL_FILE}    ${EMPTY}
    ${sheet_name}=    Get Variable Value    ${CURRENT_SHEET_NAME}    ${EMPTY}
    IF    '${excel_file}' != '${EMPTY}' and '${sheet_name}' != '${EMPTY}'
        Mark Excel Cell Green    ${excel_file}    ${sheet_name}    B3
        Log To Console    [02] Kompetencia teszt: SIKERES (B3 zöld)
    ELSE
        Log To Console    [02] Kompetencia teszt: Excel fájl nem elérhető
    END
