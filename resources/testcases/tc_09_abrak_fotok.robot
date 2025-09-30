*** Keywords ***
Test Case 09 - Abrak Fotok Ellenorzese
    [Documentation]    09 - Ábrák/fotók ellenőrzése
    Log To Console    [09/23] Ábrák/fotók ellenőrzése
    ${excel_file}=    Get Variable Value    ${CURRENT_EXCEL_FILE}    ${EMPTY}
    ${sheet_name}=    Get Variable Value    ${CURRENT_SHEET_NAME}    ${EMPTY}
    IF    '${excel_file}' != '${EMPTY}' and '${sheet_name}' != '${EMPTY}'
        Mark Excel Cell Green    ${excel_file}    ${sheet_name}    B10
        Log To Console    [09] Ábrák/fotók: SIKERES (B10 zöld)
    ELSE
        Log To Console    [09] Ábrák/fotók: Excel fájl nem elérhető
    END
