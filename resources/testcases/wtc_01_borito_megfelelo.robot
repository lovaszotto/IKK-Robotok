*** Settings ***
Resource   ${CURDIR}/../keywords.robot
Resource   ${CURDIR}/../../PLG-02-Excel-kitolto.robot

*** Keywords ***
Boritó megfelelőség ellenőrzése
    [Documentation]    Borító megfelelőség ellenőrzése
    Log String To Console    \n**************************************************************************
    Log String To Console    * wtc_01-Borító megfelelőség ellenőrzése
    Log String To Console    **************************************************************************\n
 
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
    #${home_title}=    Get Text   ${home_button}
    ${home_title}=    Get Text  xpath=//span[contains(@class,'node-title')]
    
    #Log String To Console    >>>>> Borító címe a DT-ben: ${home_title}
    #a ${home_title} -ben \nBlokk cseréje üres karakterre
    ${home_title}=    Replace String    ${home_title}    \nBlokk    ${EMPTY}
    #Log String To Console    >>>>> Borító címe a DT-ben (\\nBlokk eltávolítva): ${home_title}
    ${home_title}=    Strip String    ${home_title}
    #Log String To Console    >>>>> Borító címe a DT-ben (trim): ${home_title}

    
    Log String To Console    >>> node clicked
    TRY
        Click Button    ${home_button}    
    EXCEPT
        Log String To Console    >>> Click exception home_button gombnál
     #popup bezárása
        Wait Until Element Is Visible    xpath=//button[@aria-label='Teszt folytatása' or @aria-label='Teszt megszakítása' or @aria-label='Folytatás']  
        Click Element    xpath=//button[@aria-label='Teszt folytatása' or @aria-label='Teszt megszakítása' or @aria-label='Folytatás'] 
         Sleep    2s
         #Újra próbálkozás
         Wait Until Page Contains Element    xpath=//span[contains(@class,'node-title')]    10s
        Click Button    ${home_button}
    END
    Log String To Console    >>> node clicked
 

    Fill Excel Cell    ${DIGITALIS_EXCEL_FILE}     Alapadatok     3    2    ${home_title}

    Fill Excel Cell    ${DIGITALIS_EXCEL_FILE}     ${CURRENT_SHEET_NAME}     1    2    ${home_title}
    Fill Excel Cell    ${DIGITALIS_EXCEL_FILE}     ${DIGITALIS_EXCEL_SHEET_MK}     2    2    ${home_title}
    
    # Dokumentum cím ellenőrzése
    ${dokumentum_cimsor} =    Get Variable Value    ${DOKUMENTUM_CIMSOR}    ${EMPTY}
    ${dokumentum_cimsor} =   Strip String    ${dokumentum_cimsor}
    Log String To Console    DT címe: ${home_title}
    Log String To Console    Kézirat címe: ${dokumentum_cimsor}
    #egyenlőség vizsgálata ${dokumentum_cimsor}' != '${home_title}'
    ${dokumentum_cimsor_upper}=    Convert To Upper Case    ${dokumentum_cimsor}
    ${dokumentum_cimsor_upper}=    Strip String    ${dokumentum_cimsor_upper}
    ${home_title_upper}=    Convert To Upper Case    ${home_title}
    ${home_title_upper}=    Strip String    ${home_title_upper}

    IF    '${dokumentum_cimsor_upper}' != '${home_title_upper}'
        ${err_msg}=    Set Variable    A dokumentum címsor nem egyezik meg a várt értékkel. Kézirat: '${dokumentum_cimsor_upper}', DT: '${home_title_upper}'
        Append To List    ${errors}    ${err_msg}
    END
    
 
    # Alapadatok kitöltése
    Fill Excel Cell    ${DIGITALIS_EXCEL_FILE}    Alapadatok    3    1    ${KURZUS}
    Fill Excel Cell    ${DIGITALIS_EXCEL_FILE}    Alapadatok    3    4    Kézirat részek azonosítója
    
    
    #Végeredmény visszaírása az Excel-be
    ${unique_errors}=    Remove Duplicates    ${errors}
    ${err_msg}=    Catenate    SEPARATOR=${CR}    @{unique_errors}
 
    Log String To Console    \nEredmény visszaírása:${DIGITALIS_EXCEL_FILE}  :  ${CURRENT_SHEET_NAME}    ${testCase_row}    ${err_msg}
    Mark WebTest Status    ${DIGITALIS_EXCEL_FILE}    ${CURRENT_SHEET_NAME}    ${testCase_row}    ${err_msg}
   