*** Settings ***
Library    SeleniumLibrary
Resource   ${CURDIR}/../keywords.robot
Resource   ${CURDIR}/../../PLG-02-Excel-kitolto.robot


*** Keywords ***
Kézirat és DT összhang ellenőrzése
    [Documentation]    Kézirat és DT összhang ellenőrzése
    Log String To Console    \n[wtc_04_kezirat_es_dt_osszhang] Kézirat és DT összhang ellenőrzése
    ${testCase_row}=    Set Variable    6
   ${err_msg}=    Set Variable    ${EMPTY}
   ${errors}=    Create List

   ${next_button}=    Set Variable    ${EMPTY}
   ${is_disabled}=    Set Variable    None

    ${rc}    ${msg}=    Run Keyword And Ignore Error     Wait Until Page Contains Element    xpath=//button[contains(@aria-label,'Következő oldalra lépés')]   10s    
    Log To Console    \nVárakozás eredménye: ${rc} ${msg}
    IF    '${rc}' == 'PASS'
        ${next_button}=    Get WebElement    xpath=//button[contains(@aria-label,'Következő oldalra lépés')]
        WHILE    ${is_disabled} is ${NONE}
            #Log To Console    Következő oldal gomb engedélyezett, lépés a következő oldalra.
            Click Button       xpath=//button[contains(@aria-label,'Következő oldalra lépés')]
            ${is_disabled}=    Get Element Attribute    ${next_button}    disabled
            #Log To Console    Következő oldal gomb le van tiltva vagy ismeretlen állapot: ${is_enabled}

            IF   $is_disabled == True or $is_disabled == 'true' or $is_disabled == 'True'
                #Log To Console    Következő oldal gomb le van tiltva vagy ismeretlen állapot: ${is_disabled}
                Exit For Loop
            END
        END
    END
    #Minden menupont nyitva
     #docx_file beolvasása all_text string-be uppercase-elve
     #TODO a végén eldobni!!!
     ${all_text}    Set Variable    ${EMPTY}
     ${pars}=    Evaluate    [{'idx': i+1, 'text': p.text, 'style': (p.style.name if p.style else 'N/A')} for i,p in enumerate(__import__('docx').Document(r'''${docx_file}''').paragraphs)]
     FOR    ${par}    IN    @{pars}
        ${text}=    Get From Dictionary    ${par}    text
        #${text}=    Convert To Uppercase    ${text}
        ${all_text}=    Set Variable    ${all_text}\n ${text};
    END    

    #Level1-es címsorok ellenőrzése

    Wait Until Page Contains Element  xpath=//div[@class='tree-node expandable-node tree-level-1 expanded-node']   10s
    ${level1_nodes}=    Get WebElements    xpath=//div[@class='tree-node expandable-node tree-level-1 expanded-node']
    #get length of level1_nodes
    ${len_level1_nodes}=    Get Length    ${level1_nodes}
    Log To Console    \nLeve1 szöveg elemek száma: ${len_level1_nodes}
    ${found_count}=    Set Variable    0
    ${not_found_count}=    Set Variable    0

    FOR    ${index}    IN RANGE    ${len_level1_nodes}
        ${node}=    Get From List    ${level1_nodes}    ${index}
        ${node_text}=    Get Text    ${node}
        ${node_text}=    Replace String    ${node_text}    \nBlokk    ${EMPTY}   
        ${node_text}=    Strip String    ${node_text}
        ${node_text}=    Convert To Uppercase    ${node_text}
        ${found}=    Evaluate    '''${node_text}''' in '''${all_text}'''
        IF    ${found}
            Log To Console    \n[INFO] Szöveg megtalálva: '${node_text}'
            ${found_count}=   Evaluate    ${found_count}+1
        ELSE
            Log To Console    \n[ERROR] Szöveg nem található a DOCX_JSON-ban: '${node_text}'
            ${not_found_count}=    Evaluate   ${not_found_count}+1
            ${new_err}=    Set Variable    Címsor 1 nincs a dokumentumban: '${node_text}'
            Append To List    ${errors}    ${new_err}
        END
    END
    IF    ${not_found_count} > 0
        Log To Console    \n[ERROR] Összesen ${not_found_count} címsor 1 nem található a dokumentumban.
        ${found_percentage}=    Evaluate    ${found_count} / (${found_count} + ${not_found_count}) * 100
        ${new_err}=    Set Variable    Találati arány: ${found_percentage}%, Megtalált: ${found_count}, Nem megtalált: ${not_found_count}
        Append To List    ${errors}    ${new_err}
    ELSE
        Log To Console    \n[INFO] Minden címsor 1 megtalálva a dokumentumban. Összesen: ${found_count}
    END
  #Level2-es címsorok ellenőrzése

    #Wait Until Page Contains Element  xpath=//div[@class='tree-node expandable-node tree-level-2 expanded-node']   10s
    #${level2_nodes}=    Get WebElements    xpath=//div[@class='tree-node expandable-node tree-level-2 expanded-node']
    #get length of level1_nodes
    #${len_level2_nodes}=    Get Length    ${level2_nodes}
    #Log To Console    \nLeve2 szöveg elemek száma: ${len_level2_nodes}
    #FOR    ${index}    IN RANGE    ${len_level2_nodes}
    #    ${node}=    Get From List    ${level2_nodes}    ${index}
    #    ${node_text}=    Get Text    ${node}
    #    ${node_text}=    Replace String    ${node_text}    \nBlokk    ${EMPTY}   
    #    ${node_text}=    Strip String    ${node_text}
    #    ${node_text}=    Convert To Uppercase    ${node_text}
    #    ${found}=    Evaluate    '''${node_text}''' in '''${all_text}'''
    #    IF    ${found}
    #        Log To Console    \n[INFO] Szöveg megtalálva: '${node_text}'
    #    ELSE
    #        Log To Console    \n[ERROR] Szöveg nem található a DOCX_JSON-ban: '${node_text}'
    #        ${new_err}=    Set Variable    Címsor 2 nincs a dokumentumban: '${node_text}'
    #        Append To List    ${errors}    ${new_err}
    #    END
    #END
    
     #Oldal szövegek ellenőrzése
     ${found_count}=    Set Variable    0
    ${not_found_count}=    Set Variable    0

    Wait Until Page Contains Element  xpath=//div[contains(normalize-space(.), 'Oldal')]/preceding-sibling::div[1]  10s
    ${level2_nodes}=    Get WebElements    xpath=//div[contains(normalize-space(.), 'Oldal')]/preceding-sibling::div[1]
    ${len_level2_nodes}=    Get Length    ${level2_nodes}
    Log To Console    Oldal szöveg elemek száma: ${len_level2_nodes}
    FOR    ${index}    IN RANGE    ${len_level2_nodes}
        ${node}=    Get From List    ${level2_nodes}    ${index}
        ${node_text}=    Get Text    ${node}
         ${node_text}=    Strip String    ${node_text}
         ${len_node_text}=    Get Length    ${node_text}
        IF    ${len_node_text} < 1
            #Log To Console    \n[WARNING] Üres oldal szöveg elem kihagyva.
            Continue For Loop
        END
        ${node_text}=    Replace String    ${node_text}    \nBlokk    ${EMPTY}   
        ${node_text}=    Replace String    ${node_text}    \nOldal    ${EMPTY}   

        #Log To Console    \nOldal: '${node_text}'

        ${found_feladat}=    Evaluate    bool(re.search('feladat', $node_text, re.IGNORECASE | re.MULTILINE))    re
        IF    ${found_feladat}    
            #Log To Console    [SKIPP]  '${node_text}'  
             Continue For Loop
        END

        ${found_borito}=    Evaluate    bool(re.search('borító', $node_text, re.IGNORECASE | re.MULTILINE))    re
        IF    ${found_borito}    
            #Log To Console    [SKIPP] '${node_text}'
             Continue For Loop
        END

        ${found_nyitooldal}=    Evaluate    bool(re.search('nyitóoldal', $node_text, re.IGNORECASE | re.MULTILINE))    re
        IF    ${found_nyitooldal}    
            #Log To Console    [SKIPP] '${node_text}'
             Continue For Loop
        END

        ${found_osszefoglalo}=    Evaluate    bool(re.search('összefoglal', $node_text, re.IGNORECASE | re.MULTILINE))    re
        IF    ${found_osszefoglalo}    
            #Log To Console    [SKIPP] '${node_text}'
             Continue For Loop
        END

        ${found_kerdesbank}=    Evaluate    bool(re.search('kérdésbank', $node_text, re.IGNORECASE | re.MULTILINE))    re
        IF    ${found_kerdesbank}    
            #Log To Console    [SKIPP] '${node_text}'
             Continue For Loop
        END

        ${found_nyitooldal}=    Evaluate    bool(re.search('nyitóoldal', $node_text, re.IGNORECASE | re.MULTILINE))    re
        IF    ${found_nyitooldal}    
            #Log To Console    [SKIPP] '${node_text}'
             Continue For Loop
        END


        #${found}=    Evaluate    '''${node_text}''' in '''${all_text}'''
        ${found}=    Evaluate    bool(re.search($node_text, $all_text, re.IGNORECASE | re.MULTILINE))    re

        IF    ${found}
              ${found_count}=   Evaluate    ${found_count}+1
            #Log To Console    [OK] '${node_text}'
        ELSE
            ${not_found_count}=   Evaluate    ${not_found_count}+1
            Log To Console    [ERROR] '${node_text}'
            ${new_err}=    Set Variable    Nincs: '${node_text}'
            Append To List    ${errors}    ${new_err}
        END
    END
    IF    ${not_found_count} > 0
        Log To Console    \n[ERROR] Összesen ${not_found_count} oldal nem található a dokumentumban.
        ${found_percentage}=    Evaluate    ${found_count} / (${found_count} + ${not_found_count}) * 100
        ${new_err}=    Set Variable    Találati arány: ${found_percentage}%, Megtalált: ${found_count}, Nem megtalált: ${not_found_count}
        Append To List    ${errors}    ${new_err}
        Log To Console    \n[ERROR] ${new_err}
    ELSE
        Log To Console    \n[INFO] Minden oldal megtalálva a dokumentumban. Összesen: ${found_count}
    END
    
    
    
    
    Log To Console    <<<<<< Kézirat és DT összhang ellenőrzés vége <<<<<<<<  ${is_disabled}
    #Végeredmény visszaírása az Excel-be
    Log To Console   \n>>>>> Végeredmény visszaírása az Excel-be
    ${unique_errors}=    Remove Duplicates    ${errors}
    ${err_msg}=    Catenate    SEPARATOR=${CR}    @{unique_errors}
 
    Log String To Console    \nEredmény visszaírása:${DIGITALIS_EXCEL_FILE}  :  ${CURRENT_SHEET_NAME}    ${testCase_row}    ${err_msg}
    Mark WebTest Status    ${DIGITALIS_EXCEL_FILE}    ${CURRENT_SHEET_NAME}    ${testCase_row}    ${err_msg}
   


