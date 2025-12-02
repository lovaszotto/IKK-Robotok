*** Settings ***
Resource    ../resources/keywords.robot
Resource    ../resources/variables.robot
Resource    ./IKK03-Kurzus-ellenorzo.robot

Library     String
Library     BuiltIn
Library     Collections
Library     OperatingSystem
Library     Process
Library    ../libraries/keep_awake.py
Library    SeleniumLibrary 



*** Variables ***

*** Keywords ***
Téma keresés szűrő beállítása
    [Documentation]    Téma keresés szűrő beállítása
    Log String To Console With File     \n\[1a/24] Téma keresés szűrő beállítása
    Wait Until Element Is Visible    id=mat-input-0    30s
    #a globális ${DTEM} változó értékének lekérése

    ${dtem}=    Get Variable Value    ${DTEM}    default_value=NONE
    #cserélja le a benne lévő * karaktert üres karakterre
    ${dtem}=    Replace String    ${dtem}    *    ${EMPTY}
    #concatenate egy szóközt a DTEM érték mögé
    ${dtem}=    Set Variable    ${DTEM}${SPACE}
    Log String To Console With File    Beállított DTEM szűrő: +++${dtem}+++
    
    Input Text    id=mat-input-0    ${dtem}
    Press Keys    id=mat-input-0        ENTER
    Sleep    2s
    Log String To Console With File    \[1a/24] Téma keresés beállítása - Kész

Megjelenő kurzusok bejárása
    [Documentation]    Megjelenő kurzusok bejárása
    Log String To Console With File     \n\[2/24] Megjelenő kurzusok bejárása
    # Csak akkor várjuk meg a kurzus címkéket, ha már megjelent az 'Aktuális kurzusaim' szöveg
    # Kurzus lista elemek begyűjtése a teljes xpath alapján
    ${courses}=    Create List
    ${status}=    Set Variable    NONE
    #Run Keyword And Ignore Error  Wait Until Element Is Visible    xpath=/html/body/ulms-root/div/main/div/ulms-courses/mat-tab-nav-panel/ulms-registered-courses/div/section/ulms-course-list/ul/li    10s
    ${status}     ${courses}=      Run Keyword And Ignore Error  Wait Until Element Is Visible    xpath=//ulms-course-list-item    5s
    Log String To Console With File    Van Talált kurzusok:  ${status}:${courses}
    IF    $status=='PASS'
        Log String To Console With File    Kurzusok megtalálva a megadott szűrőkkel.

    ELSE
        Log String To Console With File    [ERROR]Nincs megjeleníthető kurzus a beállított szűrőkkel. =>${DIGITALIS_EXCEL_FILE}
        ${error_file}=    Replace String    ${DIGITALIS_EXCEL_FILE}    .v01.xlsx    _Nincs kurzus a WEB-en.txt
        Create File    ${error_file}    Nincs megjeleníthető kurzus a beállított szűrőkkel.
        Write SumError fájl    ${DIGITALIS_EXCEL_FILE}    ${DIGITALIS_EXCEL_SHEET}    wtc-0    Nincs a kurzus a WEB-en
        Close Browser
        RETURN
    END    

    ${courses}=    Get WebElements     xpath=//ulms-course-list-item 
    ${course_count}=    Get Length    ${courses}
    Log String To Console With File    Talált kurzusok száma: ${course_count}
  
      # Ha megjelenik a kétfaktoros javaslat ablak, kattints a "Később" gombra
    Run Keyword And Ignore Error    Wait Until Element Is Visible    xpath=//button[contains(., 'Később')]    2s
    Run Keyword And Ignore Error    Click Element    xpath=//button[contains(., 'Később')]
    Run Keyword And Ignore Error    Wait Until Element Is Not Visible    xpath=//button[contains(., 'Később')]    2s
 
    #időnként duplán jelenik meg
       # Ha megjelenik a kétfaktoros javaslat ablak, kattints a "Később" gombra
    Run Keyword And Ignore Error    Wait Until Element Is Visible    xpath=//button[contains(., 'Később')]    2s
    Run Keyword And Ignore Error    Click Element    xpath=//button[contains(., 'Később')]
    Run Keyword And Ignore Error    Wait Until Element Is Not Visible    xpath=//button[contains(., 'Később')]    2s
 
    ${course_idx}=    Set Variable    1
    
    ${kurzus}=    Get Variable Value    ${KURZUS}    default_value=NONE
    #cserélja le a benne lévő * karaktert üres karakterre
    ${kurzus}=    Replace String    ${kurzus}    *    ${EMPTY}
    FOR    ${idx}    IN RANGE    ${course_count}
        #Log String To Console    Kurzusra kattintás: ${course_idx}
        ${course}=    Get From List    ${courses}    ${idx}
        Wait Until Element Is Visible    xpath=/html/body/ulms-root/div/main/div/ulms-courses/mat-tab-nav-panel/ulms-registered-courses/div/section/ulms-course-list/ul/li[${course_idx}]/ulms-course-list-item/mat-card//a    30s
        Sleep    1s
        ${mat_card_content}=    Get WebElement    xpath=/html/body/ulms-root/div/main/div/ulms-courses/mat-tab-nav-panel/ulms-registered-courses/div/section/ulms-course-list/ul/li[${course_idx}]/ulms-course-list-item/mat-card//a
        #most vagyunk az adott téma fő oldalán
       
        Click Element    ${mat_card_content}
        #Execute Javascript    arguments[0].click()    ${mat_card_content}
    
        # Kurzus oldal betöltése után h2 cím kiírása
        Wait Until Element Is Visible    xpath=//h1    20s
        ${h2_text}=    Get Text    xpath=//h1
        Log String To Console With File    Kurzus: ${h2_text} Passed
        Sleep    1s

        # Lecke lista beolvasása
        IKK03-Kurzus-ellenorzo.Lecke lista beolvasása        
       
         Close Browser
         ${course_idx}=   Evaluate    ${course_idx} + 1

    END
    Log String To Console With File    \n\[2/24] Megjelenő kurzusok beolvasása - Kész
   
     
    