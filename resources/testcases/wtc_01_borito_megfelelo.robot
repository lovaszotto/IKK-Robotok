*** Settings ***
Resource   ${CURDIR}/../keywords.robot
Resource   ${CURDIR}/../../PLG-02-Excel-kitolto.robot

*** Keywords ***
Boritó megfelelőség ellenőrzése
    [Documentation]    Borító megfelelőség ellenőrzése
    Log String To Console    [wtc_01_borito_megfelelo] Borító megfelelőség ellenőrzése
    ${testCase_row}=    Set Variable    3
   ${err_msg}=    Set Variable    ${EMPTY}

 #címsor kiválasztása a tartalomjegyzékből
    ${home_button}=    Get WebElement    xpath=//span[contains(@class,'node-title')]
    ${home_title}=    Get Text   ${home_button}
    #a ${home_title} -ben \nBlokk cseréje üres karakterre
    ${home_title}=    Replace String    ${home_title}    \nBlokk    ${EMPTY}
     Log To Console    Beléptünk a tartalomjegyzék első címsorába: \n${home_title}
    Click Button    ${home_button}
    Sleep     2s
    Log String To Console    DT címe: ${home_title}
    Fill Excel Cell    ${DIGITALIS_EXCEL_FILE}     Alapadatok     3    2    ${home_title}
    Fill Excel Cell    ${DIGITALIS_EXCEL_FILE}     ${CURRENT_SHEET_NAME}     1    2    ${home_title}
    
    # Dokumentum cím ellenőrzése
    ${dokumentum_cimsor} =    Get Variable Value    ${DOKUMENTUM_CIMSOR}    ${EMPTY}
    IF    $dokumentum_cimsor != $home_title
        ${err_msg}=    Set Variable    A dokumentum címsor nem egyezik meg a várt értékkel. Kézirat: '${dokumentum_cimsor}', DT: '${home_title}'
    END
    

  #impresszum keresése és kiválasztása
    Run Keyword And Ignore Error    Wait Until Element Is Visible    xpath=//span[contains(text(),'Impresszum')]    5s
    ${impresszum_button}=    Get WebElement    xpath=//span[contains(text(),'Impresszum')]
    ${impresszum_title}=    Get Text   ${impresszum_button}    
    Log To Console    Impresszum címsor megtalálva: \n${impresszum_title}
    Click Button    ${impresszum_button}    
    
    #impresszum tartalom beolvasása
    ${text_fields}=      Get WebElements    xpath=//app-formatted-text-field
   #kiirjuk a találatok számát
    ${text_fields_count}=    Get Length    ${text_fields}
    Log To Console    Impresszum szöveg mezők száma: ${text_fields_count}
   FOR    ${text_field}    IN    ${text_fields}
        ${field_text}=    Get Text    ${text_field}
        Log To Console    Impresszum szöveg mező tartalma: \n${field_text}
        #keressük meg a szerző és lektor szöveget
       
   END
   
    #szerző beolvasása
   
    # Alapadatok kitöltése
    Fill Excel Cell    ${DIGITALIS_EXCEL_FILE}    Alapadatok    3    1    ${KURZUS}
    Fill Excel Cell    ${DIGITALIS_EXCEL_FILE}    Alapadatok    3    4    Kézirat részek azonosítója
    #Végeredmény visszaírása az Excel-be
 
    Log String To Console    Eredmény visszaírása:${DIGITALIS_EXCEL_FILE}  :  ${CURRENT_SHEET_NAME}    ${testCase_row}    ${err_msg}
    Mark WebTest Status    ${DIGITALIS_EXCEL_FILE}    ${CURRENT_SHEET_NAME}    ${testCase_row}    ${err_msg}
