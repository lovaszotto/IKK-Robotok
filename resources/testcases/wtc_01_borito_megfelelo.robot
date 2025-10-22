*** Settings ***
Resource   ${CURDIR}/../keywords.robot
Resource   ${CURDIR}/../../PLG-02-Excel-kitolto.robot

*** Keywords ***
Boritó megfelelőség ellenőrzése
    [Documentation]    Borító megfelelőség ellenőrzése
    Log String To Console    [wtc_01_borito_megfelelo] Borító megfelelőség ellenőrzése
    ${testCase_row}=    Set Variable    3
   ${err_msg}=    Set Variable    ${EMPTY}
   ${errors}=    Create List

    #tartalomjegyzék gomb megnyomása
   # Wait Until Page Contains Element    xpath=//button[@aria-label='Tartalomjegyzék']    30s
   # ${toc_buttons}=    Get WebElements    xpath=//button[@aria-label='Tartalomjegyzék']
   # Run Keyword And Ignore Error    Wait Until Page Does Not Contain Element    css=.cdk-overlay-backdrop    3s
   # Click Button    ${toc_buttons}[0]
    #Sleep    2s

 #címsor kiválasztása a tartalomjegyzékből
    ${home_button}=    Get WebElement    xpath=//span[contains(@class,'node-title')]
    ${home_title}=    Get Text   ${home_button}
    #a ${home_title} -ben \nBlokk cseréje üres karakterre
    ${home_title}=    Replace String    ${home_title}    \nBlokk    ${EMPTY}
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
    Wait Until Element Is Visible    xpath=//span[contains(text(),'Impresszum')]    5s
    ${impresszum_button}=    Get WebElement    xpath=//span[contains(text(),'Impresszum')]
    ${impresszum_title}=    Get Text   ${impresszum_button}    
    Click Button    ${impresszum_button}    
    Sleep     2s

    #szerző beolvasása
    Wait Until Element Is Visible   xpath=//div[contains(@class,'custom-format')]//strong[normalize-space(.)='Szerző:']/following-sibling::span[1]    5s
    ${raw}=    Get Text    xpath=//div[contains(@class,'custom-format')]//strong[normalize-space(.)='Szerző:']/following-sibling::span[1]
    ${author}=    Strip String    ${raw}
  
    #szerző ellenőrzése
    ${dokumentum_szerzo} =    Get Variable Value    ${DOKUMENTUM_SZERZO}    ${EMPTY}
    ${dokumentum_szerzo}=    Convert To Uppercase    ${dokumentum_szerzo}
    
    Log To Console    Szerző neve: ${author}
    Log To Console    Dokumentum szerző neve: ${dokumentum_szerzo}
    
    IF    $dokumentum_szerzo != $author
          ${new_err}=    Set Variable     A dokumentum szerzője nem egyezik meg a várt értékkel. Kézirat: '${dokumentum_szerzo}', DT: '${author}'
          Append To List    ${errors}    ${new_err}
    END


    # Alapadatok kitöltése
    Fill Excel Cell    ${DIGITALIS_EXCEL_FILE}    Alapadatok    3    1    ${KURZUS}
    Fill Excel Cell    ${DIGITALIS_EXCEL_FILE}    Alapadatok    3    4    Kézirat részek azonosítója
    
    
    #Végeredmény visszaírása az Excel-be
    ${unique_errors}=    Remove Duplicates    ${errors}
    ${err_msg}=    Catenate    SEPARATOR=${CR}    @{unique_errors}
 
    Log String To Console    \nEredmény visszaírása:${DIGITALIS_EXCEL_FILE}  :  ${CURRENT_SHEET_NAME}    ${testCase_row}    ${err_msg}
    Mark WebTest Status    ${DIGITALIS_EXCEL_FILE}    ${CURRENT_SHEET_NAME}    ${testCase_row}    ${err_msg}
   