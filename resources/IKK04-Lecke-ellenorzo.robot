*** Settings ***
Resource    ../resources/keywords.robot
Resource    ../resources/variables.robot
Resource    ../resources/testcases/wtc_01_borito_megfelelo.robot
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
   
      Log To Console    ---------------------------------Egy lecke ellenőrzés kezdete---------------------------------
   
            Wait Until Element Is Visible    id=ScormContent    30s
            Select Frame    id=ScormContent

            # Ha megjelenik a folytatás javaslat ablak, kattints a "Folytatás" gombra
            Run Keyword And Ignore Error    Wait Until Element Is Visible    //*[self::button or self::a or self::input][contains(., 'Folytatás') or @value='Folytatás' or @aria-label='Folytatás']    2s
            Run Keyword And Ignore Error    Click Element    xpath=//*[self::button or self::a or self::input][contains(., 'Folytatás') or @value='Folytatás' or @aria-label='Folytatás']
            
          
            Log To Console    Most vagyunk egy leckében
            # Egy lecke ellenőrzése itt történik
               #tartalomjegyzék gomb megnyomása
            Wait Until Page Contains Element    xpath=//button[@aria-label='Tartalomjegyzék']    30s
            ${toc_buttons}=    Get WebElements    xpath=//button[@aria-label='Tartalomjegyzék']
            Run Keyword And Ignore Error    Wait Until Page Does Not Contain Element    css=.cdk-overlay-backdrop    3s
            Click Button    ${toc_buttons}[0]
            Sleep    2s

            #felugró teszt megszakítása gomb kezelése
            Run Keyword And Ignore Error    Wait Until Element Is Visible    xpath=//button[contains(., 'TESZT MEGSZAKÍTÁSA')]    5s
            Run Keyword And Ignore Error    Click Element    xpath=//button[contains(., 'TESZT MEGSZAKÍTÁSA ')]
           
            #címsor kiválasztása a tartalomjegyzékből
            ${home_button}=    Get WebElement    xpath=//span[contains(@class,'node-title')]
            ${home_title}=    Get Text   ${home_button}
            Click Button    ${home_button}
            Log To Console    Beléptünk a tartalomjegyzék első címsorába: \n${home_title}
            
            #
            # TestCase-ek futtatása a leckében
            #
            Log String To Console    \n--- TestCase-ek futtatása a leckében ---\n

            # Összesítés számlálók
            ${check_total}=    Set Variable    0
            ${check_passed}=   Set Variable    0
            ${check_failed}=   Set Variable    0
            
            ${rc}    ${msg}=    Run Keyword And Ignore Error    Boritó megfelelőség ellenőrzése
            ${check_total}=    Evaluate    ${check_total} + 1
            IF    '${rc}' == 'PASS'
                ${check_passed}=    Evaluate    ${check_passed} + 1
            ELSE
                ${check_failed}=    Evaluate    ${check_failed} + 1
                Log String To Console    [HIBA] wtc_01_borito_megfelelo.robot: ${msg}
            END
            
            Sleep    20s
            #Kilépés a leckéből és a browesert bezárjuk
            Close browser
        
            Log To Console    <<<<<< Lecke elleőrzés vége <<<<<<<<
            #Wait Until Element Is Visible    xpath=//button[@id='panelExitBtn']    5s
            #Click Button    xpath=//button[@id='panelExitBtn']
            #Sleep    2s
            #Sure box Igen gomb kezelése
            #Run Keyword And Ignore Error     Wait Until Element Is Visible    xpath=//button[@aria-label='Igen']    3s
            #Run Keyword And Ignore Error    Click Button    xpath=//button[@aria-label='Igen']
            #Run Keyword And Ignore Error    Wait Until Element Is Not Visible    xpath=//button[@aria-label='Igen']    3s
            #Sleep    2s
            #felugró teszt megszakítása gomb kezelése
            #Run Keyword And Ignore Error    Wait Until Element Is Visible    xpath=//*[@id="mat-mdc-dialog-1"]/div/div/test-end-or-interrupt-dialog/div/div[2]/button[3]   10s
            #Run Keyword And Ignore Error    Click Element    xpath=//*[@id="mat-mdc-dialog-1"]/div/div/test-end-or-interrupt-dialog/div/div[2]/button[3]
            #Run Keyword And Ignore Error    Wait Until Element Is Not Visible    xpath=//*[@id="mat-mdc-dialog-1"]/div/div/test-end-or-interrupt-dialog/div/div[2]/button[3]   3s

            #Log To Console    --------------------------------- Tananyag bezárva?${start_index}\n
            #Unselect Frame

            #megvárjuk hogy vissza töltődjön a leckék listája
            #Sleep    2s
            #újra beállítjuk a keresést
            #Lecke Keresés beállítása  
            #Sleep    2s
            
            #Wait Until Element Is Visible    xpath=(//*[contains(@class,'course-object__title')])     20s
            #${leckek}=    Get WebElements    xpath=(//*[contains(@class,'course-object__title')])
            #${leckek_szama}=    Get Length    ${leckek}
            #Log String To Console    Újar keresett leckék száma: ${leckek_szama}/${index}
       
    #END
     #Log String To Console    \n\[2/24] Kurzus lista beolvasása - Kész        
      #Sleep    30s
