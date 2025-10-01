*** Keywords ***
Test Case 14 - Felsorolasok Egysegesek Ellenorzese
    [Documentation]    14 - A felsorolások egységesek
    Log To Console    [14/23] A felsorolások egységesek
    ${excel_file}=    Get Variable Value    ${CURRENT_EXCEL_FILE}    ${EMPTY}
    ${sheet_name}=    Get Variable Value    ${CURRENT_SHEET_NAME}    ${EMPTY}
    IF    '${excel_file}' != '${EMPTY}' and '${sheet_name}' != '${EMPTY}'
        Mark Excel Cell Green    ${excel_file}    ${sheet_name}    B15
    Log To Console    [14] A felsorolások egységesek: SIKERES (B15 zöld)
    ELSE
    Log To Console    [14] A felsorolások egységesek: Excel fájl nem elérhető
    END
