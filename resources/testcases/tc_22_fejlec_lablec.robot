*** Keywords ***
Test Case 22 - Fejlec Lablec Ellenorzese
    [Documentation]    22 - Fejléc/lábléc ellenőrzése
    Log To Console    [22/23] Fejléc/lábléc ellenőrzése
    ${excel_file}=    Get Variable Value    ${CURRENT_EXCEL_FILE}    ${EMPTY}
    ${sheet_name}=    Get Variable Value    ${CURRENT_SHEET_NAME}    ${EMPTY}
    IF    '${excel_file}' != '${EMPTY}' and '${sheet_name}' != '${EMPTY}'
        Mark Excel Cell Green    ${excel_file}    ${sheet_name}    B23
        Log To Console    [22] Fejléc/lábléc: SIKERES (B23 zöld)
    ELSE
        Log To Console    [22] Fejléc/lábléc: Excel fájl nem elérhető
    END
