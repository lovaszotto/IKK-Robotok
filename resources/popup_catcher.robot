*** Settings ***
Library    SeleniumLibrary

*** Keywords ***

Folyamatos Popup Figyelés És Kezelés
    [Documentation]    Folyamatosan figyeli a böngészőt, és ha modal ablak jelenik meg, megnyomja a benne lévő gombot.
    FOR    ${INDEX}    IN RANGE    60
        ${is_visible}=    Run Keyword And Return Status    Wait Until Element Is Visible    //div[contains(@class, 'mat-dialog-container')]//button    1s
        IF    ${is_visible}
            Click Element    //div[contains(@class, 'mat-dialog-container')]//button
        END
        Sleep    1s
    END
    Log    Popup catcher futott egy ciklust.
