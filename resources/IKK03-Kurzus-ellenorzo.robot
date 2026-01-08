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
    #Log String To Console    nyitott böngészők lekérése
    #${handle}=    Get Window Handles
    #Log String To Console    nyitott böngészők: ${handle}

    # Csatlakozás a már futó böngészőhöz
   #${browser}=    Open Browser    about:blank    browser=chrome    remote_url=http://127.0.0.1:9222
     # Ellenőrzés
    #${title}=    Get Title
    #Log String To Console    Böngésző címe: ${title}

    #itt vagyunk a fő témán belül
    Wait Until Element Is Visible    xpath=//*[contains(text(), 'Tartalom')]    30s
    Wait Until Element Is Visible    xpath=//h1    20s
    ${tema_h1}=    Get Text    xpath=//h1
    Log String To Console    >>>>>>>>>>>>>>>>>>>>>>>> kurzus főoldal: ${tema_h1} <<<<<<<<<<<<<<<<<<<<<<<
   Lecke lista beolvasása

 

Lecke Keresés beállítása
    [Documentation]    Lecke Keresés beállítása
    Log String To Console     \n\[1a/24] Lecke Keresés beállítása
    Wait Until Element Is Visible      xpath=//input[@placeholder="Keresés"]     1s
    ${kurzus}=    Get Variable Value    ${KURZUS}    default_value=NONE
    #cserélje le a benne lévő * karaktert üres karakterre
    ${kurzus}=    Replace String    ${kurzus}    *    ${EMPTY}
    #addj egy szóközt a kurzus érték mögé
    ${kurzus}=    Set Variable    ${kurzus}${SPACE}

    Log String To Console    Beállított lecke szűrő: +++++${kurzus}+++++++
    Input Text    xpath=//input[@placeholder="Keresés"]    ${kurzus}
    Press Keys    xpath=//input[@placeholder="Keresés"]        ENTER
    #Sleep    2s
    Log String To Console    Lecke Keresés beállítása - Kész\n

Lecke lista beolvasása
    [Documentation]    Lecke lista beolvasása
    Log String To Console     \nLecke lista beolvasása
   
    # Csak akkor várjuk meg a kurzus címkéket, ha már megjelent az 'Tartalom' szöveg
    Wait Until Element Is Visible    xpath=//*[contains(text(), 'Tartalom')]    5s
   
    Lecke Keresés beállítása

   #olytatás gombok és lecke címek lekérése
    Wait Until Element Is Visible    xpath=(//*[contains(@class,'course-object-list')])   5s
 
      # Ellenőrizzük, hogy van-e Legutóbb megnyitott blokk
    ${kurzus}=    Get Variable Value    ${KURZUS}    default_value=NONE
    ${offset}=    Set Variable    0
    ${rc}    ${msg}=    Run Keyword And Ignore Error     Wait Until Element Is Visible   xpath=//h2[contains(text(), 'Legutóbb megnyitott')]    1s
    Log String To Console    Legutóbb megnyitott blokk ellenőrzése: ${rc} : ${msg}
    IF   '${rc}' == 'PASS'
        Log String To Console    Legutóbb megnyitott blokk megtalálva, kihagyva a leckék bejárásából.
        ${offset}=    Set Variable    1
    END

    #Lecke címek lekérése
    ${lecke_cimekWebElements}=    Get WebElements    xpath=//h3[contains(@class,'course-object__title')]
    ${lecke_cimekWebElements_szama}=    Get Length    ${lecke_cimekWebElements}
    Log String To Console    \nTalált lecke címek száma: ${KURZUS}/${lecke_cimekWebElements_szama}   
    IF     ${lecke_cimekWebElements_szama} > 0
       ${error_file}=    Replace String    ${DIGITALIS_EXCEL_FILE}    .xlsx    Hibás_szűrés.txt
      Create File    ${error_file}
      #Append To File    ${error_file}   Hibás a lecke szűrés, túl sok lecke találat: ${lecke_cimekWebElements_szama} ,  ${kurzus} Keresésnél  
      Append To File    ${error_file}   Hibás a lecke szűrés, túl sok lecke találat. 
        #lecke keresése a találatokban
       ${offeset}=     Set Variable    -1

      FOR    ${index}    IN RANGE    ${lecke_cimekWebElements_szama}
          ${lecke_cim_elem}=    Get From List    ${lecke_cimekWebElements}    ${index}
          ${lecke_cim}=    Get Text    ${lecke_cim_elem}
          Log String To Console    Lecke cím ${index}: ${lecke_cim}
          IF    $kurzus in $lecke_cim
              ${offset}=    Set Variable    ${index}
              Log String To Console    \nMegvan a lecke a ${offset} helyen!
          END
      END
    END
    #Ha nincs megfelelő című lecke, akkor vége
    IF    ${offset} == -1
         Log String To Console    [ERROR]Nincs megjeleníthető lecke a beállított szűrőkkel. =>${DIGITALIS_EXCEL_FILE}
        ${error_file}=    Replace String    ${DIGITALIS_EXCEL_FILE}    .v01.xlsx    _Nincs lecke a WEB-en.txt
        Create File    ${error_file}    Nincs megjeleníthető lecke a beállított szűrőkkel.
        Write SumError fájl    ${EMPTY}    ${EMPTY}    wtc-0    Nincs a lecke a WEB-en
      
        Close Browser
        RETURN
    END
    #Folytatás gomok keresése
    ${retry}=    Set Variable    True
    ${folytatas_buttons}=    Get WebElements    xpath=//button[contains(@class,'button-launch')]
      #${folytatas_buttons}=    Get WebElements    xpath=//button[contains(text(), 'Folytatás')]
    ${folytatas_szama}=    Get Length    ${folytatas_buttons}
    Log String To Console    Talált Folytatás gombok száma: ${folytatas_szama} , offset: ${offset}
   
     #Lecke keresés hiba hack!
    
    ${lecke_elem}=    Get From List    ${lecke_cimekWebElements}    ${offset}
    ${lecke_cim}=    Get Text    ${lecke_elem}
  
      Log String To Console    Lecke: ${lecke_cim}
      #belépés a leckébe
      Log String To Console    >>>>>> Lecke belépés <<<<<<<: ${lecke_cim}
      ${folytatas_button}=    Get From List    ${folytatas_buttons}    ${offset}
      
      Log String To Console    >>> Folytatás gomb clicked
      Click Button    ${folytatas_button}
      Log String To Console    >>> folytatas_button clicked


      # Egy lecke ellenőrzése itt történik
        Egy lecke ellenőrzése 
      
      #Kilépés a leckéből és a browesert bezárjuk
      Close Browser
      
       


 Kurzus ellenőrzés kész
    [Documentation]    Kurzus ellenőrzés kész   
    Log String To Console    \n\[3/24] Egy kurzus ellenőrzése - Kész
