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
   ${is_enabled}=    Set Variable    'None'
    WHILE    ${is_enabled} == 'None'
        ${rc}    ${msg}=    Run Keyword And Ignore Error     Wait Until Page Contains Element    xpath=//button[contains(@aria-label,'Következő oldalra lépés')]   10s    
        Log To Console    \nVárakozás eredménye: ${rc} ${msg}
        IF    '${rc}' == 'PASS'
            ${next_button}=    Get WebElement    xpath=//button[contains(@aria-label,'Következő oldalra lépés')]
            ${is_enabled}=    Get Element Attribute    ${next_button}    disabled
            Log To Console    Következő oldal gomb disabled attribútuma: ${is_enabled}
            IF    '${is_enabled}' == 'None'
                Log To Console    Következő oldal gomb engedélyezett, lépés a következő oldalra.
                Click Button       xpath=//button[contains(@aria-label,'Következő oldalra lépés')]
                Sleep   2s
                 #várjunk amíg a tartalomjegyzék elemei megjelennek
                #Wait Until Element Is Visible    xpath=//span[contains(@class,'node-title')]    10s
            END
        ELSE
            ${is_enabled}=    Set Variable    'Disabled'
        END
    END
    Log To Console    <<<<<< Kézirat és DT összhang ellenőrzés vége <<<<<<<<  ${is_enabled}
    
   


   
   
    




Nyisd ki a menü minden szintjét
     # Mindig térjünk vissza a top-dokumentumhoz
  

