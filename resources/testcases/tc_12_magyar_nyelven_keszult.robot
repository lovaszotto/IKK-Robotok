*** Settings ***
Library     Collections
Library     OperatingSystem
# RPA.JSON eltávolítva – nem használt és hiányzó modul hibát okozott
Resource    ${CURDIR}/../keywords.robot
Resource    ${CURDIR}/../../PLG-02-Excel-kitolto.robot
*** Keywords ***
Test Case 12 - Magyar Nyelven Keszult Ellenorzese
    [Documentation]    12 - Magyar nyelven készült ellenőrzése
    Log String To Console     \n\[12/24] Magyar nyelven készült ellenőrzése
    
    ${testCase_row}=    Set Variable    14

    ${docx_file}=    Get Variable Value    ${DOCX_FILE}    ${EMPTY}
    ${docx_json}=    Get Variable Value    ${DOCX_JSON}    ${EMPTY}
    ${CR}=    Set Variable    ;
    ${err_msg}=    Set Variable    ${EMPTY}
    
    # Nyelv detektálás változók inicializálása
    ${hungarian_count}=    Set Variable    0
    ${other_lang_count}=    Set Variable    0
    ${total_valid_texts}=    Set Variable    0
  
    ${pars}=    Evaluate    [{'idx': i+1, 'text': p.text, 'style': (p.style.name if p.style else 'N/A')} for i,p in enumerate(__import__('docx').Document(r'''${docx_file}''').paragraphs)]
    FOR    ${par}    IN    @{pars}
        ${idx}=    Get From Dictionary    ${par}    idx
        ${text}=    Get From Dictionary    ${par}    text
        ${style}=    Get From Dictionary    ${par}    style
        #Log String To Console    ${idx}: [${style}] "${text}"
        
        # Csak akkor próbáljunk nyelvet detektálni, ha van értelmes szöveg
        ${text_length}=    Get Length    ${text}
        ${is_text_valid}=    Run Keyword And Return Status    Should Be True    ${text_length} > 15
        
        IF    ${is_text_valid}
            TRY
                #ha a style nem normal akkor continue
                IF    "${style}" != "Normal"
                    CONTINUE
                END
                #írd ki a text és a stílus értékét
                #Log String To Console    [DEBUG]${idx}: [${style}] "${text}"

                ${lang}=    Evaluate    __import__('langdetect').detect(r'''${text}''')
                ${total_valid_texts}=    Evaluate    ${total_valid_texts} + 1
                
                IF    '${lang}' == 'hu'
                    ${hungarian_count}=    Evaluate    ${hungarian_count} + 1
                    #Log String To Console    ✓ ${idx}. bekezdés: MAGYAR - "${text[:50]}..."
                ELSE
                    ${other_lang_count}=    Evaluate    ${other_lang_count} + 1
                    # Biztonságos szöveg kiírása Unicode karakterek kezelésével
                    ${safe_text}=    Evaluate    repr(r'''${text}''')[:50] + "..." if len(r'''${text}''') > 50 else repr(r'''${text}''')
                    Log String To Console    X ${idx}. bekezdés: ${lang.upper()} 
                    # Biztonságos hibaüzenet összeállítása
                    ${safe_err_text}=    Evaluate    repr(r'''${text}''')[:50] + "..." if len(r'''${text}''') > 80 else repr(r'''${text}''')
                    ${err_msg}=    Set Variable    ${err_msg}${idx}. bekezdés idegen nyelven (${lang}): - ${safe_err_text}${CR}
                END
            EXCEPT    AS    ${error}
                # Biztonságos szöveg kiírása Unicode karakterek kezelésével
                ${safe_text}=    Evaluate    repr(r'''${text}''')[:50] + "..." if len(r'''${text}''') > 50 else repr(r'''${text}''')
                Log String To Console    ? ${idx}. bekezdés: Nyelv nem detektálható 
            END
        ELSE
            No Operation
            #Log String To Console    - ${idx}. bekezdés: Túl rövid szöveg (${text_length} karakter)
        END
    END
    
    # Eredmény kiértékelése
    Log String To Console    Osszesen vizsgalt szovegreszek: ${total_valid_texts}
    Log String To Console    Magyar nyelven: ${hungarian_count}
    Log String To Console    Idegen nyelven: ${other_lang_count}
    
    IF    ${total_valid_texts} > 0
        ${hungarian_percentage}=    Evaluate    round((${hungarian_count} / ${total_valid_texts}) * 100, 1)
        Log String To Console    Magyar nyelvu arany: ${hungarian_percentage}%
        
        IF    ${hungarian_percentage} > 90
        #IF    ${other_lang_count} == 0
            Log String To Console    SIKERES: A dokumentum magyar nyelven keszult
            ${err_msg}=    Set Variable    ${EMPTY}
        ELSE
            ${err_msg}=    Set Variable    Magyar nyelvu arany: ${hungarian_percentage}% ; Talalt idegen nyelvu szovegreszek: ${other_lang_count} db. ${err_msg}
            Log String To Console    SIKERTELEN: Talalhatok idegen nyelvu szovegreszek
        END
    ELSE
        Log String To Console    FIGYELEM: Nem talalhato detektalhato szoveg (alapertelmezett: SIKERES)
        ${err_msg}=    Set Variable    ${EMPTY}
    END
    
    # Excel jelentés frissítése a Mark Test Status keyword használatával
    ${current_excel_file}=    Get Variable Value    ${CURRENT_EXCEL_FILE}    ${EMPTY}
    ${current_sheet_name}=    Get Variable Value    ${CURRENT_SHEET_NAME}    ${EMPTY}
    
    #IF    '${current_excel_file}' != '${EMPTY}' and '${current_sheet_name}' != '${EMPTY}'
    #    Mark Test Status    ${current_excel_file}    ${current_sheet_name}    ${testCase_row}    ${err_msg}
        #Ha a magyar 95% felett van akkor sikeres legyen a teszt
        IF    ${hungarian_percentage} >= 95
             Fill Excel Cell    ${current_excel_file}    ${current_sheet_name}    ${testCase_row}    4     ${EMPTY}
            Mark Test Status    ${current_excel_file}    ${current_sheet_name}    ${testCase_row}    ${EMPTY}
        ELSE
            Mark Test Status    ${current_excel_file}    ${current_sheet_name}    ${testCase_row}    ${err_msg}
        END
    #END   
    # Változók törlése
    #Delete Variables    ${pars}    ${par}    ${text}