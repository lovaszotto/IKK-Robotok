*** Settings ***
Resource   ${CURDIR}/../keywords.robot
Resource   ${CURDIR}/../../PLG-02-Excel-kitolto.robot

*** Keywords ***
Impresszum megfelelőség ellenőrzése
    [Documentation]    Impresszum megfelelőség ellenőrzése
    Log String To Console    \n[wtc_02_impresszum_megfelelo] Impresszum megfelelőség ellenőrzése
    ${testCase_row}=    Set Variable    4
   ${err_msg}=    Set Variable    ${EMPTY}
   ${errors}=    Create List

  #impresszum keresése és kiválasztása
    Wait Until Element Is Visible    xpath=//span[contains(text(),'Impresszum')]    5s
    ${impresszum_button}=    Get WebElement    xpath=//span[contains(text(),'Impresszum')]
    ${impresszum_title}=    Get Text   ${impresszum_button}    
    Click Button    ${impresszum_button}    
    Sleep     2s
    ##############################################################################################
    #IKK logo ellenőrzése
    ##############################################################################################
     ${ALT_TEXT}     Set Variable    Az Innovatív Képzéstámogató Központ logója
     ${rc}    ${msg}=    Run Keyword And Ignore Error     Wait Until Element Is Visible    xpath=//img[contains(@alt, '${ALT_TEXT}')]    10s
     IF    '${rc}' == 'PASS'
            ${src}=    Get Element Attribute    xpath=//img[contains(@alt, '${ALT_TEXT}')]    src
            Log To Console    \nKép URL: ${src}
            #ha scr üres
            IF    '${src}' == ''
                ${new_err}=    Set Variable     Az IKK logó nem található meg az impresszumban!
                Append To List    ${errors}    ${new_err}
            END
    ELSE
              ${new_err}=    Set Variable     Az IKK logó nem található meg az impresszumban!
              Append To List    ${errors}    ${new_err}
    END
   
    ##############################################################################################
    #szerző ellenőrzése
    ##############################################################################################

    ${rc}    ${msg}=    Run Keyword And Ignore Error     Wait Until Element Is Visible   xpath=//div[contains(@class,'custom-format')]//strong[normalize-space(.)='Szerző:']/following-sibling::span[1]    5s
    IF    '${rc}' == 'PASS'
        ${raw}=    Get Text    xpath=//div[contains(@class,'custom-format')]//strong[normalize-space(.)='Szerző:']/following-sibling::span[1]
        ${author}=    Strip String    ${raw}
        ${author}=   Convert To UpperCASE    ${author}
  
        ${dokumentum_szerzo} =    Get Variable Value    ${DOKUMENTUM_SZERZO}    ${EMPTY}
        ${dokumentum_szerzo}=    Convert To Uppercase    ${dokumentum_szerzo}

        Log To Console    Szerző neve: ${author}
        Log To Console    Dokumentum szerző neve: ${dokumentum_szerzo}
        
        IF    $dokumentum_szerzo != $author
            ${new_err}=    Set Variable     A dokumentum szerzője nem egyezik meg a várt értékkel. Kézirat: '${dokumentum_szerzo}', DT: '${author}'
            Append To List    ${errors}    ${new_err}
        END
    ELSE
        ${new_err}=    Set Variable     Szerző mező nem található meg az impresszumban!
        Append To List    ${errors}    ${new_err}
    END
    
    ##############################################################################################
    #Lektorok ellenőrzése
    ##############################################################################################
    
    ${rc}    ${msg}=    Run Keyword And Ignore Error     Wait Until Element Is Visible    xpath=//strong[contains(., 'További szakmai közreműködők')]    10s
     IF    '${rc}' == 'PASS'
        ${text}=    Get Text    xpath=//strong[contains(., 'További szakmai közreműködők')]/following-sibling::*[1]
        ${text}=    Strip String    ${text}
        ${text}=   Convert To UpperCASE    ${text}    
        Log To Console    \nTovábbi szakmai közreműködők: ${text}
        ${dokumentum_szakmai_lektor} =    Get Variable Value    ${DOKUMENTUM_SZAKMAI_LEKTOR}    ${EMPTY}
        IF    $dokumentum_szakmai_lektor != $text
            ${new_err}=    Set Variable     A dokumentum szakmai lektor nem egyezik meg a várt értékkel. Kézirat: '${dokumentum_szakmai_lektor}', DT: '${text}'
            Append To List    ${errors}    ${new_err}
        END 
     ELSE
          ${new_err}=    Set Variable     További szakmai közreműködők mező nem található meg az impresszumban!
          Append To List    ${errors}    ${new_err}
     END
    
    

    
    
    #Végeredmény visszaírása az Excel-be
    ${unique_errors}=    Remove Duplicates    ${errors}
    ${err_msg}=    Catenate    SEPARATOR=${CR}    @{unique_errors}
 
    Log String To Console    \nEredmény visszaírása:${DIGITALIS_EXCEL_FILE}  :  ${CURRENT_SHEET_NAME}    ${testCase_row}    ${err_msg}
    Mark WebTest Status    ${DIGITALIS_EXCEL_FILE}    ${CURRENT_SHEET_NAME}    ${testCase_row}    ${err_msg}
   