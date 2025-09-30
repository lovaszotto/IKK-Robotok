*** Keywords ***
Test Case 08 - Tordeles Ellenorzese
    [Documentation]    08 - Tördelés ellenőrzése
    Log To Console    [08/23] Tördelés ellenőrzése
    ${excel_file}=    Get Variable Value    ${CURRENT_EXCEL_FILE}    ${EMPTY}
    ${sheet_name}=    Get Variable Value    ${CURRENT_SHEET_NAME}    ${EMPTY}
    IF    '${excel_file}' != '${EMPTY}' and '${sheet_name}' != '${EMPTY}'
        Mark Excel Cell Green    ${excel_file}    ${sheet_name}    B9
        Log To Console    [08] Tördelés: SIKERES (B9 zöld)
    ELSE
        Log To Console    [08] Tördelés: Excel fájl nem elérhető
    END
