

*** Settings ***
Library    OperatingSystem
Library    String
Library    Collections
Library    ../../libraries/DocxXmlExtractor.py
Resource   ${CURDIR}/../keywords.robot
Resource   ${CURDIR}/../../PLG-02-Excel-kitolto.robot

*** Keywords ***
Test Case 23 - Generalt Tartalomjegyzek Ellenorzese
    [Documentation]    23 - Generált tartalomjegyzék
    Log String To Console With File     \n\[23/24] Generált tartalomjegyzék
    ${excel_file}=    Get Variable Value    ${CURRENT_EXCEL_FILE}    ${EMPTY}
    ${sheet_name}=    Get Variable Value    ${CURRENT_SHEET_NAME}    ${EMPTY}
    ${question_row}=    Set Variable    25
    ${col_present}=    Set Variable    3
    ${col_missing}=    Set Variable    4
    ${err_msg}=    Set Variable    ${EMPTY}
    #ellenőrizzük, hogy style-ban van-e toc
    ${stilusok}=  Get Variable Value    ${STILUSOK}
    
    ${file_path}=   Get Variable Value    ${DOCX_FILE}    ${EMPTY}
    #Log String To Console    ++++++++++++++++++++++++++++ ${file_path}+++++++++++++++++++++++++++++++++++++++++
    ${entries}=    Extract TOC Entries From Docx File    ${file_path}
    ${filename_part}=   Get Variable Value    ${CURRENT_FILENAME_PART}    ${EMPTY}
    ${toc_count}=    Get Length    ${entries}
    #Log String To Console    Talált TOC sorok száma: ${toc_count}
    #FOR    ${e}    IN    @{entries}
    #    Log String To Console With File    TOC: ${e}
   # END
    #ellenőrizzük, hogy van-e benne toc
    ${toc_count}=    Get Length    ${entries}
    IF    ${toc_count} == 0
            ${err_msg}=    Set Variable    Nincs generált tartalomjegyzék a dokumentumban!
    END
    Mark Test Status    ${excel_file}    ${sheet_name}    ${question_row}    ${err_msg}

    
    # Nincs explicit RETURN: a kulcsszó csak státuszt jelöl