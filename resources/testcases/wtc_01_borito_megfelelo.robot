*** Settings ***
Resource   ${CURDIR}/../keywords.robot
Resource   ${CURDIR}/../../PLG-02-Excel-kitolto.robot

*** Keywords ***
Boritó megfelelőség ellenőrzése
    [Documentation]    Borító megfelelőség ellenőrzése
    Log String To Console    [wtc_01_borito_megfelelo] Borító megfelelőség ellenőrzése
    ${testCase_row}=    Set Variable    3

  #impresszum keresése és kiválasztása
    Run Keyword And Ignore Error    Wait Until Element Is Visible    xpath=//span[contains(text(),'Impresszum')]    5s
    ${impresszum_button}=    Get WebElement    xpath=//span[contains(text(),'Impresszum')]
    ${impresszum_title}=    Get Text   ${impresszum_button}    
    Log To Console    Impresszum címsor megtalálva: \n${impresszum_title}
    Click Button    ${impresszum_button}    
    
    #impresszum tartalom beolvasása

    # Alapadatok kitöltése
    Fill Excel Cell    ${DIGITALIS_EXCEL_FILE}    Alapadatok    3    1    ${KURZUS}
     Fill Excel Cell    ${DIGITALIS_EXCEL_FILE}    Alapadatok    3    4    Kézirat részek azonosítója
    #Végeredmény visszaírása az Excel-be
    ${err_msg}=    Set Variable    ${EMPTY}
    Log String To Console    Eredmény visszaírása:${DIGITALIS_EXCEL_FILE}  :  ${CURRENT_SHEET_NAME}    ${testCase_row}    ${err_msg}
    Mark WebTest Status    ${DIGITALIS_EXCEL_FILE}    ${CURRENT_SHEET_NAME}    ${testCase_row}    ${err_msg}
