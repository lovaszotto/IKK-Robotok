*** Keywords ***
Test Case 04 - Szerkesztoi Instrukciok Ellenorzese
    [Documentation]    04 - Szerkesztői instrukciók ellenőrzése
    Log To Console    [04/23] Szerkesztői instrukciók ellenőrzése
    ${excel_file}=    Get Variable Value    ${CURRENT_EXCEL_FILE}    ${EMPTY}
    ${sheet_name}=    Get Variable Value    ${CURRENT_SHEET_NAME}    ${EMPTY}
    IF    '${excel_file}' != '${EMPTY}' and '${sheet_name}' != '${EMPTY}'
        Mark Excel Cell Green    ${excel_file}    ${sheet_name}    B5
        Log To Console    [04] Szerkesztői instrukciók: SIKERES (B5 zöld)
    ELSE
        Log To Console    [04] Szerkesztői instrukciók: Excel fájl nem elérhető
    END
