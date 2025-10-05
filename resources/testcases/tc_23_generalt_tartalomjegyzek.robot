*** Settings ***
Resource   ${CURDIR}/../keywords.robot
Resource   ${CURDIR}/../../PLG-02-Excel-kitolto.robot

*** Keywords ***
Test Case 23 - Generalt Tartalomjegyzek Ellenorzese
    [Documentation]    23 - Generált tartalomjegyzék
    Log To Console     \n\[23/24] Generált tartalomjegyzék
    ${excel_file}=    Get Variable Value    ${CURRENT_EXCEL_FILE}    ${EMPTY}
    ${sheet_name}=    Get Variable Value    ${CURRENT_SHEET_NAME}    ${EMPTY}
    ${question_row}=    Set Variable    25
    ${col_present}=    Set Variable    3
    ${col_missing}=    Set Variable    4
    ${err_msg}=    Set Variable    ${EMPTY}
    # ellenőrizzük, hogy van-e benne generált tartalomjegyzék
    ${err_msg}=    Check Document Has Generated Table Of Contents
    # Teszt státusz és Excel jelölés végrehajtása a megadott soron
    Mark Test Status    ${excel_file}    ${sheet_name}    ${question_row}    ${err_msg}


  

Check Document Has Generated Table Of Contents
    [Documentation]    Ellenőrzi, hogy a ${DOCX_FILE} dokumentumban Word-generált tartalomjegyzék (TOC mező) található-e.
    ${docx_file}=    Get Variable Value    ${DOCX_FILE}    ${EMPTY}
    ${err_msg}=    Set Variable    ${EMPTY}
    Run Keyword If    '${docx_file}' == ''    Set Test Variable    ${err_msg}    Üres DOCX fájlnév változó
    ${status}    ${docxml}=    Run Keyword And Ignore Error    Evaluate    __import__('zipfile').ZipFile(path,'r').read('word/document.xml')    path=${docx_file}
    IF    '${status}' != 'PASS'
        ${has_toc}=    Set Variable    ${False}
    ELSE
        ${text}=    Evaluate    str(data,'utf-8','ignore').lower()    data=${docxml}
        ${p1}=    Evaluate    'w:fldsimple' in t and 'w:instr="toc' in t    t=${text}
        ${p2}=    Evaluate    'w:instrtext' in t and 'toc' in t    t=${text}
        ${has_toc}=    Evaluate    bool(p1 or p2)    p1=${p1}    p2=${p2}
    END
    IF    not ${has_toc}
        ${err_msg}=    Set Variable    Nincs generált tartalomjegyzék
    END
    RETURN    ${err_msg}
