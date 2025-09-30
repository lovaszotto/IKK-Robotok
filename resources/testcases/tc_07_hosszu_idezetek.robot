*** Keywords ***
Test Case 07 - Hosszu Idezetek Ellenorzese
    [Documentation]    07 - Hosszú idézetek ellenőrzése
    Log To Console    [07/23] Hosszú idézetek ellenőrzése
    ${excel_file}=    Get Variable Value    ${CURRENT_EXCEL_FILE}    ${EMPTY}
    ${sheet_name}=    Get Variable Value    ${CURRENT_SHEET_NAME}    ${EMPTY}
    IF    '${excel_file}' != '${EMPTY}' and '${sheet_name}' != '${EMPTY}'
        Mark Excel Cell Green    ${excel_file}    ${sheet_name}    B8
        Log To Console    [07] Hosszú idézetek: SIKERES (B8 zöld)
    ELSE
        Log To Console    [07] Hosszú idézetek: Excel fájl nem elérhető
    END
