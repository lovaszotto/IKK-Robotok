*** Settings ***
Library    ../../libraries/DocxReader.py
Library    OperatingSystem
Library    String
Library    Collections
Library    ../../libraries/DocxXmlExtractor.py
Resource   ${CURDIR}/../keywords.robot
Resource   ${CURDIR}/../../PLG-02-Excel-kitolto.robot

*** Keywords ***
Test Case 07 - Hosszu Idezetek Ellenorzese
    [Documentation]    07 - Hosszú idézetek ellenőrzése
    Log To Console     \n\[07/24] +++++++++++++++++++++++++++ Hosszú idézetek ellenőrzése
    #RETURN
    ${docx_json}=    Get Variable Value    ${DOCX_JSON}    ${EMPTY}
   ${testCase_row}=    Set Variable    9
    ${excel_file}=    Get Variable Value    ${CURRENT_EXCEL_FILE}    ${EMPTY}
    ${sheet_name}=    Get Variable Value    ${CURRENT_SHEET_NAME}    ${EMPTY}

    #${all}=    Read Docx All    ${docx_file}
    ${text}=    Catenate    SEPARATOR=\n    @{docx_json['paragraphs']}
    ${text1_length}=    Get Length    ${text}
    ${quote_indexes}=    Create List
    ${is_start}=    Set Variable    0
    ${start_idx}=    Set Variable    0
    ${end_idx}=    Set Variable    0
    ${sample}=       Set Variable    ''

    ${max_distance}=    Set Variable    0
    ${max_sample}=       Set Variable    ''
    
    Log To Console    Teljes szöveg JSON hossza: ${text1_length} karakter
    @{char_list}=    Create List
    FOR    ${i}    IN RANGE    0    ${text1_length}
        ${c}=    Get Substring    ${text}    ${i}    ${i+1}
        # Ha idézőjelek között vagyunk, fűzzük hozzá a karaktert a sample-hoz
        IF    ${is_start} == 1
            ${sample_length}=    Get Length    ${sample}
            IF    ${sample_length} < 50
                ${sample}=    Set Variable    ${sample}${c}
            END
        END
        IF    $c == '"' or $c == '„' or $c == '”' or $c == '“' or $c == '»' or $c == '«'
            #Log To Console    Idézőjel találat: ${c} index: ${i}
            IF     ${is_start} == 0
                ${is_start}=    Set Variable    1
                ${start_idx}=    Set Variable    ${i}
                 ${sample}=       Set Variable    ${c}
            ELSE
                ${is_start}=    Set Variable    0
                ${end_idx}=    Set Variable    ${i}
                 ${distance}=    Evaluate    ${end_idx} - ${start_idx}
                Log To Console    ${i}:Idézőjelek közti távolság: ${distance} ${sample}
                IF  ${distance} > ${max_distance}    
                    ${max_distance}=    Set Variable    ${distance}
                    ${max_sample}=       Set Variable    ${sample}
                END
            END
        END    
    END
    #irjuk ki a tömb méretét
     Log To Console   Max idézőjelek közti távolság: ${max_distance}
 
    IF    ${max_distance} >= 40    #10000    
       ${err_msg}=    Set Variable        Túl hosszú idézet: ${max_distance} karakter az idézőjelek között!(${max_sample})
    ELSE
       ${err_msg}=    Set Variable        ''
    END

      Mark Test Status    ${excel_file}    ${sheet_name}    ${testCase_row}    ${err_msg}
