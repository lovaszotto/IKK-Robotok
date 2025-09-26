*** Settings ***
Documentation     Teszt suite az Excel kitöltő funktionalitáshoz - végleges verzió
Resource          PLG-02-Excel-kitolto.robot
Library           OperatingSystem
Library           Process

*** Variables ***
${TEST_EXCEL}     ${CURDIR}${/}teszt_excel.xlsx

*** Test Cases ***
Teszt Excel Cella Kitöltés Számokkal
    [Documentation]    Teszt: Excel cella kitöltése sor és oszlop számokkal
    [Tags]    excel    fill_cell
    
    Log    === TESZT: Excel cella kitöltése számokkal ===    console=yes
    
    # Teszt Excel fájl létrehozása, ha nem létezik
    ${exists}=    Run Keyword And Return Status    File Should Exist    ${TEST_EXCEL}
    Run Keyword If    not ${exists}    Create Test Excel File
    
    Fill Excel Cell    ${TEST_EXCEL}    Teszt    2    2    X
        
    Log    Teszt befejezve!    console=yes

Teszt Excel Cella Kitöltés Betűkkel  
    [Documentation]    Teszt: Excel cella kitöltése betű koordinátákkal
    [Tags]    excel    fill_cell_letter
    
    Log    === TESZT: Excel cella kitöltése betűkkel ===    console=yes
    
    # Ellenőrizzük, hogy létezik a teszt fájl
    File Should Exist    ${TEST_EXCEL}
    
    # Használjuk a betű koordinátás verziót
    Fill Excel Cell By Letter    ${TEST_EXCEL}    Teszt    B3    Betű koordinátákkal
    
    Log    Teszt befejezve!    console=yes

Teszt Hibás Sheet Név
    [Documentation]    Teszt: Hibakezelés nem létező sheet névvel
    [Tags]    excel    error_handling
    
    Log    === TESZT: Hibakezelés nem létező sheet-tel ===    console=yes
    
    # Ez a teszt hibát kell hogy dobjon
    Run Keyword And Expect Error    *
    ...    Fill Excel Cell    ${TEST_EXCEL}    NemLetezoSheet    1    1    teszt érték
    
    Log    Hibakezelés teszt sikeres!    console=yes

*** Keywords ***
Create Test Excel File
    [Documentation]    Teszt Excel fájl létrehozása Python scripttel
    Log    Teszt Excel fájl létrehozása...    console=yes
    
    ${result}=    Run Process    python    -c    import openpyxl; wb=openpyxl.Workbook(); ws=wb.active; ws.title='Teszt'; ws['A1']='Eredeti érték'; wb.save('teszt_excel.xlsx'); print('Teszt Excel létrehozva')    shell=True
    
    Log    ${result.stdout}    console=yes
    Should Be Equal As Integers    ${result.rc}    0    msg=Teszt Excel fájl létrehozása sikertelen
    
    Log    Teszt Excel fájl létrehozva: ${TEST_EXCEL}    console=yes