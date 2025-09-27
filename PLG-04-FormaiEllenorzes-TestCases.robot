*** Settings ***
Documentation    Formálellenőrzési Test Cases DOCX dokumentumokhoz
Library          BuiltIn
Library          OperatingSystem
Library          String
Library          Collections
Resource         resources/variables.robot
Resource         resources/keywords.robot

*** Variables ***
# These will be passed from command line via --variable  
${CURRENT_DOCX_FILE}    c:/tmp/test/Kézirat.docx
${CURRENT_EXCEL_FILE}    c:/tmp/K_ell_Kézirat.xlsx
${CURRENT_SHEET_NAME}    Kézirat

*** Test Cases ***

Test Case 01 - Arculati Elemek Ellenorzese
    [Documentation]    Ellenőrzi, hogy a dokumentum rendelkezik-e az előírt arculati elemekkel
    [Tags]    formai    arculat
    Test Case 01 - Arculati Elemek Ellenorzese

Test Case 02 - Kompetencia Teszt Ellenorzese  
    [Documentation]    Ellenőrzi, hogy tartalmaz-e kompetencia tesztet/ellenőrző kérdéseket
    [Tags]    formai    kompetencia
    Test Case 02 - Kompetencia Teszt Ellenorzese

Test Case 03 - Fogalomtar Ellenorzese
    [Documentation]    Ellenőrzi, hogy tartozik-e hozzá fogalomtár
    [Tags]    formai    fogalomtar
    Test Case 03 - Fogalomtar Ellenorzese

Test Case 04 - Szerkesztoi Instrukciok Ellenorzese
    [Documentation]    Ellenőrzi, hogy tartalmaz-e szerkesztői instrukciókat
    [Tags]    formai    instrukciok
    Test Case 04 - Szerkesztoi Instrukciok Ellenorzese

Test Case 05 - Internet Hivatkozasok Ellenorzese
    [Documentation]    Ellenőrzi a linkek, webes hivatkozások helyességét
    [Tags]    formai    linkek
    Test Case 05 - Internet Hivatkozasok Ellenorzese

Test Case 06 - Szerzo Lektor Ellenorzese
    [Documentation]    Ellenőrzi a szerző és lektor megjelölését
    [Tags]    formai    szerzo_lektor
    Test Case 06 - Szerzo Lektor Ellenorzese

Test Case 07 - Hosszu Idezetek Ellenorzese
    [Documentation]    Ellenőrzi a hosszú idézetek formázását
    [Tags]    formai    idezetek
    Test Case 07 - Hosszu Idezetek Ellenorzese

Test Case 08 - Tordeles Ellenorzese
    [Documentation]    Ellenőrzi a tördelési szabályok betartását
    [Tags]    formai    tordeles
    Test Case 08 - Tordeles Ellenorzese

Test Case 09 - Abrak Fotok Ellenorzese
    [Documentation]    Ellenőrzi az ábrák és fotók beszúrását/formázását
    [Tags]    formai    abrak
    Test Case 09 - Abrak Fotok Ellenorzese

Test Case 10 - Felsorolas Ellenorzese
    [Documentation]    Ellenőrzi a felsorolások formázását
    [Tags]    formai    felsorolas
    Test Case 10 - Felsorolas Ellenorzese

Test Case 11 - Ures Negyzetek Ellenorzese
    [Documentation]    Ellenőrzi, hogy nincsenek-e üres négyzetek
    [Tags]    formai    negyzetek
    Test Case 11 - Ures Negyzetek Ellenorzese

Test Case 12 - Cimek Formatuma Ellenorzese
    [Documentation]    Ellenőrzi a címek formátumát
    [Tags]    formai    cimek
    Test Case 12 - Cimek Formatuma Ellenorzese

Test Case 13 - Oldalhatar Ellenorzese
    [Documentation]    Ellenőrzi az oldalhatárok beállítását
    [Tags]    formai    oldalhatar
    Test Case 13 - Oldalhatar Ellenorzese

Test Case 14 - Betutipus Ellenorzese
    [Documentation]    Ellenőrzi a betűtípus egységességét
    [Tags]    formai    betutipus
    Test Case 14 - Betutipus Ellenorzese

Test Case 15 - Sorkoze Ellenorzese
    [Documentation]    Ellenőrzi a sorközök beállításait
    [Tags]    formai    sorkoze
    Test Case 15 - Sorkoze Ellenorzese

Test Case 16 - Labjegyzetek Ellenorzese
    [Documentation]    Ellenőrzi a lábjegyzetek formázását
    [Tags]    formai    labjegyzetek
    Test Case 16 - Labjegyzetek Ellenorzese

Test Case 17 - Tartalomjegyzek Ellenorzese
    [Documentation]    Ellenőrzi a tartalomjegyzék meglétét és formáját
    [Tags]    formai    tartalomjegyzek
    Test Case 17 - Tartalomjegyzek Ellenorzese

Test Case 18 - Irodalomjegyzek Ellenorzese
    [Documentation]    Ellenőrzi az irodalomjegyzék meglétét és formáját
    [Tags]    formai    irodalomjegyzek
    Test Case 18 - Irodalomjegyzek Ellenorzese

Test Case 19 - Tablazatok Ellenorzese
    [Documentation]    Ellenőrzi a táblázatok formázását
    [Tags]    formai    tablazatok
    Test Case 19 - Tablazatok Ellenorzese

Test Case 20 - Szoveg Igazitas Ellenorzese
    [Documentation]    Ellenőrzi a szöveg igazításait
    [Tags]    formai    igazitas
    Test Case 20 - Szoveg Igazitas Ellenorzese

Test Case 21 - Oldalszamozas Ellenorzese
    [Documentation]    Ellenőrzi az oldalszámozást
    [Tags]    formai    oldalszamozas
    Test Case 21 - Oldalszamozas Ellenorzese

Test Case 22 - Fejlec Lablec Ellenorzese
    [Documentation]    Ellenőrzi a fejléc és lábléc formázását
    [Tags]    formai    fejlec_lablec
    Test Case 22 - Fejlec Lablec Ellenorzese

Test Case 23 - Helyesiras Ellenorzese
    [Documentation]    Ellenőrzi a helyesírást és nyelvhelyességet
    [Tags]    formai    helyesiras
    Test Case 23 - Helyesiras Ellenorzese