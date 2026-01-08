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

    # beolvassuk a menu fájlt
    ${menu_file}=    Set Variable    ${CONFIG_OUTPUT_FOLDER}/${CURRENT_SHEET_NAME}_Menu.csv 
   #beolvasás és ellenőrzés
    Log String To Console    \n>>>>> Menü fájl beolvasása: ${menu_file}
    ${existsMenu}=    Run Keyword And Return Status    File Should Exist    ${menu_file}
    IF    not ${existsMenu}            
        Log String To Console    \n[ERROR] Menu fájl nem található: ${menu_file}
        ${err_msg}=    Set Variable    Menu fájl nem található: ${menu_file}
        Mark WebTest Status    ${DIGITALIS_EXCEL_FILE}    ${CURRENT_SHEET_NAME}    ${testCase_row}    ${err_msg}
        RETURN    
    END    
     ${menu_files_content}=    Get File    ${menu_file}    encoding=UTF-8
   
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
   
    ${tartalom_content}=    Get File    ${tartalomjegyzek_file}    encoding=UTF-8
    ${tartalom_content}=    Convert To Lower Case   ${tartalom_content}  
    ${tartalom_lines}=    Split To Lines    ${tartalom_content}
    ${tartalom_lines_count}=    Get Length    ${tartalom_lines}
    Log String To Console    Tartalomjegyzék fájl sorok száma: ${ tartalom_lines_count}  
    
    #első sor a fejléc, azt kihagyjuk
   
     #Tartalomjegyzék szövegek ellenőrzése
     ${found_count}=    Set Variable    0
     ${not_found_count}=    Set Variable    0

    Log String To Console    \n>>>>> Tartalomjegyzék szövegek ellenőrzése a Digitális anyagban
    FOR    ${line_index}    IN RANGE    1    ${tartalom_lines_count}
        ${line}=    Get From List    ${tartalom_lines}    ${line_index}
        #Log String To Console    \n[DEBUG] Tartalomjegyzék sor: ${line}
        ${parts}=    Split String    ${line}    ;
        ${level}=    Get From List    ${parts}    0
        ${szoveg}=    Get From List    ${parts}    1
        #kisbetűsre alakítás
        ${szoveg}=    Convert To Lower Case   ${szoveg}
        #Log String To Console    [DEBUG] Szöveg ellenőrzése: ${szoveg}
       
        #keressük meg a szöveget a digitális anyagban
        ${all_text}=    Set Variable    ${menu_files_content}
        #Log String To Console    [DEBUG] Keresendő szöveg: '''${szoveg}'''
        #${found}=    Evaluate    '''${szoveg}''' in '''${all_text}'''
        ${found}=    Evaluate    bool(re.search($szoveg, $all_text, re.IGNORECASE | re.MULTILINE))    re

        IF    ${found}
              ${found_count}=   Evaluate    ${found_count}+1
            Log String To Console    \t[___OK] ${szoveg}
            ${new_err}=    Set Variable    ___OK: ${szoveg}
            Append To List    ${errors}    ${new_err}
        ELSE
            ${not_found_count}=   Evaluate    ${not_found_count}+1
            Log String To Console    \t[NINCS] ${szoveg}
            ${new_err}=    Set Variable    NINCS: ${szoveg}
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
    #Delete Variable    ${all_text}
    #Delete Variable    ${pars}
    #Delete Variable    ${par}
    #Delete Variable    ${text}

    Log String To Console    <<<<<< Kézirat és DT összhang ellenőrzés vége <<<<<<<<  ${is_disabled}
  

