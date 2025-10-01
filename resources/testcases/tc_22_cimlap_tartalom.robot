*** Keywords ***
Test Case 22 - Cimlap Tartalom Ellenorzese
    [Documentation]    22 - Címlap tartalom ellenőrzése
    Log To Console    [22/23] Címlap tartalom ellenőrzése
    ${excel_file}=    Get Variable Value    ${CURRENT_EXCEL_FILE}    ${EMPTY}
    ${sheet_name}=    Get Variable Value    ${CURRENT_SHEET_NAME}    ${EMPTY}
    IF    '${excel_file}' != '${EMPTY}' and '${sheet_name}' != '${EMPTY}'
        Mark Excel Cell Green    ${excel_file}    ${sheet_name}    B23
    Log To Console    [22] Címlap tartalom: SIKERES (B23 zöld)
    ELSE
    Log To Console    [22] Címlap tartalom: Excel fájl nem elérhető
    END
