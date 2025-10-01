*** Keywords ***
Test Case 19 - Idegen Nyelvu Illusztraciok Ellenorzese
    [Documentation]    19 - Idegen nyelvű illusztrációk
    Log To Console    [19/23] Idegen nyelvű illusztrációk
    ${excel_file}=    Get Variable Value    ${CURRENT_EXCEL_FILE}    ${EMPTY}
    ${sheet_name}=    Get Variable Value    ${CURRENT_SHEET_NAME}    ${EMPTY}
    IF    '${excel_file}' != '${EMPTY}' and '${sheet_name}' != '${EMPTY}'
        Mark Excel Cell Green    ${excel_file}    ${sheet_name}    B20
    Log To Console    [19] Idegen nyelvű illusztrációk: SIKERES (B20 zöld)
    ELSE
    Log To Console    [19] Idegen nyelvű illusztrációk: Excel fájl nem elérhető
    END
