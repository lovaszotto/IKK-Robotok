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
     ${kezirat_iro_idx}=    Set Variable    -1
     ${kezirat_iro_idx}=    Set Variable    -1
    ${kezirat_iro}=    Set Variable    ${EMPTY}
    ${szakmai_lektor}=    Set Variable    ${EMPTY}

  #XML formában olvassuk be a docx fájlt a szövegek ellenőrzéséhez
   Log String To Console   Read docx as XML file: ${docx_file}
     ${read_status}    ${xmlAllText}=    Run Keyword And Ignore Error    Read Docx All as XML    ${docx_file}
    @{xml_lines}=    Split To Lines    ${xmlAllText}
    ${idx}=    Set Variable    0
    #törli a xml_line.txt fájlt, ha létezik
    Run Keyword And Ignore Error    Remove File    xml_line.txt
    FOR    ${line}    IN    @{xml_lines}
        #Log To Console    ${idx}:${line}
        Append To File    xml_line.txt    ${idx}:${line}\n
         IF     'Kéziratíró' in '''${line}''' 
            ${kezirat_iro_idx}=    Set Variable    ${idx}+1
            ${kezirat_iro}=    Set Variable    ${xml_lines[${kezirat_iro_idx}]}
         Log String To Console    [DEBUG] Kéziratíró sort tartalmazó xml sor(${idx}): ${line}
         Log String To Console    [DEBUG] Kéziratíró neve: ${kezirat_iro}
           
        END
        IF     'Szakmai lektor' in '''${line}'''
            ${szakmai_lektor_idx}=    Set Variable    ${idx}+1
            ${szakmai_lektor}=    Set Variable        ${xml_lines[${szakmai_lektor_idx}]}
            Log String To Console    [DEBUG] Szakmai lektor sort tartalmazó xml sor(${idx}): ${line}
            Log String To Console    [DEBUG] Szakmai lektor neve: ${szakmai_lektor}
           
        END
        ${idx}=    Evaluate    ${idx} + 1
    END
   
    ${err_msg}=    Szerzo Lektor Ellenorzesek    ${kezirat_iro}    ${szakmai_lektor}    ${err_msg}
 
    Mark Test Status    ${excel_file}    ${sheet_name}    ${testCase_row}    ${err_msg}

Szerzo Lektor Ellenorzesek
    [Arguments]     ${szerzo}    ${szakmai_lektor}     ${err_msg}
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
    # Ensure no None values before further processing
    ${szerzo}=    Get Variable Value    ${szerzo}    ${EMPTY}
    ${szakmai_lektor}=    Get Variable Value    ${szakmai_lektor}    ${EMPTY}
    
    #globális változókba mentés

    ${upper_szerzo}=    Convert To Uppercase    ${szerzo}
    Set Global Variable       ${DOKUMENTUM_SZERZO}     ${upper_szerzo}    
     Log String To Console    [SAVE] Dokumentum szerző elmentve: ${DOKUMENTUM_SZERZO}
     
    ${upper_szakmai_lektor}=    Convert To Uppercase    ${szakmai_lektor}
    Set Global Variable        ${DOKUMENTUM_SZAKMAI_LEKTOR}     ${upper_szakmai_lektor}   
    Log String To Console    [SAVE] Dokumentum szakmai lektor elmentve: ${DOKUMENTUM_SZAKMAI_LEKTOR}

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