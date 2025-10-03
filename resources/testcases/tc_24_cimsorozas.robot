*** Settings ***
Library     Collections
Resource    ${CURDIR}/../keywords.robot
Resource    ${CURDIR}/../../PLG-02-Excel-kitolto.robot

*** Variables ***
${DOCX}    ${DOCX_FILE}

*** Keywords ***
Test Case 24 - Cimsorozassal Keszult Ellenorzese
    [Documentation]    24 - Címsorozással készült ellenőrzése
    Log To Console    [24/24] Címsorozással készült ellenőrzése
    
     ${testCase_row}=    Set Variable    26
    ${heading_count}=    Set Variable    0
    ${excel_file}=    Get Variable Value    ${CURRENT_EXCEL_FILE}    ${EMPTY}
    ${sheet_name}=    Get Variable Value    ${CURRENT_SHEET_NAME}    ${EMPTY}
    ${path_part}=       Get Variable Value    ${CURRENT_PATH_PART}    ${EMPTY}
    ${filename_part}=   Get Variable Value    ${CURRENT_FILENAME_PART}    ${EMPTY}
    ${err_msg}=    Set Variable    ${EMPTY}
    ${CR}=    Evaluate    chr(13)
  
    ${docx_path}=    Get Variable Value    ${DOCX_FILE}    ${EMPTY}
    ${pars}=    Evaluate    [{'idx': i+1, 'text': p.text, 'style': (p.style.name if p.style else 'N/A')} for i,p in enumerate(__import__('docx').Document(r'''${docx_path}''').paragraphs)]
    FOR    ${par}    IN    @{pars}
        ${idx}=    Get From Dictionary    ${par}    idx
        ${text}=    Get From Dictionary    ${par}    text
        ${style}=    Get From Dictionary    ${par}    style
        IF    "${style}" == "Normal"
            CONTINUE
        END
         #minden paragraph és stílus kiiratása
        #Log To Console    ${idx}: "${text}"
        #Log To Console    ${idx}: [${style}]
        IF    "${style}" == "Heading 1" or "${style}" == "Heading 2" or "${style}" == "Heading 3" or "${style}" == "Heading 4" or "${style}" == "Heading 5" or "${style}" == "Heading 6"
            ${heading_count}=    Evaluate    ${heading_count} + 1
        END
    END
    IF    ${heading_count} < 5
        ${new_err}=    Set Variable    Nem használ címsorokat!
        IF    $err_msg == ''
            ${err_msg}=    Set Variable    ${new_err}
        ELSE
            ${err_msg}=    Catenate    SEPARATOR=${CR}    ${err_msg}    ${new_err}
        END
        Log To Console    [ERROR] ${new_err}
    END
     # Teszt státusz és Excel jelölés végrehajtása a megadott soron
    Mark Test Status    ${excel_file}    ${sheet_name}    ${testCase_row}    ${err_msg}
