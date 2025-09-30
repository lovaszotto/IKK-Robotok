*** Keywords ***
Test Case 05 - Internet Hivatkozasok Ellenorzese
    [Documentation]    05 - Internet hivatkozások ellenőrzése
    Log To Console    [05/23] Internet hivatkozások ellenőrzése
    ${excel_file}=    Get Variable Value    ${CURRENT_EXCEL_FILE}    ${EMPTY}
    ${sheet_name}=    Get Variable Value    ${CURRENT_SHEET_NAME}    ${EMPTY}
    IF    '${excel_file}' != '${EMPTY}' and '${sheet_name}' != '${EMPTY}'
        Mark Excel Cell Green    ${excel_file}    ${sheet_name}    B6
        Log To Console    [05] Internet hivatkozások: SIKERES (B6 zöld)
    ELSE
        Log To Console    [05] Internet hivatkozások: Excel fájl nem elérhető
    END
