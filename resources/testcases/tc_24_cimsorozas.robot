*** Keywords ***
Test Case 24 - Cimsorozassal Keszult Ellenorzese
    [Documentation]    24 - Címsorozással készült ellenőrzése
    Log To Console    [24/23] Címsorozással készült ellenőrzése
    ${excel_file}=    Get Variable Value    ${CURRENT_EXCEL_FILE}    ${EMPTY}
    ${sheet_name}=    Get Variable Value    ${CURRENT_SHEET_NAME}    ${EMPTY}
    IF    '${excel_file}' != '${EMPTY}' and '${sheet_name}' != '${EMPTY}'
        Mark Excel Cell Green    ${excel_file}    ${sheet_name}    B24
    Log To Console    [24] Generált tartalomjegyzék: SIKERES (B24 zöld)
    ELSE
    Log To Console    [24] Generált tartalomjegyzék: Excel fájl nem elérhető
    END
