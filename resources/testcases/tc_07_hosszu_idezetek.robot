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
    RETURN
    ${docx_json}=    Get Variable Value    ${DOCX_JSON}    ${EMPTY}

    #${all}=    Read Docx All    ${docx_file}
    ${text}=    Catenate    SEPARATOR=\n    @{docx_json['paragraphs']}
    #@{char_list}=    Split String    ${text}    separator=''
    @{char_list}=    Evaluate    list('${text}')    # Convert to list explicitly
    Log To Console    ${char_list}
    ${quote_indexes}=    Create List
    ${index}=    Set Variable    0
    
    FOR    ${c}    IN    @{char_list}
         Log To Console     találat: ${c} index: ${index}
    
        #IF    '${c}' in ['"', '„', '”', '“', '»', '«']   
        IF    '"' in '${c}'
            Append To List    ${quote_indexes}    ${index}
            Log To Console    Idézőjel találat: ${c} index: ${index}
        END    
        ${index}=    Convert To Integer    ${index}
        ${index}=    Set Variable    ${index + 1}
    END
    Log To Console    Idézőjelek indexei:${index} ${quote_indexes}
    ${max_distance}=    Set Variable    0
    ${quote_count}=    Get Length    ${quote_indexes}
    FOR    ${i}    IN RANGE    0    ${quote_count}    2
        ${start}=    Get From List    ${quote_indexes}    ${i}
        ${end}=    Get From List    ${quote_indexes}    ${i+1}
    ${distance}=    Evaluate    ${end} - ${start}
        Log To Console   Idézőjelek közti távolság: ${distance}
        Run Keyword If    ${distance} > ${max_distance}    Set Variable    ${max_distance}    ${distance}
    END
    Log To Console   Max idézőjelek közti távolság: ${max_distance}
    Run Keyword If    ${max_distance} >= 10000    Fail    Túl hosszú idézet: ${max_distance} karakter az idézőjelek között!
