

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

   # ${found}=     Get Variable Value    ${FOUND_TARTALOMJEGYZEK}   
   # Log String To Console   [DEBUG] FOUND_TARTALOMJEGYZEK: ${found}
   # IF    ${found} == ${False}
   #         ${err_msg}=    Set Variable    Nincs generált tartalomjegyzék a dokumentumban!
   # END

 #ellenőrizzük, hogy style-ban van-e toc
    #${stilusok}=  Get Variable Value    ${STILUSOK}

    ${file_path}=   Get Variable Value    ${DOCX_FILE}    ${EMPTY}
    ${entries}=    Extract TOC Entries From Docx File    ${file_path}
     ${docx_path}=    Get Variable Value    ${DOCX_FILE}    ${EMPTY}
    ${pars}=    Evaluate    [{'idx': i+1, 'text': p.text, 'style': (p.style.name if p.style else 'N/A')} for i,p in enumerate(__import__('docx').Document(r'''${docx_path}''').paragraphs)]
      #Írd ki a talált paragraphok számát
    ${par_count}=    Get Length    ${pars}    
    Log String To Console    [DEBUG] par_count: ${par_count}
    FOR    ${par}    IN    @{pars}
        ${idx}=    Get From Dictionary    ${par}    idx
        ${text}=    Get From Dictionary    ${par}    text
        ${style}=    Get From Dictionary    ${par}    style
        TRY
                 IF    "${style}" == "Normal"
                        CONTINUE
                END
                #Log String To Console    [SHOW]${idx}: [${style}] : "${text}"
       
                ${is_match}=    Evaluate    re.search(r'(?i).*címsor.*', """${style}""")    re
                IF    ${is_match}
                        ${heading_count}=    Evaluate    ${heading_count} + 1
                        Log String To Console    [DEBUG] ${style} : ${text} 
                    Write Tartalomjegyzék To CSV    ${CURRENT_SHEET_NAME}    ${style}   ${text}
                END
               ${is_match2}=   Evaluate    re.search(r'(?i).*heading.*', """${style}""")   re
                IF   ${is_match2}
                        ${heading_count}=    Evaluate    ${heading_count} + 1
                        Log String To Console    [DEBUG] T ${style} : ${text} 
                        Write Tartalomjegyzék To CSV    ${CURRENT_SHEET_NAME}    ${style}   ${text}
                END
        EXCEPT    AS    ${e}
                Log String To Console    [ERROR] Hiba a címsor stílus ellenőrzése során: ${e}
        END
    END

    ${filename_part}=   Get Variable Value    ${CURRENT_FILENAME_PART}    ${EMPTY}
    #toc ellenőrzése
     ${entries}=    Extract TOC Entries From Docx File    ${file_path}
    ${toc_count}=    Get Length    ${entries}
    #Log String To Console    [TOC]Talált TOC sorok száma: ${toc_count}
    #FOR    ${e}    IN    @{entries}
    #    Log String To Console    TOC: ${e}
    #END
    #ellenőrizzük, hogy van-e benne toc
   Log String To Console    [TOC]Talált TOC sorok száma: ${toc_count}
       #ellenőrizzük, hogy van-e benne toc
    ${toc_count}=    Get Length    ${entries}
    IF    ${toc_count} == 0
            ${err_msg}=    Set Variable    Nincs generált tartalomjegyzék a dokumentumban!
    END
    # Teszt státusz és Excel jelölés végrehajtása a megadott soron
    Mark Test Status    ${excel_file}    ${sheet_name}    ${question_row}    ${err_msg}

    #Delete Variables    ${pars}    ${par}    ${text}    ${entries}
    # Nincs explicit RETURN: a kulcsszó csak státuszt jelöl