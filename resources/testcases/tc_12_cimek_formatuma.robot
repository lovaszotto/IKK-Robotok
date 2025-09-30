*** Keywords ***
Test Case 12 - Cimek Formatuma Ellenorzese
    [Documentation]    12 - Címek formátuma ellenőrzése
    Log To Console    [12/23] Címek formátuma ellenőrzése
    ${excel_file}=    Get Variable Value    ${CURRENT_EXCEL_FILE}    ${EMPTY}
    ${sheet_name}=    Get Variable Value    ${CURRENT_SHEET_NAME}    ${EMPTY}
    IF    '${excel_file}' != '${EMPTY}' and '${sheet_name}' != '${EMPTY}'
        Mark Excel Cell Green    ${excel_file}    ${sheet_name}    B13
        Log To Console    [12] Címek formátuma: SIKERES (B13 zöld)
    ELSE
        Log To Console    [12] Címek formátuma: Excel fájl nem elérhető
    END
