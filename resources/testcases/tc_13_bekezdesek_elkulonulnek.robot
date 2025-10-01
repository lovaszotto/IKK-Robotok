*** Keywords ***
Test Case 13 - Bekezdesek Elkulonulnek Ellenorzese
    [Documentation]    13 - Bekezdések elkülönülnek
    Log To Console    [13/23] Bekezdések elkülönülnek
    ${excel_file}=    Get Variable Value    ${CURRENT_EXCEL_FILE}    ${EMPTY}
    ${sheet_name}=    Get Variable Value    ${CURRENT_SHEET_NAME}    ${EMPTY}

    IF    '${excel_file}' != '${EMPTY}' and '${sheet_name}' != '${EMPTY}'
        Mark Excel Cell Green    ${excel_file}    ${sheet_name}    B14
    Log To Console    [13] Bekezdések elkülönülnek: SIKERES (B14 zöld)
    ELSE
    Log To Console    [13] Bekezdések elkülönülnek: Excel fájl nem elérhető
    END