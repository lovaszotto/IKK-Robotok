*** Settings ***
Library     Collections
# RPA.RobotLogListener eltávolítva – nem használt és hiányzó modul hibát okozott
Resource    ${CURDIR}/../keywords.robot
Resource    ${CURDIR}/../../PLG-02-Excel-kitolto.robot

*** Keywords ***
Test Case 06 - Szerzo Lektor Ellenorzese
    [Documentation]    06 - Szerző-lektor ellenőrzése
    Log String To Console    \n\[06/24] Szerző-lektor ellenőrzése

    ${excel_file}=    Get Variable Value    ${CURRENT_EXCEL_FILE}    ${EMPTY}
    ${sheet_name}=    Get Variable Value    ${CURRENT_SHEET_NAME}    ${EMPTY}
    ${testCase_row}=    Set Variable    8
    ${path_part}=    Get Variable Value    ${CURRENT_PATH_PART}    ${EMPTY}
    ${filename_part}=    Get Variable Value    ${CURRENT_FILENAME_PART}    ${EMPTY}
    ${docx_file}=    Get Variable Value    ${DOCX_FILE}    ${EMPTY}
    ${docx_json}=    Get Variable Value    ${DOCX_JSON}    ${EMPTY}
    ${err_msg}=    Set Variable    ${EMPTY}
    ${CR}=    Set Variable    ;
    # Ellenőrizd, hogy a docx_json tényleg dictionary, különben hibát jelezz
    ${is_dict}=    Evaluate    isinstance(${docx_json}, dict)
    IF    not ${is_dict}
        ${err_msg}=    Set Variable    DOCX_JSON nem elérhető vagy nem megfelelő típus (${docx_json})
        Log String To Console    [ERROR] ${err_msg}
    ELSE
        TRY
            ${tables}=    Get From Dictionary    ${docx_json}    tables
        EXCEPT    AS    ${e}
            ${tables}=    Set Variable    ${EMPTY}
            ${err_msg}=    Set Variable    DOCX_JSON['tables'] nem található (${e})
            Log String To Console    [ERROR] ${err_msg}
        END
        ${is_tables_list}=    Evaluate    isinstance(${tables}, list)
        IF    not ${is_tables_list}
            ${err_msg}=    Set Variable    DOCX_JSON['tables'] nem lista vagy hiányzik (${tables})
            Log String To Console    [ERROR] ${err_msg}
        ELSE
            TRY
                ${first_table}=    Get From List    ${tables}    0
                ${clean}=    Evaluate    {k.rstrip(':').strip(): v.strip() for k, v in dict(${first_table}).items()}
                #Log String To Console    >>>> ${clean}
                ${err_msg}=    Szerzo Lektor Ellenorzesek    ${clean}    ${CR}    ${err_msg}
            EXCEPT    AS    ${e}
                ${first_table}=    Set Variable    ${EMPTY}
                Log String To Console    [ERROR] Címtábla nem elérhető vagy hibás megnevezéseket tartalmaz!: (${e})
                ${err_msg}=    Set Variable    Címtábla nem elérhető vagy hibás megnevezéseket tartalmaz, ezért a szerző-lektor ellenőrzés nem hajtható végre!
            END
        END
    END
    Mark Test Status    ${excel_file}    ${sheet_name}    ${testCase_row}    ${err_msg}

Szerzo Lektor Ellenorzesek
    [Arguments]    ${clean}    ${CR}    ${err_msg}
    ${szerzo}=    Get From Dictionary    ${clean}    Kéziratíró
    #Log String To Console    >>>>>>>>>>>>>>>>>>>>>>>>>>> Szerző: ${szerzo}
    IF    $szerzo == '' or $szerzo == '#'
        ${new_err}=    Set Variable    A Kéziratíró mező nem létezik, vagy üres!
        IF    $err_msg == ''
            ${err_msg}=    Set Variable    ${new_err}
        ELSE
            ${err_msg}=    Catenate    SEPARATOR=${CR}    ${err_msg}    ${new_err}
        END
        Log String To Console    [ERROR] ${new_err}
    END
    ${szakmai_lektor}=    Get From Dictionary    ${clean}    Szakmai lektor
    #Log String To Console    >>>>>>>>>>>>>>>>>>>>>>>>>>> Szakmai lektor: ${szakmai_lektor}
    IF    $szakmai_lektor == '' or $szakmai_lektor == '#'
        ${new_err}=    Set Variable    A Szakmai lektor mező nem létezik, vagy üres!
        IF    $err_msg == ''
            ${err_msg}=    Set Variable    ${new_err}
        ELSE
            ${err_msg}=    Catenate    SEPARATOR=${CR}    ${err_msg}    ${new_err}
        END
        Log String To Console    [ERROR] ${new_err}
    END
    #szerzőben és lektorban cseréljük le a ; , re
    ${szerzo}=    Replace String    ${szerzo}    ;    ,
    ${szakmai_lektor}=    Replace String    ${szakmai_lektor}    ;    ,
    ${DOC_SZERZO}=    Set Global Variable    ${szerzo}    ${EMPTY}
    ${DOC_SZAKMAI_LEKTOR}=    Set Global Variable    ${szakmai_lektor}    ${EMPTY}

    ${szerzo_list}=    Split String    ${szerzo}    ,
    ${szakmai_lektor_list}=    Split String    ${szakmai_lektor}    ,
    #Log String To Console    Szerző lista: ${szerzo_list}
    #Log String To Console    Lektor lista: ${szakmai_lektor_list}
    FOR    ${szerzo_item}    IN    @{szerzo_list}
        FOR    ${lektor_item}    IN    @{szakmai_lektor_list}
            ${szerzo_item}=    Strip String    ${szerzo_item}
            ${lektor_item}=    Strip String    ${lektor_item}
            #Log String To Console    Compare:${szerzo_item} and ${lektor_item}
            IF    '${szerzo_item}' == '${lektor_item}'
                #Log String To Console    Megegyezik a szerző és a lektor: ${szerzo_item}
                ${new_err}=    Set Variable    A Kéziratíró és a Szakmai lektor nem lehet azonos!
                IF    $err_msg == ''
                    ${err_msg}=    Set Variable    ${new_err}
                ELSE
                    ${err_msg}=    Catenate    SEPARATOR=${CR}    ${err_msg}    ${new_err}
                END
                BREAK
            END
        END
    END
    RETURN    ${err_msg}