*** Settings ***
Resource    ../resources/keywords.robot
Resource    ../resources/variables.robot
Resource    IKK04-Lecke-ellenorzo.robot
Library     String
Library     BuiltIn
Library     Collections
Library     OperatingSystem
Library     Process
Library    ../libraries/keep_awake.py
Library    SeleniumLibrary

*** Keywords ***
Egy kurzus ellenőrzése
    [Documentation]    Egy kurzus ellenőrzése
    Log String To Console    \n\[3/24] Egy kurzus ellenőrzése
    #Open Browser    ${APP_URL}    edge    remote_url=http://127.0.0.1:9222

    # csatlakozunk a már megnyitott böngészőablakhoz
    #az ablak azonosítót az induláskor kaptuk meg
    #Switch Browser    ${HANDLE}[0]

    #teszteléskor önálló futtatás esetén
    #Log To Console    nyitott böngészők lekérése
    #${handle}=    Get Window Handles
    #Log To Console    nyitott böngészők: ${handle}

    # Csatlakozás a már futó böngészőhöz
   #${browser}=    Open Browser    about:blank    browser=chrome    remote_url=http://127.0.0.1:9222
     # Ellenőrzés
    #${title}=    Get Title
    #Log To Console    Böngésző címe: ${title}

    #itt vagyunk a fő témán belül
    Wait Until Element Is Visible    xpath=//*[contains(text(), 'Tartalom')]    30s
    Wait Until Element Is Visible    xpath=//h1    20s
    ${tema_h1}=    Get Text    xpath=//h1
    Log String To Console    >>>>>>>>>>>>>>>>>>>>>>>> kurzus főoldal: ${tema_h1} <<<<<<<<<<<<<<<<<<<<<<<
   Lecke lista beolvasása

 

Lecke Keresés beállítása
    [Documentation]    Lecke Keresés beállítása
    Log String To Console     \n\[1a/24] Lecke Keresés beállítása
    Wait Until Element Is Visible      xpath=//input[@placeholder="Keresés"]     10s
    ${kurzus}=    Get Variable Value    ${KURZUS}    default_value=NONE
    #cserélje le a benne lévő * karaktert üres karakterre
    ${kurzus}=    Replace String    ${kurzus}    *    ${EMPTY}
    #addj egy szóközt a kurzus érték mögé
    ${kurzus}=    Set Variable    ${kurzus}${SPACE}

    Log To Console    Beállított lecke szűrő: +++++${kurzus}+++++++
    Input Text    xpath=//input[@placeholder="Keresés"]    ${kurzus}
    Press Keys    xpath=//input[@placeholder="Keresés"]        ENTER
    Sleep    2s
    Log String To Console    \[1a/24] Lecke Keresés beállítása - Kész

Lecke lista beolvasása
    [Documentation]    Lecke lista beolvasása
    Log String To Console     \n\[2/24] Lecke lista beolvasása
   
    # Csak akkor várjuk meg a kurzus címkéket, ha már megjelent az 'Tartalom' szöveg
    #Wait Until Element Is Visible    xpath=//*[contains(text(), 'Tartalom')]    30s
    #Sleep    1s
    #Wait Until Element Is Visible    xpath=(//*[contains(@class,'course-object-list')])   20s
    #szűrő beállítása

    Lecke Keresés beállítása
    Sleep    2s
   

    #összegyűjtjük az összes Folytatás gombot
      #${folytatas_buttons}=    Get WebElements    xpath=//button[contains(text(), 'Folytatás')]
    # Végigmegyünk a kurzusokon és kiírjuk a címüket
    # Minden Folytatás gomb keresése: <button class="button-launch">, benne <span class="mdc-button__label">'Folytatás'
    ${folytatas_buttons}=    Get WebElements    xpath=//button[contains(@class,'button-launch')]

    #FOR    ${index}    IN RANGE    ${start_index}    ${leckek_szama}
           
            # Minden iterációban frissítjük a listákat, hogy elkerüljük a StaleElementReferenceException hibát
            ${leckek}=    Get WebElements    xpath=(//*[contains(@class,'course-object__title')])
            ${folytatas_buttons}=    Get WebElements    xpath=//button[contains(@class,'button-launch')]
            ${lecke_elem}=    Get From List    ${leckek}    0
            ${lecke_cim}=    Get Text    ${lecke_elem}
            
            Log To Console    Lecke: ${lecke_cim}
            ${folytatas_button}=    Get From List    ${folytatas_buttons}  0
            
            #belépés a leckébe
            Log To Console    >>>>>> Lecke belépés <<<<<<<: ${lecke_cim}
             Click Button    ${folytatas_button}
            
            Wait Until Element Is Visible    id=ScormContent    30s
          #  Select Frame    id=ScormContent

            # Ha megjelenik a folytatás javaslat ablak, kattints a "Folytatás" gombra
          #  Run Keyword And Ignore Error    Wait Until Element Is Visible    //*[self::button or self::a or self::input][contains(., 'Folytatás') or @value='Folytatás' or @aria-label='Folytatás']    2s
          #  Run Keyword And Ignore Error    Click Element    xpath=//*[self::button or self::a or self::input][contains(., 'Folytatás') or @value='Folytatás' or @aria-label='Folytatás']
            
            #tartalomjegyzék gomb kezelése
          #  Wait Until Page Contains Element    xpath=//button[@aria-label='Tartalomjegyzék']    30s
          #  ${toc_buttons}=    Get WebElements    xpath=//button[@aria-label='Tartalomjegyzék']
          #  Run Keyword And Ignore Error    Wait Until Page Does Not Contain Element    css=.cdk-overlay-backdrop    3s
          #  Click Button    ${toc_buttons}[0]
          #  Sleep    2s

            #felugró teszt megszakítása gomb kezelése
            Run Keyword And Ignore Error    Wait Until Element Is Visible    xpath=//button[contains(., 'TESZT MEGSZAKÍTÁSA')]    5s
            Run Keyword And Ignore Error    Click Element    xpath=//button[contains(., 'TESZT MEGSZAKÍTÁSA ')]
            
            Log To Console    Most vagyunk egy leckében: ${lecke_cim}
           
            # Egy lecke ellenőrzése itt történik
             Egy lecke ellenőrzése 
            
            #Kilépés a leckéből és a browesert bezárjuk
            Close Browser
        
            #Log To Console    --------------------------------- Tananyag bezárása?${start_index}
            #Log To Console    <<<<<< Lecke kilépés:${leckek_szama}/${index} <<<<<<<<
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

 Kurzus ellenőrzés kész
    [Documentation]    Kurzus ellenőrzés kész   
    Log String To Console    \n\[3/24] Egy kurzus ellenőrzése - Kész
