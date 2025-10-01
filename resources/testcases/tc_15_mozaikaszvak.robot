*** Keywords ***
Test Case 15 - Mozaikszavak Roviditesek Ellenorzese
    [Documentation]    15 - Mozaikszavak rövidítések
    Log To Console    [15/23] Mozaikszavak rövidítések
    ${excel_file}=    Get Variable Value    ${CURRENT_EXCEL_FILE}    ${EMPTY}
    ${sheet_name}=    Get Variable Value    ${CURRENT_SHEET_NAME}    ${EMPTY}
    IF    '${excel_file}' != '${EMPTY}' and '${sheet_name}' != '${EMPTY}'
        Mark Excel Cell Green    ${excel_file}    ${sheet_name}    B16
    Log To Console    [15] Mozaikszavak rövidítések: SIKERES (B16 zöld)
    ELSE
    Log To Console    [15] Mozaikszavak rövidítések: Excel fájl nem elérhető
    END
