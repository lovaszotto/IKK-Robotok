*** Settings ***
Library    SeleniumLibrary
Resource   ../resources/popup_handler.robot
Resource   ../resources/variables.robot

*** Test Cases ***
Popup Handler Chrome Indítás
    [Documentation]    Megnyitja a https://account.nexiuslearning.com/login oldalt, majd popupot kezel.
    Open Browser    https://account.nexiuslearning.com/login    chrome
    Sleep    3s
    Input Text    css=input[type="email"]    ${USERNAME}
    Input Text    css=input[type="password"]    ${PASSWORD}
    Click Button    css=button[type="submit"]
    Sleep    5s
    Handle Popup Dialog
