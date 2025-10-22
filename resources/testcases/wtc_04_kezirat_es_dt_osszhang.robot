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

  # Várjunk, amíg legalább egy elem megjelenik
  #//span[contains(@class,'node-title')]
    Wait Until Page Contains Element    xpath=//span[contains(@class,'node-title')]    10s

    Nyisd ki a menü minden szintjét

    ${titles}=    Get WebElements    xpath=//span[contains(@class,'node-title')]

    ${title_count}=    Get Length    ${titles}
    Log To Console    Talált címek száma: ${title_count}
    ${index}=    Set Variable    0
    FOR    ${elem}    IN    @{titles}
        ${text}=    Get Text    ${elem}
        ${xpath}=    Set Variable    (//span[contains(@class,'node-title')])[${index + 1}]
        ${level}=    Get Indent Level For Item    ${xpath}
        Log To Console    ---${text}+++ [szint: ${level}]
        ${index}=    Set Variable    ${index + 1}
    END


Nyisd ki a menü minden szintjét
     # Mindig térjünk vissza a top-dokumentumhoz
  

