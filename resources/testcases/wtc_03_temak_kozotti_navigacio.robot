*** Settings ***
Library    SeleniumLibrary 
Library    RequestsLibrary
Library    Collections
Library    OperatingSystem

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
     ${leckek_szama}=    Set Variable    0

    #felugró teszt megszakítása gomb kezelése
    Log String To Console    \nTeszt megszakítás popup kezelés
    Run Keyword And Ignore Error    Wait Until Element Is Visible    xpath=//button[contains(., 'Teszt megszakítása')]    1s
    Run Keyword And Ignore Error    Click Element    xpath=//button[contains(., 'Teszt megszakítása')]
    Run Keyword And Ignore Error    Wait Until Element Is Not Visible    xpath=//button[contains(., 'Teszt megszakítása')]    1s


    ${rc}    ${msg}=    Run Keyword And Ignore Error     Wait Until Page Contains Element    xpath=//button[contains(@aria-label,'Következő oldalra lépés')]   10s    
    Log String To Console    \nVárakozás eredménye: ${rc} ${msg}
 
    IF    '${rc}' == 'PASS'
        ${next_button}=    Get WebElement    xpath=//button[contains(@aria-label,'Következő oldalra lépés')]
        TRY 
           WHILE    ${is_disabled} is ${NONE}
                #Log String To Console    Következő oldal gomb engedélyezett, lépés a következő oldalra.
                TRY 
                   #Log To Console    Következő oldal gomb kattintás előtt
                    #felugró teszt megszakítása gomb kezelése
                    Run Keyword And Ignore Error    Wait Until Element Is Visible    xpath=//button[contains(., 'Teszt megszakítása')]    0.1s
                    Run Keyword And Ignore Error    Click Element    xpath=//button[contains(., 'Teszt megszakítása')]
                    Run Keyword And Ignore Error    Wait Until Element Is Not Visible    xpath=//button[contains(., 'Teszt megszakítása')]    0.1s
            

                    #Wait Until Page Does Not Contain Element    css=.cdk-overlay-backdrop    5s

                    Click Button       xpath=//button[contains(@aria-label,'Következő oldalra lépés')]
                   #Log To Console    Következő oldal gomb kattintás után
                      #felugró teszt megszakítása gomb kezelése
                    #Run Keyword And Ignore Error    Wait Until Element Is Visible    xpath=//button[contains(., 'Teszt megszakítása')]    0.1s
                    #Run Keyword And Ignore Error    Click Element    xpath=//button[contains(., 'Teszt megszakítása')]
                    #Run Keyword And Ignore Error    Wait Until Element Is Not Visible    xpath=//button[contains(., 'Teszt megszakítása')]    0.1s
                
                    #todo egy oldal tartalmának ellenőrzése
       
                    ${images}=    Get WebElements    xpath=//app-image-field//img
                    ${image_count}=    Get Length    ${images}
                    Log String To Console    >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>Talált képek száma: ${image_count}
                    FOR    ${img}    IN    @{images}
                     
                        ${alt}=    Get Element Attribute    ${img}    alt
                        Log String To Console    Kép alt: ${alt}
                        ${src}=    Get Element Attribute    ${img}    src
                        Log String To Console    Kép forrás: ${src}
                    END




                     ${leckek_szama}=    Evaluate    ${leckek_szama} + 1
                EXCEPT    AS    ${e1}
                    Log String To Console    [WARNING] Hiba a következő oldal gomb kattintásakor: ${e1}
                     #felugró teszt megszakítása gomb kezelése
                    Run Keyword And Ignore Error    Wait Until Element Is Visible    xpath=//button[contains(., 'Teszt megszakítása')]    0.1s
                    Run Keyword And Ignore Error    Click Element    xpath=//button[contains(., 'Teszt megszakítása')]
                    Run Keyword And Ignore Error    Wait Until Element Is Not Visible    xpath=//button[contains(., 'Teszt megszakítása')]    0.1s

                    #felugró teszt újrakezdés gomb kezelése
                    Run Keyword And Ignore Error    Wait Until Element Is Visible    xpath=//button[contains(., 'Újrakezdés')]    0.01s
                    Run Keyword And Ignore Error    Click Element    xpath=//button[contains(., 'Újrakezdés')]
                    Run Keyword And Ignore Error    Wait Until Element Is Not Visible    xpath=//button[contains(., 'Újrakezdés')]    0.01s
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
   
    #oldalszám visszaírása
    Fill Excel Cell    ${DIGITALIS_EXCEL_FILE}     Alapadatok     3    5    ${leckek_szama}
   Run Keyword And Ignore Error    Wait Until Element Is Visible    xpath=//button[contains(., 'Újrakezdés')]    1s
    Run Keyword And Ignore Error    Click Element    xpath=//button[contains(., 'Újrakezdés')]
   Run Keyword And Ignore Error    Wait Until Element Is Not Visible    xpath=//button[contains(., 'Újrakezdés')]    1s