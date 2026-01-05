*** Keywords ***
Library    SeleniumLibrary
Handle Popup Dialog
    [Documentation]    Ha megjelenik egy mat-dialog-container, kattint az első benne lévő gombra, ha nincs, továbblép.
    ${is_visible}=    Run Keyword And Return Status    Wait Until Element Is Visible    css=.mat-dialog-container    2s
    IF    ${is_visible}
        # Kattint az első gombra a dialogban
        Click Element    css=.mat-dialog-container button
           Log To Console    [POPUP] mat-dialog-container felugró ablak bezárva.
    ELSE
           Log To Console    [POPUP] Nincs mat-dialog-container felugró ablak.
    END
    # Továbblép, nincs hiba
    RETURN
