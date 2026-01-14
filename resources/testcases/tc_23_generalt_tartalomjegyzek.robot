

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
    Log String To Console     \n\[23/24] Generált tartalomjegyzék
    ${excel_file}=    Get Variable Value    ${CURRENT_EXCEL_FILE}    ${EMPTY}
    ${sheet_name}=    Get Variable Value    ${CURRENT_SHEET_NAME}    ${EMPTY}
    ${question_row}=    Set Variable    25
    ${col_present}=    Set Variable    3
    ${col_missing}=    Set Variable    4
    ${err_msg}=    Set Variable    ${EMPTY}
    ${heading_count}=    Set Variable    0
    #ellenőrizzük, hogy style-ban van-e toc
    #${stilusok}=  Get Variable Value    ${STILUSOK}
    # get global variable FOUND_TARTALOMJEGYZEK

    ${found}=     Get Variable Value    ${FOUND_TARTALOMJEGYZEK}   
    Log String To Console   [DEBUG] FOUND_TARTALOMJEGYZEK: ${found}
    IF    ${found} == ${False}
            ${err_msg}=    Set Variable    Nincs generált tartalomjegyzék a dokumentumban!
    END

    # Teszt státusz és Excel jelölés végrehajtása a megadott soron
    Mark Test Status    ${excel_file}    ${sheet_name}    ${question_row}    ${err_msg}

    #Delete Variables    ${pars}    ${par}    ${text}    ${entries}
    # Nincs explicit RETURN: a kulcsszó csak státuszt jelöl