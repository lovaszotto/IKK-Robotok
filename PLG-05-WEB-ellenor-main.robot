*** Settings ***
Resource    resources/keywords.robot
Resource    resources/variables.robot
Resource    resources/IKK02-Kurzusaim-bejarasa.robot

Library     String
Library     BuiltIn
Library     Collections
Library     OperatingSystem
Library     Process
Library    libraries/keep_awake.py
Library    SeleniumLibrary 

#Suite Setup    Prevent Sleep
#Suite Teardown    Allow Sleep
#Test Teardown    Update Test Counters

*** Variables ***

*** Keywords ***

Web-alkalmazás indítása és bejelentkezés
    [Documentation]    Web-alkalmazás indítása és bejelentkezés
    
    Log String To Console With File     \n\[1/24] Web-alkalmazás indítása és bejelentkezés - from root
    Open Browser    ${APP_URL}    chrome    
    #Open Browser    ${APP_URL}    edge    
    Maximize Browser Window
    # ${handle}=    Get Window Handles
    # Log String To Console With File    Ablak azonosító: ${HANDLE}
    # Sleep    1s
    Wait Until Element Is Visible    id=email    5s
    Input Text    id=email    ${USERNAME}    
    Input Text    id=PasswordTop    ${PASSWORD}
    Click Button    id=submitBtn


    # Ha megjelenik a kétfaktoros javaslat ablak, kattints a "Később" gombra
    Run Keyword And Ignore Error    Wait Until Element Is Visible    xpath=//button[contains(., 'Később')]    5s
    Run Keyword And Ignore Error    Click Element    xpath=//button[contains(., 'Később')]
    Run Keyword And Ignore Error    Wait Until Element Is Not Visible    xpath=//button[contains(., 'Később')]    5s
 


    # Várd meg, amíg megjelenik a "KURZUSAIM" felirat, majd kattints rá
    Wait Until Element Is Visible    id=header-coursesButton    5s

    Click Element    id=header-coursesButton
    Wait Until Element Is Visible    xpath=//*[contains(text(), 'Aktuális kurzusaim')]    5s
    Log String To Console With File    \n\[1/24] Aktuális kurzusaim oldal megjelenítve
    
    #Téma keresés szűrő beállítása
    Téma keresés szűrő beállítása

    #Megjelenő kurzusok bejárása
    Megjelenő kurzusok bejárása
    Log String To Console With File    \n\[1/24] Web-alkalmazás indítása és bejelentkezés - Kész