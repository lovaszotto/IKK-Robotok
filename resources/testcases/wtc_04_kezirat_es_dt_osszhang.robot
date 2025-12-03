*** Settings ***
Library    SeleniumLibrary 
Library    OperatingSystem
Library    String
Resource   ${CURDIR}/../keywords.robot
Resource   ${CURDIR}/../../PLG-02-Excel-kitolto.robot


*** Keywords ***
Kézirat és DT összhang ellenőrzése
    [Documentation]    Kézirat és DT összhang ellenőrzése
    Log String To Console    \n**************************************************************************
    Log String To Console    * wtc_04-Kézirat és DT összhang ellenőrzése
    Log String To Console    **************************************************************************\n
    ${testCase_row}=    Set Variable    6
   ${err_msg}=    Set Variable    ${EMPTY}
   ${errors}=    Create List
  ${CR}=    Set Variable    ;
   ${next_button}=    Set Variable    ${EMPTY}
   ${is_disabled}=    Set Variable    None

    # Beolvassuk a ${tartalomjegyzek_file}-t
      ${tartalomjegyzek_file}=    Set Variable    ${CONFIG_OUTPUT_FOLDER}/${CURRENT_SHEET_NAME}_Tartalomjegyzék.csv 
   #beolvasás és ellenőrzés
    Log String To Console    \n>>>>> Tartalomjegyzék fájl beolvasása: ${tartalomjegyzek_file}
    ${exists}=    Run Keyword And Return Status    File Should Exist    ${tartalomjegyzek_file}
    IF    not ${exists}            
        Log String To Console    \n[ERROR] Tartalomjegyzék fájl nem található: ${tartalomjegyzek_file}
        ${err_msg}=    Set Variable    Tartalomjegyzék fájl nem található: ${tartalomjegyzek_file}
        Mark WebTest Status    ${DIGITALIS_EXCEL_FILE}    ${CURRENT_SHEET_NAME}    ${testCase_row}    ${err_msg}
        RETURN    
    END
    ${tartalom_lines}=    OperatingSystem.Get File    ${tartalomjegyzek_file}    encoding=UTF-8
    # számítsd ki ${tartalom_lines} sorok száma kiirása
    ${tartalom_lines_count}=    Get Length    ${tartalom_lines}


    Log String To Console    Tartalomjegyzék fájl sorok száma: ${ tartalom_lines_count}  
    ${all_text}=    Convert To Lower Case   ${tartalom_lines}  
    #első sor a fejléc, azt kihagyjuk
   
     #Oldal szövegek ellenőrzése
     ${found_count}=    Set Variable    0
     ${not_found_count}=    Set Variable    0

    #Wait Until Page Contains Element  xpath=//div[contains(normalize-space(.), 'Oldal')]/preceding-sibling::div[1]  10s
   # ${szoveg_nodes}=    Get WebElements    xpath=//div[contains(normalize-space(.), 'Oldal')]/preceding-sibling::div[1]

    Wait Until Page Contains Element  xpath=//*[contains(concat(' ', normalize-space(@class), ' '), ' tree-node ')]     10s
   ${szoveg_nodes}=    Get WebElements    xpath=//*[contains(concat(' ', normalize-space(@class), ' '), ' tree-node ')]
    ${len_szoveg_nodes}=    Get Length    ${szoveg_nodes}
    Log String To Console    Oldal szöveg elemek száma: ${len_szoveg_nodes}

    FOR    ${index}    IN RANGE    ${len_szoveg_nodes}
        ${node}=    Get From List    ${szoveg_nodes}    ${index}
        ${node_text}=    Get Text    ${node}
         ${node_text}=    Strip String    ${node_text}
         #kisbetűsre alakítás
        ${node_text}=    Convert To Lower Case   ${node_text}
        ${node_text}=    Replace String    ${node_text}    \nblokk    ${EMPTY}   
        ${node_text}=    Replace String    ${node_text}    \noldal    ${EMPTY}   

         ${len_node_text}=    Get Length    ${node_text}
        IF    ${len_node_text} < 1
            #Log String To Console    \n[WARNING] Üres oldal szöveg elem kihagyva.
            Continue For Loop
        END

        Log String To Console    ${index} Oldal: ${node_text}


        #${found}=    Evaluate    '''${node_text}''' in '''${all_text}'''
        ${found}=    Evaluate    bool(re.search($node_text, $all_text, re.IGNORECASE | re.MULTILINE))    re

        IF    ${found}
              ${found_count}=   Evaluate    ${found_count}+1
            Log String To Console    \t[___OK] ${node_text}
            ${new_err}=    Set Variable    ___OK: ${node_text}
            Append To List    ${errors}    ${new_err}
        ELSE
            ${not_found_count}=   Evaluate    ${not_found_count}+1
            Log String To Console    \t[NINCS] ${node_text}
            ${new_err}=    Set Variable    NINCS: ${node_text}
            Append To List    ${errors}    ${new_err}
        END
    END
    IF    ${not_found_count} > 0
        Log String To Console    \n[ERROR] Összesen ${not_found_count} oldal nem található a Digitális anyagban.
        ${found_percentage}=    Evaluate    ${found_count} / (${found_count} + ${not_found_count}) * 100
        ${new_err}=    Set Variable    DT-Kézirat találati arány: ${found_percentage}%, Megtalált: ${found_count}, Nem megtalált: ${not_found_count}
        #Append To List    ${errors}    ${new_err}
        Insert Into List    ${errors}    0    ${new_err}
        Log String To Console    \n[ERROR] ${new_err}
    ELSE
        Log String To Console    \n[INFO] Minden oldal megtalálva a Digitális anyagban. Összesen: ${found_count}
    END

     #Végeredmény visszaírása az Excel-be
    Log String To Console   \n>>>>> Végeredmény visszaírása az Excel-be
    ${unique_errors}=    Remove Duplicates    ${errors}
    ${err_msg}=    Catenate    SEPARATOR=${CR}    @{unique_errors}
 
    #Log String To Console    \nEredmény visszaírása:${DIGITALIS_EXCEL_FILE}  :  ${CURRENT_SHEET_NAME}    ${testCase_row}    ${unique_errors}
    Mark WebTest Status    ${DIGITALIS_EXCEL_FILE}    ${CURRENT_SHEET_NAME}    ${testCase_row}    ${err_msg}
   
    #változók törlése
    Delete Variable    ${all_text}
    Delete Variable    ${pars}
    Delete Variable    ${par}
    Delete Variable    ${text}

    Log String To Console    <<<<<< Kézirat és DT összhang ellenőrzés vége <<<<<<<<  ${is_disabled}
  

