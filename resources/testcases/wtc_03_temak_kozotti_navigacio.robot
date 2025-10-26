*** Settings ***
Library    SeleniumLibrary 
Resource   ${CURDIR}/../keywords.robot
Resource   ${CURDIR}/../../PLG-02-Excel-kitolto.robot


*** Keywords ***
Témák közötti navigáció ellenőrzése
    [Documentation]    Témák közötti navigáció ellenőrzése
    Log String To Console    \n[wtc_03_temak_kozotti_navigacio] Témák közötti navigáció ellenőrzése
    ${testCase_row}=    Set Variable    5
   ${err_msg}=    Set Variable    ${EMPTY}
   ${errors}=    Create List
    ${CR}=    Set Variable    ;
     ${next_button}=    Set Variable    ${EMPTY}
   ${is_disabled}=    Set Variable    None


    ${rc}    ${msg}=    Run Keyword And Ignore Error     Wait Until Page Contains Element    xpath=//button[contains(@aria-label,'Következő oldalra lépés')]   10s    
    Log String To Console    \nVárakozás eredménye: ${rc} ${msg}
    IF    '${rc}' == 'PASS'
        ${next_button}=    Get WebElement    xpath=//button[contains(@aria-label,'Következő oldalra lépés')]
        TRY 
           WHILE    ${is_disabled} is ${NONE}
                #Log String To Console    Következő oldal gomb engedélyezett, lépés a következő oldalra.
                TRY 
                     Click Button       xpath=//button[contains(@aria-label,'Következő oldalra lépés')]
                EXCEPT    AS    ${e1}
                    Log String To Console    [WARNING] Hiba a következő oldal gomb kattintásakor: ${e1}
                     #felugró teszt megszakítása gomb kezelése
                    #Run Keyword And Ignore Error    Wait Until Element Is Visible    xpath=//button[contains(., 'Teszt megszakítása')]    0.1s
                    #Run Keyword And Ignore Error    Click Element    xpath=//button[contains(., 'Teszt megszakítása')]

                    #felugró teszt újrakezdés gomb kezelése
                    Run Keyword And Ignore Error    Wait Until Element Is Visible    xpath=//button[contains(., 'Újrakezdés')]    0.01s
                    Run Keyword And Ignore Error    Click Element    xpath=//button[contains(., 'Újrakezdés')]
                     Sleep    1s
                     #retry
                    Click Button       xpath=//button[contains(@aria-label,'Következő oldalra lépés')]
                END
               
             
              

                ${is_disabled}=    Get Element Attribute    ${next_button}    disabled
                #Log String To Console    Következő oldal gomb le van tiltva vagy ismeretlen állapot: ${is_enabled}

                IF   $is_disabled == True or $is_disabled == 'true' or $is_disabled == 'True'
                    #Log String To Console    Következő oldal gomb le van tiltva vagy ismeretlen állapot: ${is_disabled}
                    Exit For Loop
                END
           END
           #Sikeres navigáció az összes oldalra
        EXCEPT    AS    ${e}
            #Sikertelen navigáció az összes oldalra
            Log String To Console    [ERROR] Hiba a következő oldal gomb állapot lekérdezésekor: ${e}
            ${new_err}=    Set Variable    Hiba az oldalak közti lapozásban: ${e}
            Append To List    ${errors}    ${new_err}
        END
    END
    #Minden menupont nyitva
     Log String To Console   \n>>>>> Végeredmény visszaírása az Excel-be
    ${unique_errors}=    Remove Duplicates    ${errors}
    ${err_msg}=    Catenate    SEPARATOR=${CR}    @{unique_errors}
    #Log String To Console    \nEredmény visszaírása:${DIGITALIS_EXCEL_FILE}  :  ${CURRENT_SHEET_NAME}    ${testCase_row}    ${unique_errors}
    Mark WebTest Status    ${DIGITALIS_EXCEL_FILE}    ${CURRENT_SHEET_NAME}    ${testCase_row}    ${err_msg}

   Run Keyword And Ignore Error    Wait Until Element Is Visible    xpath=//button[contains(., 'Újrakezdés')]    5s
    Run Keyword And Ignore Error    Click Element    xpath=//button[contains(., 'Újrakezdés')]
   