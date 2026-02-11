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
    Log String To Console     \n\[07/24] +++++++++++++++++++++++++++ Hosszú idézetek ellenőrzése 
    
    ${docx_json}=    Get Variable Value    ${DOCX_JSON}    ${EMPTY}
    ${docx_file}=    Get Variable Value    ${DOCX_FILE}    ${EMPTY}
   ${testCase_row}=    Set Variable    9
    ${excel_file}=    Get Variable Value    ${CURRENT_EXCEL_FILE}    ${EMPTY}
    ${sheet_name}=    Get Variable Value    ${CURRENT_SHEET_NAME}    ${EMPTY}
    ${err_msg}=    Set Variable    ${EMPTY}

    #${all}=    Read Docx All    ${docx_file}
    ${text}=    Catenate    SEPARATOR=\n    @{docx_json['paragraphs']}
    ${text1_length}=    Get Length    ${text}
    ${quote_indexes}=    Create List
    ${is_start}=    Set Variable    0
    ${start_idx}=    Set Variable    0
    ${end_idx}=    Set Variable    0
    ${sample}=       Set Variable    ''

    ${max_distance}=    Set Variable    0
      #XML formában olvassuk be a docx fájlt a szövegek ellenőrzéséhez
     ${read_status}    ${xmlAllText}=    Run Keyword And Ignore Error    Read Docx All as XML    ${docx_file}
   #dobd ki a \n karaktereket az xmlAllText-ből
    ${xmlAllText}=    Replace String    ${xmlAllText}    \n    ''
    #ird ki az xmlAllText tartalmát egy xml_alltext.txt fájlba felülírással
    #Append To File    xml_alltext.txt    ${xmlAllText}

    ${matches}=    Get Regexp Matches    ${xmlAllText}    \„(.*?)\”
    #Log String To Console    Talált idézetek száma: ${matches}
    ${max_distance}=    Set Variable    0
    FOR    ${item}    IN    @{matches}
        ${item_length}=    Get Length    ${item}
        #Log To Console    ${item} hossza: ${item_length}
        IF    ${item_length} > ${max_distance}
            ${max_distance}=    Set Variable    ${item_length}
            ${max_sample}=       Set Variable    ${item}        
        END        
    END
    #irjuk ki a tömb méretét
     Log String To Console   Max idézőjelek közti távolság: ${max_distance}
 
    IF    ${max_distance} >= 10000      
       ${err_msg}=    Set Variable        Túl hosszú idézet: ${max_distance} karakter az idézőjelek között!;(${max_sample}[0:100])
    END

    Mark Test Status    ${excel_file}    ${sheet_name}    ${testCase_row}    ${err_msg}
