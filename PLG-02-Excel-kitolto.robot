*** Settings ***
Documentation     Excel fájl cellák kitöltése - végleges működő verzió
Library           OperatingSystem
Library           Process
Library           String
Resource          resources/variables.robot

*** Keywords ***
Fill Excel Cell
    [Documentation]    Excel fájl megnyitása, cella kitöltése és mentése
    [Arguments]    ${excel_file_name}    ${sheet_name}    ${row}    ${col}    ${value}
 
   #RETURN
    #Log    === EXCEL CELLA KITÖLTÉS KEZDÉSE ===    console=yes
    #Log    Excel fájl: ${excel_file_name}    console=yes
    #Log    Sheet név: ${sheet_name}    console=yes
    #Log    Sor: ${row}    console=yes
    #Log    Oszlop: ${col}    console=yes
    #Log    Érték: ${value}    console=yes

    #Log    >>>>>> Excel: ${excel_file_name}/${sheet_name}/${row}/${col}:(${value})    console=yes

    # Ellenőrizzük, hogy létezik-e az Excel fájl
    File Should Exist    ${excel_file_name}    msg=Excel fájl nem található: ${excel_file_name}
    ${result}=    Run Process    ${PYTHON_EXEC}    libraries/fill_excel_cell.py    ${excel_file_name}    ${sheet_name}    ${row}    ${col}    ${value}    shell=True
    ${has_stderr}=    Run Keyword And Return Status    Should Not Be Empty    ${result.stderr}
    Run Keyword If    ${has_stderr}    Log    Python script hiba: ${result.stderr}    console=yes
    ${ok_rc}=    Run Keyword And Return Status    Should Be Equal As Integers    ${result.rc}    0
    Run Keyword If    not ${ok_rc}    Log    ${excel_file_name}/${sheet_name}/${row}/${col}/${value} - FIGYELMEZTETÉS: Excel cella kitöltés sikertelen. Visszatérési kód: ${result.rc}    console=yes    level=WARN
    
    #Log    === EXCEL CELLA KITÖLTÉS BEFEJEZVE ===    console=yes

Fill Excel Cell By Letter
    [Documentation]    Excel cella kitöltése betű koordinátákkal (pl. A1, B2) - egyszerűsített verzió
    [Arguments]    ${excel_file_name}    ${sheet_name}    ${cell_ref}    ${value}
    
    Log    === EXCEL CELLA KITÖLTÉS BETŰ KOORDINÁTÁKKAL ===    console=yes
    Log    Excel fájl: ${excel_file_name}    console=yes
    Log    Sheet név: ${sheet_name}    console=yes
    Log    Cella: ${cell_ref}    console=yes
    Log    Érték: ${value}    console=yes
    
    # Ellenőrizzük, hogy létezik-e az Excel fájl
    File Should Exist    ${excel_file_name}    msg=Excel fájl nem található: ${excel_file_name}
    ${result}=    Run Process    ${PYTHON_EXEC}    libraries/fill_excel_cell.py    ${excel_file_name}    ${sheet_name}    ${cell_ref}    ${value}    shell=True

    Log    Python script kimenet:    console=yes
    Log    ${result.stdout}    console=yes

    ${has_stderr}=    Run Keyword And Return Status    Should Not Be Empty    ${result.stderr}
    Run Keyword If    ${has_stderr}    Log    Python script hiba: ${result.stderr}    console=yes
    ${ok_rc}=    Run Keyword And Return Status    Should Be Equal As Integers    ${result.rc}    0
    Run Keyword If    not ${ok_rc}    Log    ${excel_file_name}/${sheet_name}/${cell_ref}/${value} \n- FIGYELMEZTETÉS: Excel cella kitöltés sikertelen. Visszatérési kód: ${result.rc}    console=yes    level=WARN
    
    Log    === EXCEL CELLA KITÖLTÉS BEFEJEZVE ===    console=yes