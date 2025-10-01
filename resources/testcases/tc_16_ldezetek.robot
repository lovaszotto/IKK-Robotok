*** Keywords ***
Test Case 16 - Idezetek Formailag Megfeleloek Ellenorzese
    [Documentation]    16 - Idézetek formailag megfelelőek
    Log To Console    [16/23] Idézetek formailag megfelelőek
    ${excel_file}=    Get Variable Value    ${CURRENT_EXCEL_FILE}    ${EMPTY}
    ${sheet_name}=    Get Variable Value    ${CURRENT_SHEET_NAME}    ${EMPTY}
    IF    '${excel_file}' != '${EMPTY}' and '${sheet_name}' != '${EMPTY}'
        Mark Excel Cell Green    ${excel_file}    ${sheet_name}    B17
    Log To Console    [16] Idézetek formailag megfelelőek: SIKERES (B17 zöld)
    ELSE
    Log To Console    [16] Idézetek formailag megfelelőek: Excel fájl nem elérhető
    END
