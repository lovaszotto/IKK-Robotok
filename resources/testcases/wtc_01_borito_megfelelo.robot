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
    