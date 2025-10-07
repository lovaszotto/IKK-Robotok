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
     ${CR}=    Set Variable    ;
    #${CR}=    Set Variable    ;
    ${is_abra}=    Set Variable    0
    ${abra_text}=    Set Variable    ${EMPTY}

 
    ${docx_path}=    Get Variable Value    ${DOCX_FILE}    ${EMPTY}
    ${pars}=    Evaluate    [{'idx': i+1, 'text': p.text, 'style': (p.style.name if p.style else 'N/A')} for i,p in enumerate(__import__('docx').Document(r'''${docx_path}''').paragraphs)]
    
    FOR    ${par}    IN    @{pars}
        ${idx}=    Get From Dictionary    ${par}    idx
        ${text}=    Get From Dictionary    ${par}    text
        ${style}=    Get From Dictionary    ${par}    style
        
        #Log To Console    ${idx}: "${text}"
        #Log To Console    ${idx}: [${style}] "${text}"
        #CONTINUE
        
        
        #table of figures kihagyása
         IF    $style == "table of figures" 
            CONTINUE
        END    

        #ha text üres vagy Téma jegyzék, akkor kihagyjuk
        IF    $text == "" 
            CONTINUE
        END    
     
        IF    "${style}" == "Caption"
          #Log To Console    \n\n=========================== SZK Ábrajegyzék:${idx}: "${text}"        
          #Log To Console    \n\n--------------------------- Caption:${idx}: ${style} ${text}

          # Reset counter after a table of figures heading
          ${abra_utan}=    Evaluate    ${idx} + 1
          ${is_abra}=    Set Variable    1
          ${abra_text}=    Set Variable    ${text}

        END

        IF    "${style}" == "SK Képaláírás"
          #Log To Console    \n\n=========================== SK Képaláírás:${idx}: "${text}"        
          #Log To Console    --------------------------- SK Képaláírás:${idx}: ${style}
          # Reset counter after a table of figures heading
          ${abra_utan}=    Evaluate    ${idx} + 1
          ${is_abra}=    Set Variable    1
          ${abra_text}=    Set Variable    ${text}
        END

        IF    "${style}" == "SZK Ábrajegyzék"
          #Log To Console    \n\n=========================== SZK Ábrajegyzék:${idx}: "${text}"        
          #Log To Console    --------------------------- SZK Ábrajegyzék:${idx}: ${style}
          # Reset counter after a table of figures heading
          ${abra_utan}=    Evaluate    ${idx} + 1
          ${is_abra}=    Set Variable    1
          ${abra_text}=    Set Variable    ${text}
        END
        IF    "${style}" == "a_ELMS_Ábraaláírás"
          #Log To Console    \n\n=========================== a_ELMS_Ábraaláírás:${idx}: "${text}"
          #Log To Console    --------------------------- ÁBRA:${idx}: ${style}
          # Reset counter after a table of figures heading
          ${abra_utan}=    Evaluate    ${idx} + 1
         ${is_abra}=    Set Variable    1
         ${abra_text}=    Set Variable    ${text}
        END
        #ha az idx értéke  megegyezik az abra_utan értékével, akkor ez az ábra utáni sor

        ${is_next_line}=    Evaluate    ${idx} == ${abra_utan}
        IF    ${is_next_line}
           #Log To Console    Next line: ${idx}: [${style}] "${text}"
           #${abra_utan}=    Evaluate    ${abra_utan} + 1
           IF   not "Forrás:" in $text
                ${text}=    Get Substring    ${abra_text}    0    100
                ${new_err}=    Set Variable    Ábra/fotó után nincs Forrás megjelölve! ${idx}.sor ${text}
                IF    $err_msg == ''
                    ${err_msg}=    Set Variable    ${new_err}
                ELSE
                    # err_msg max 500 karakter lehet (új hibával együtt)
                    ${current_len}=    Evaluate    len($err_msg)
                    ${new_len}=    Evaluate    ${current_len} + len($new_err) + 1
                    #IF    ${new_len} < 500
                        ${err_msg}=    Catenate    SEPARATOR=${CR}    ${err_msg}    ${new_err}
                    #END
                END
                Log To Console     [ERROR] ${new_err}    
           END
        END
 
    END
     # Teszt státusz és Excel jelölés végrehajtása a megadott soron
    Mark Test Status    ${excel_file}    ${sheet_name}    ${testCase_row}    ${err_msg}
