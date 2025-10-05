*** Settings ***
Library     Collections
Library     String
Resource    ${CURDIR}/../keywords.robot
Resource    ${CURDIR}/../../PLG-02-Excel-kitolto.robot

*** Variables ***
${DOCX}    ${DOCX_FILE}

*** Keywords ***
Test Case 09 - Abrak Fotok Ellenorzese
    [Documentation]    09 - Ábrák/fotók ellenőrzése
    Log To Console     \n\[09/24] Ábrák/fotók ellenőrzése 
    ${testCase_row}=     Set Variable    11
    ${heading_count}=    Set Variable    0
    ${abra_utan}=        Set Variable    0
    ${has_forras}=       Set Variable    0
    ${sum_idx}=          Set Variable    0

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
        ${sum_idx}=    Evaluate    ${sum_idx} + ${idx}
        
        #Log To Console    ${idx}: "${text}"
        #Log To Console    ${idx}: [${style}]
        #CONTINUE

        #ha text üres vagy Téma jegyzék, akkor kihagyjuk
        IF    $text == "" or "Téma kézirata" in $text or "Egyedi megrendelés azonosítója:" in $text
            CONTINUE
        END    
        #A címlapon lévőket kihagyjuk
        IF    ${sum_idx} < 10
            #Log To Console    ========KIHAGYVA:${sum_idx}: "${text}"
            CONTINUE
        END
        IF    "${style}" == "SZK Ábrajegyzék"
          #Log To Console    \n\n=========================== ÁBRA:${idx}: "${text}"
          #Log To Console    --------------------------- ÁBRA:${idx}: ${style}
          # Reset counter after a table of figures heading
          ${abra_utan}=    Set Variable    0
        END

        IF    ${abra_utan} < 5
            #Log To Console    >>>>${abra_utan}>>> Ábra/fotó után: ${text}
            #Log To Console    ${idx}: "${text}"
            #Log To Console    ${idx}: ${style}
           #Ha a text tartalmazza a "Forrás:" szót, akkor    
           # FIX: 'contains' is not valid in Robot inline IF expression; use Python 'in'
           # Robot Framework expression evaluation: use $text so expression is parsed before variable substitution
           IF    "Forrás:" in $text
               ${has_forras}=    Evaluate    ${has_forras} + 1
           END
            #növeljük egyel
            ${abra_utan}=    Evaluate    ${abra_utan} + 1
        ELSE
            # Reached the limit -> reset counter back to 0
            ${abra_utan}=    Set Variable    0
        END

     
         # ha a has_forrás 0, akkor hibaüzenet
        IF    ${has_forras} == 0        
            ${text}=    Get Substring    ${text}    0    40
            ${new_err}=    Set Variable    Ábra/fotó után nincs Forrás megjelölve! ${idx}.sor ${text}
            IF    $err_msg == ''
                ${err_msg}=    Set Variable    ${new_err}
            ELSE
                ${err_msg}=    Catenate    SEPARATOR=${CR}    ${err_msg}    ${new_err}
            END
            Log To Console     [ERROR] ${new_err}    
       END
        
    END

     # Teszt státusz és Excel jelölés végrehajtása a megadott soron
    Mark Test Status    ${excel_file}    ${sheet_name}    ${testCase_row}    ${err_msg}
