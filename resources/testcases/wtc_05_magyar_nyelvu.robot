*** Settings ***
Library    SeleniumLibrary 
Resource   ${CURDIR}/../keywords.robot
Resource   ${CURDIR}/../../PLG-02-Excel-kitolto.robot


*** Keywords ***
DT nyelv ellenőrzése
    [Documentation]    DT nyelv ellenőrzése
     Log String To Console    \n**************************************************************************
    Log String To Console    * wtc_05- DT nyelv ellenőrzése
    Log String To Console    **************************************************************************\n
    ${testCase_row}=    Set Variable    7
   ${err_msg}=    Set Variable    ${EMPTY}
   ${errors}=    Create List
  ${CR}=    Set Variable    ;
   ${next_button}=    Set Variable    ${EMPTY}
   ${is_disabled}=    Set Variable    None
  # Nyelv detektálás változók inicializálása
    ${hungarian_count}=    Set Variable    0
    ${other_lang_count}=    Set Variable    0
    ${total_valid_texts}=    Set Variable    0

     #Oldal szövegek ellenőrzése
     ${found_count}=    Set Variable    0
    ${not_found_count}=    Set Variable    0

    #Wait Until Page Contains Element  xpath=//div[contains(normalize-space(.), 'Oldal')]/preceding-sibling::div[1]  10s
    #${szoveg_nodes}=    Get WebElements    xpath=//div[contains(normalize-space(.), 'Oldal')]/preceding-sibling::div[1]
   
    Wait Until Page Contains Element  xpath=//*[contains(concat(' ', normalize-space(@class), ' '), ' tree-node ')]     10s
    #Log String To Console    Oldal szöveg elemek lekérése...
   ${szoveg_nodes}=    Get WebElements    xpath=//*[contains(concat(' ', normalize-space(@class), ' '), ' tree-node ')]
   #Log String To Console    Oldal szöveg elemek lekérve.
    ${len_szoveg_nodes}=    Get Length    ${szoveg_nodes}
    Log String To Console    Oldal szöveg elemek száma: ${len_szoveg_nodes}
    FOR    ${index}    IN RANGE    ${len_szoveg_nodes}
        ${node}=    Get From List    ${szoveg_nodes}    ${index}
        ${node_text}=    Get Text    ${node}
         ${node_text}=    Strip String    ${node_text}
         ${len_node_text}=    Get Length    ${node_text}
        IF    ${len_node_text} < 1
            #Log String To Console    \n[WARNING] Üres oldal szöveg elem kihagyva.
            Continue For Loop
        END
        ${node_text}=    Replace String    ${node_text}    \nBlokk    ${EMPTY}   
        ${node_text}=    Replace String    ${node_text}    \nOldal    ${EMPTY}   

        Log String To Console    ${index}=>Oldal: '${node_text}'

        ${found_feladat}=    Evaluate    bool(re.search('feladat', $node_text, re.IGNORECASE | re.MULTILINE))    re
        IF    ${found_feladat}    
            #Log String To Console    [SKIPP]  '${node_text}'  
             Continue For Loop
        END

        ${found_borito}=    Evaluate    bool(re.search('borító', $node_text, re.IGNORECASE | re.MULTILINE))    re
        IF    ${found_borito}    
            #Log String To Console    [SKIPP] '${node_text}'
             Continue For Loop
        END

        ${found_nyitooldal}=    Evaluate    bool(re.search('nyitóoldal', $node_text, re.IGNORECASE | re.MULTILINE))    re
        IF    ${found_nyitooldal}    
            #Log String To Console    [SKIPP] '${node_text}'
             Continue For Loop
        END

        ${found_osszefoglalo}=    Evaluate    bool(re.search('összefoglal', $node_text, re.IGNORECASE | re.MULTILINE))    re
        IF    ${found_osszefoglalo}    
            #Log String To Console    [SKIPP] '${node_text}'
             Continue For Loop
        END

        ${found_kerdesbank}=    Evaluate    bool(re.search('kérdésbank', $node_text, re.IGNORECASE | re.MULTILINE))    re
        IF    ${found_kerdesbank}    
            #Log String To Console    [SKIPP] '${node_text}'
             Continue For Loop
        END

        ${found_nyitooldal}=    Evaluate    bool(re.search('nyitóoldal', $node_text, re.IGNORECASE | re.MULTILINE))    re
        IF    ${found_nyitooldal}    
            #Log String To Console    [SKIPP] '${node_text}'
             Continue For Loop
        END


     # Csak akkor próbáljunk nyelvet detektálni, ha van értelmes szöveg
        ${text_length}=    Get Length    ${node_text}
        ${is_text_valid}=    Run Keyword And Return Status    Should Be True    ${text_length} > 15
        
        IF    ${is_text_valid}
            TRY
                ${lang}=    Evaluate    __import__('langdetect').detect(r'''${node_text}''')
                ${total_valid_texts}=    Evaluate    ${total_valid_texts} + 1
                
                IF    '${lang}' == 'hu'
                    ${hungarian_count}=    Evaluate    ${hungarian_count} + 1
                    Log String To Console     MAGYAR - "${node_text[:50]}..."
                ELSE
                    ${other_lang_count}=    Evaluate    ${other_lang_count} + 1
                    # Biztonságos szöveg kiírása Unicode karakterek kezelésével
                   # ${safe_text}=    Evaluate    repr(r'''${node_text}''')[:50] + "..." if len(r'''${node_text}''') > 50 else repr(r'''${node_text}''')
                   # Log String To Console     ${lang.upper()} - "${safe_text}"
                    # Biztonságos hibaüzenet összeállítása
                   # ${safe_err_text}=    Evaluate    repr(r'''${node_text}''')[:50] + "..." if len(r'''${node_text}''') > 80 else repr(r'''${node_text}''')
                   # ${err_msg}=    Set Variable    ${err_msg} bekezdés idegen nyelven,(${lang}): - ${safe_err_text}${CR}
                   # Append To List    ${errors}    ${err_msg}
                END
            EXCEPT    AS    ${error}
                # Biztonságos szöveg kiírása Unicode karakterek kezelésével
                ${safe_text}=    Evaluate    repr(r'''${node_text}''')[:50] + "..." if len(r'''${node_text}''') > 50 else repr(r'''${node_text}''')
                Log String To Console    Nyelv nem detektálható: ${safe_text}
            END
        ELSE
            No Operation
            #Log String To Console    - ${idx}. bekezdés: Túl rövid szöveg (${text_length} karakter)
        END
    END
     
    ${found_percentage}=    Evaluate    ${hungarian_count} / (${hungarian_count} + ${other_lang_count}) * 100
    IF    ${found_percentage} < 80 
        #Log String To Console    \n[ERROR] Összesen ${other_lang_count} oldal nem magyar.
      
        ${new_err}=    Set Variable    Magyar nyelv találati arány: ${found_percentage}%, Magyar: ${hungarian_count}, Nem magyar: ${other_lang_count}
        #Append To List    ${errors}    ${new_err}
        Insert Into List    ${errors}    0    ${new_err}
        Log String To Console    \n[ERROR] ${new_err}
    ELSE
        Log String To Console    \n[INFO] Minden oldal magyar. Összesen: ${hungarian_count}
    END
    
    
    
    
    Log String To Console    <<<<<< Kézirat és DT összhang ellenőrzés vége <<<<<<<<  ${is_disabled}
    #Végeredmény visszaírása az Excel-be
    Log String To Console   \n>>>>> Végeredmény visszaírása az Excel-be
    ${unique_errors}=    Remove Duplicates    ${errors}
    ${err_msg}=    Catenate    SEPARATOR=${CR}    @{unique_errors}
 
    #Log String To Console    \nEredmény visszaírása:${DIGITALIS_EXCEL_FILE}  :  ${CURRENT_SHEET_NAME}    ${testCase_row}    ${unique_errors}
    Mark WebTest Status    ${DIGITALIS_EXCEL_FILE}    ${CURRENT_SHEET_NAME}    ${testCase_row}    ${err_msg}
   
    #változók törlése
    #Delete Variables  ${all_text}    ${pars}    ${par}    ${text}
    

