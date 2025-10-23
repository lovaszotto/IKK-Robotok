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

   ${next_button}=    Set Variable    ${EMPTY}
   ${is_disabled}=    Set Variable    None

    ${rc}    ${msg}=    Run Keyword And Ignore Error     Wait Until Page Contains Element    xpath=//button[contains(@aria-label,'Következő oldalra lépés')]   10s    
    Log To Console    \nVárakozás eredménye: ${rc} ${msg}
    IF    '${rc}' == 'PASS'
        ${next_button}=    Get WebElement    xpath=//button[contains(@aria-label,'Következő oldalra lépés')]
        WHILE    ${is_disabled} is ${NONE}
            #Log To Console    Következő oldal gomb engedélyezett, lépés a következő oldalra.
            Click Button       xpath=//button[contains(@aria-label,'Következő oldalra lépés')]
            #Sleep   2s
            ${is_disabled}=    Get Element Attribute    ${next_button}    disabled
            #Log To Console    Következő oldal gomb le van tiltva vagy ismeretlen állapot: ${is_enabled}

            IF   $is_disabled == True or $is_disabled == 'true' or $is_disabled == 'True'
                Log To Console    Következő oldal gomb le van tiltva vagy ismeretlen állapot: ${is_disabled}
                Exit For Loop
            END
        END
    END

    Log To Console    <<<<<< Kézirat és DT összhang ellenőrzés vége <<<<<<<<  ${is_disabled}
    Sleep    300
   


