*** Settings ***
Library     Collections
Resource    ${CURDIR}/../keywords.robot
Resource    ${CURDIR}/../../PLG-02-Excel-kitolto.robot

*** Variables ***
${DOCX}    ${DOCX_FILE}

*** Keywords ***
Test Case 09 - Abrak Fotok Ellenorzese
    [Documentation]    09 - Ábrák/fotók ellenőrzése
    Log To Console    [09/24] Ábrák/fotók ellenőrzése - not implemented
    ${testCase_row}=     Set Variable    26
    ${heading_count}=    Set Variable    0
    ${abra_utan}=        Set Variable    0

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
        
        #Log To Console    ${idx}: "${text}"
        #Log To Console    ${idx}: [${style}]

        IF    ${abra_utan} == 1
            Log To Console    >>>>>>>>>>>>>>>>>>>>>>>>>>> Ábra/fotó után normál szöveg: ${text}
            ${abra_utan}=    Set Variable    ${abra_utan}    0
        END

        IF    "${style}" == "table of figures"
            Log To Console    ${idx}: "${text}"
            Log To Console    ${idx}: [${style}]
            ${abra_utan}=    Set Variable    ${abra_utan}    1
        END
        Log To Console    ÁBRA UTÁN:${abra_utan}
   
         #minden paragraph és stílus kiiratása
      
     
        
    END

     # Teszt státusz és Excel jelölés végrehajtása a megadott soron
    Mark Test Status    ${excel_file}    ${sheet_name}    ${testCase_row}    ${err_msg}
