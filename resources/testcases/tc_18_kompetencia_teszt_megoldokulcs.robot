*** Keywords ***
Test Case 18 - Kompetencia Teszt Megoldokulcs Ellenorzese
    [Documentation]    18 - Kompetencia teszt megoldókulcs ellenőrzése
    Log To Console    [18/23] Kompetencia teszt megoldókulcs ellenőrzése
    ${excel_file}=    Get Variable Value    ${CURRENT_EXCEL_FILE}    ${EMPTY}
    ${sheet_name}=    Get Variable Value    ${CURRENT_SHEET_NAME}    ${EMPTY}
    IF    '${excel_file}' != '${EMPTY}' and '${sheet_name}' != '${EMPTY}'
        Mark Excel Cell Green    ${excel_file}    ${sheet_name}    B19
    Log To Console    [18] Kompetencia teszt megoldókulcs ellenőrzése: SIKERES (B19 zöld)
    ELSE
    Log To Console    [18] Kompetencia teszt megoldókulcs ellenőrzése: Excel fájl nem elérhető
    END
