*** Settings ***
Resource    ../resources/keywords.robot
Resource    ../resources/variables.robot
Resource    ../resources/testcases/wtc_01_borito_megfelelo.robot
Resource    ../resources/testcases/wtc_02_impresszum_megfelelo.robot
Resource    ../resources/testcases/wtc_04_kezirat_es_dt_osszhang.robot
Resource    ../resources/testcases/wtc_03_temak_kozotti_navigacio.robot
Resource    ../resources/testcases/wtc_05_magyar_nyelvu.robot
Resource    ../resources/testcases/wtc_10_tartalmaz_statikus_mediaelemeket.robot
Resource    ../resources/testcases/wtc_11_tartalmaz_egyeb_mediaelemeket.robot
Resource    ../resources/testcases/wtc_09_tartalmaz_fogalomtarat.robot


Library     String
Library     BuiltIn
Library     Collections
Library     OperatingSystem
Library     Process
Library    ../libraries/keep_awake.py
Library    SeleniumLibrary 

*** Keywords ***


Egy lecke ellenőrzése
    [Documentation]    Lecke ellenőrzése
    Log String To Console    \n\[3/24] Egy lecke ellenőrzése
   
      Log String To Console    ---------------------------------Egy lecke ellenőrzés kezdete---------------------------------
   
            Wait Until Element Is Visible    id=ScormContent    20s
            Select Frame    id=ScormContent

            # Ha megjelenik a folytatás javaslat ablak, kattints a "Folytatás" gombra
            Run Keyword And Ignore Error    Wait Until Element Is Visible    //*[self::button or self::a or self::input][contains(., 'Folytatás') or @value='Folytatás' or @aria-label='Folytatás']    1s
            Run Keyword And Ignore Error    Click Element    xpath=//*[self::button or self::a or self::input][contains(., 'Folytatás') or @value='Folytatás' or @aria-label='Folytatás']
            
          
            Log String To Console    Most vagyunk egy leckében
            # Egy lecke ellenőrzése itt történik
            #Popup Handler
             # Ha megjelenik a folytatás javaslat ablak, kattints a "Folytatás" gombra
            #Run Keyword And Ignore Error    Wait Until Element Is Visible    //*[self::button or self::a or self::input][contains(., 'Folytatás') or @value='Folytatás' or @aria-label='Folytatás']    1s
            #Run Keyword And Ignore Error    Click Element    xpath=//*[self::button or self::a or self::input][contains(., 'Folytatás') or @value='Folytatás' or @aria-label='Folytatás']
            #Run Keyword And Ignore Error    Wait Until Element Is Not Visible    //*[self::button or self::a or self::input][contains(., 'Folytatás') or @value='Folytatás' or @aria-label='Folytatás']    1s
         
            #felugró teszt megszakítása gomb kezelése
            #Run Keyword And Ignore Error    Wait Until Element Is Visible    xpath=//*[self::button or self::a or self::input][contains(., 'Teszt megszakítása') or @value='Teszt megszakítása' or @aria-label='Teszt megszakítása']    1s
            #Run Keyword And Ignore Error    Click Element    xpath=//*[self::button or self::a or self::input][contains(., 'Teszt megszakítása') or @value='Teszt megszakítása' or @aria-label='Teszt megszakítása']
            #Run Keyword And Ignore Error    Wait Until Element Is Not Visible    xpath=//*[self::button or self::a or self::input][contains(., 'Teszt megszakítása') or @value='Teszt megszakítása' or @aria-label='Teszt megszakítása']    1s
          
           #felugró tesz folytatása gomb kezelése
            #Run Keyword And Ignore Error    Wait Until Element Is Visible    xpath=//*[self::button or self::a or self::input][contains(., 'Teszt folytatása') or @value='Teszt folytatása' or @aria-label='Teszt folytatása']    1s
            #Run Keyword And Ignore Error    Click Element      xpath=//*[self::buttonxpath=//*[self::button or self::a or self::input][contains(., 'Teszt folytatása') or @value='Teszt folytatása' or @aria-label='Teszt folytatása']   
            #Run Keyword And Ignore Error    Wait Until Element Is Not Visible    xpath=//*[self::buttonxpath=//*[self::button or self::a or self::input][contains(., 'Teszt folytatása') or @value='Teszt folytatása' or @aria-label='Teszt folytatása']    1s
         
            #tartalomjegyzék gomb megnyomása
            Log String To Console    >>> Try to Click tartalomjegyzék gomb
            TRY
                Wait Until Page Contains Element    xpath=//button[@aria-label='Tartalomjegyzék']    10s
                Click Button    xpath=//button[@aria-label='Tartalomjegyzék'] 
            EXCEPT    
                Log String To Console    >>> Click exception tartalomjegyzék gombnál
               #popup bezárása
                Wait Until Element Is Visible    xpath=//button[@aria-label='Teszt folytatása' or @aria-label='Teszt megszakítása' or @aria-label='Folytatás']  
                Click Element    xpath=//button[@aria-label='Teszt folytatása' or @aria-label='Teszt megszakítása' or @aria-label='Folytatás'] 
                Sleep    2s
                #Újra próbálkozás
                Wait Until Page Contains Element    xpath=//button[@aria-label='Tartalomjegyzék']    10s
                Click Button    xpath=//button[@aria-label='Tartalomjegyzék'] 
            END
            Log String To Console    >>> Tartalom clicked

            # Overlay eltávolításának várakozása, ha szükséges
            #Run Keyword And Ignore Error    Wait Until Element Is Not Visible    css:.cdk-overlay-backdrop    5s
            #Click Button    ${toc_buttons}

            # Ha megjelenik a folytatás javaslat ablak, kattints a "Folytatás" gombra
            #Run Keyword And Ignore Error    Wait Until Element Is Visible    //*[self::button or self::a or self::input][contains(., 'Folytatás') or @value='Folytatás' or @aria-label='Folytatás']    1s
            #Run Keyword And Ignore Error    Click Element    xpath=//*[self::button or self::a or self::input][contains(., 'Folytatás') or @value='Folytatás' or @aria-label='Folytatás']
            #Run Keyword And Ignore Error    Wait Until Element Is Not Visible    //*[self::button or self::a or self::input][contains(., 'Folytatás') or @value='Folytatás' or @aria-label='Folytatás']    1s
         
            #felugró teszt megszakítása gomb kezelése
            #Run Keyword And Ignore Error    Wait Until Element Is Visible    xpath=//*[self::button or self::a or self::input][contains(., 'Teszt megszakítása') or @value='Teszt megszakítása' or @aria-label='Teszt megszakítása']    1s
            #Run Keyword And Ignore Error    Click Element    xpath=//*[self::button or self::a or self::input][contains(., 'Teszt megszakítása') or @value='Teszt megszakítása' or @aria-label='Teszt megszakítása']
            #Run Keyword And Ignore Error    Wait Until Element Is Not Visible    xpath=//*[self::button or self::a or self::input][contains(., 'Teszt megszakítása') or @value='Teszt megszakítása' or @aria-label='Teszt megszakítása']    1s
          
           #felugró tesz folytatása gomb kezelése
            #Run Keyword And Ignore Error    Wait Until Element Is Visible    xpath=//*[self::button or self::a or self::input][contains(., 'Teszt folytatása') or @value='Teszt folytatása' or @aria-label='Teszt folytatása']    1s
            #Run Keyword And Ignore Error    Click Element      xpath=//*[self::buttonxpath=//*[self::button or self::a or self::input][contains(., 'Teszt folytatása') or @value='Teszt folytatása' or @aria-label='Teszt folytatása']   
            #Run Keyword And Ignore Error    Wait Until Element Is Not Visible    xpath=//*[self::buttonxpath=//*[self::button or self::a or self::input][contains(., 'Teszt folytatása') or @value='Teszt folytatása' or @aria-label='Teszt folytatása']    1s
            
            #
            # TestCase-ek futtatása a leckében
            #
            Log String To Console    \n--- TestCase-ek futtatása a leckében ---\n

            # Összesítés számlálók
            ${check_total}=    Set Variable    0
            ${check_passed}=   Set Variable    0
            ${check_failed}=   Set Variable    0
            
            #wtc_01_borito_megfelelo.robot futtatása
            ${rc}    ${msg}=    Run Keyword And Ignore Error    Boritó megfelelőség ellenőrzése
            ${check_total}=    Evaluate    ${check_total} + 1
            IF    '${rc}' == 'PASS'
                ${check_passed}=    Evaluate    ${check_passed} + 1
            ELSE
                ${check_failed}=    Evaluate    ${check_failed} + 1
                Log String To Console    [HIBA]  ${msg}
            END
            
            #wtc_02_impresszum_megfelelo.robot futtatása
            ${rc}    ${msg}=    Run Keyword And Ignore Error    Impresszum megfelelőség ellenőrzése
            ${check_total}=    Evaluate    ${check_total} + 1
            IF    '${rc}' == 'PASS'
                ${check_passed}=    Evaluate    ${check_passed} + 1
            ELSE
                ${check_failed}=    Evaluate    ${check_failed} + 1
                 Log String To Console    [HIBA]  ${msg}
            END

           #wtc_03_temak_kozotti_lapozas.robot futtatása és média ellenőrzés

                ${rc}    ${msg}=    Run Keyword And Ignore Error    Témák közötti navigáció ellenőrzése
                ${check_total}=    Evaluate    ${check_total} + 1
                IF    '${rc}' == 'PASS'
                    ${check_passed}=    Evaluate    ${check_passed} + 1
                ELSE
                    ${check_failed}=    Evaluate    ${check_failed} + 1
                    Log String To Console    [HIBA]  ${msg}
                END
    
           
            #wtc_04_kezirat_es_dt_osszhang.robot futtatása
            ${rc}    ${msg}=    Run Keyword And Ignore Error    Kézirat és DT összhang ellenőrzése
            ${check_total}=    Evaluate    ${check_total} + 1
            IF    '${rc}' == 'PASS'
                ${check_passed}=    Evaluate    ${check_passed} + 1
            ELSE
                ${check_failed}=    Evaluate    ${check_failed} + 1
                 Log String To Console    [HIBA]  ${msg}
            END

            #wtc_05_magyar_nyelvu.robot futtatása
            ${rc}    ${msg}=    Run Keyword And Ignore Error    DT nyelv ellenőrzése
            ${check_total}=    Evaluate    ${check_total} + 1
            IF    '${rc}' == 'PASS'
                ${check_passed}=    Evaluate    ${check_passed} + 1
            ELSE
                ${check_failed}=    Evaluate    ${check_failed} + 1
                Log String To Console    [HIBA]  ${msg}
            END

           #wtc_09_tartalmaz_fogalomtárat.robot futtatása
            ${rc}    ${msg}=    Run Keyword And Ignore Error    Tartalmaz fogalomtárat ellenőrzése
            ${check_total}=    Evaluate    ${check_total} + 1
            IF    '${rc}' == 'PASS'
                ${check_passed}=    Evaluate    ${check_passed} + 1
            ELSE
                ${check_failed}=    Evaluate    ${check_failed} + 1
                 Log String To Console    [HIBA]  ${msg}
            END
            #wtc_10_tartalmaz_statikus_mediaelemeket.robot futtatása
            ${rc}    ${msg}=    Run Keyword And Ignore Error    Tartalmaz statikus mediaelemeket ellenőrzése
            ${check_total}=    Evaluate    ${check_total} + 1
            IF    '${rc}' == 'PASS'
                ${check_passed}=    Evaluate    ${check_passed} + 1
            ELSE
                ${check_failed}=    Evaluate    ${check_failed} + 1
                 Log String To Console    [HIBA]  ${msg}
            END
            
            #wtc_11_tartalmaz_egyeb_mediaelemeket.robot futtatása
            ${rc}    ${msg}=    Run Keyword And Ignore Error    Tartalmaz egyeb mediaelemeket ellenőrzése
            ${check_total}=    Evaluate    ${check_total} + 1
            IF    '${rc}' == 'PASS'
                ${check_passed}=    Evaluate    ${check_passed} + 1
            ELSE
                ${check_failed}=    Evaluate    ${check_failed} + 1
                Log String To Console    [HIBA]  ${msg}
            END

            #Kilépés a leckéből és a browesert bezárjuk
            Close browser
        
            Log String To Console                                          <<<<<< Lecke ellenőrzés vége >>>>>\n\n\n
                  #selenium-screenshot törlése selenium-screenshot*.png fájlok törlése
            ${SELENIUM_SCREENSHOT_FILE}=    Set Variable    selenium-screenshot*.png
            Run Keyword And Ignore Error    Remove File    ${SELENIUM_SCREENSHOT_FILE}

