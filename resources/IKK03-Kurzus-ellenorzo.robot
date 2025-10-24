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

      # Ellenőrizzük, hogy van-e Legutóbb megnyitott blokk
    ${offset}=    Set Variable    0
    ${rc}    ${msg}=    Run Keyword And Ignore Error     Wait Until Element Is Visible   xpath=//h2[contains(text(), 'Legutóbb megnyitott')]    5s
    Log To Console    Legutóbb megnyitott blokk ellenőrzése: ${rc} : ${msg}
    IF   '${rc}' == 'PASS'
        Log To Console    Legutóbb megnyitott blokk megtalálva, kihagyva a leckék bejárásából.
        ${offset}=    Set Variable    1
    END
    #összegyűjtjük az összes Folytatás gombot

      
    # Végigmegyünk a kurzusokon és kiírjuk a címüket
    # Minden Folytatás gomb keresése: <button class="button-launch">, benne <span class="mdc-button__label">'Folytatás'
    ${folytatas_buttons}=    Get WebElements    xpath=//button[contains(@class,'button-launch')]
      #${folytatas_buttons}=    Get WebElements    xpath=//button[contains(text(), 'Folytatás')]
    ${folytatas_szama}=    Get Length    ${folytatas_buttons}
    Log String To Console    Talált Folytatás gombok száma: ${folytatas_szama} , offset: ${offset}
    ${folytatas_button}=    Get From List    ${folytatas_buttons}  ${offset}
        
    ${leckek}=    Get WebElements    xpath=(//*[contains(@class,'course-object__title')])
    ${lecke_szam}=    Get Length    ${leckek}
    Log String To Console    Talált leckék száma: ${lecke_szam}

    ${lecke_elem}=    Get From List    ${leckek}    ${offset}
    ${lecke_cim}=    Get Text    ${lecke_elem}
  
      Log To Console    Lecke: ${lecke_cim}
    
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
      
      
      # Egy lecke ellenőrzése itt történik
        Egy lecke ellenőrzése 
      
      #Kilépés a leckéből és a browesert bezárjuk
      Close Browser
      
       


 Kurzus ellenőrzés kész
    [Documentation]    Kurzus ellenőrzés kész   
    Log String To Console    \n\[3/24] Egy kurzus ellenőrzése - Kész
