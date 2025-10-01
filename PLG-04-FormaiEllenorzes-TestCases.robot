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

Test Case 12 - Magyar Nyelven Keszult Ellenorzese
    [Documentation]    Ellenőrzi a címek formátumát
    [Tags]    formai    cimek
    Test Case 12 - Magyar Nyelven Keszult Ellenorzese

Test Case 13 - Bekezdesek Elkulonulnek Ellenorzese
    [Documentation]    Ellenőrzi az oldalhatárok beállítását
    [Tags]    formai    oldalhatar
    Test Case 13 - Bekezdesek Elkulonulnek Ellenorzese

Test Case 14 - Felsorolasok Egységesek Ellenorzese
    [Documentation]    14 - A felsorolások egységesek
    [Tags]    formai    felsorolasok_egysegesek
    Test Case 14 - Felsorolasok Egységesek Ellenorzese

Test Case 15 - Mozaikszavak Roviditesek Ellenorzese
    [Documentation]    15 - Mozaikszavak rövidítések
    [Tags]    formai    mozaikszavak_roviditesek
    Test Case 15 - Mozaikszavak Roviditesek Ellenorzese

Test Case 16 - Idezetek Formailag Megfeleloek Ellenorzese
    [Documentation]    16 - Idézetek formailag megfelelőek
    [Tags]    formai    idezetek_formailag_megfeleloek
    Test Case 16 - Idezetek Formailag Megfeleloek Ellenorzese

Test Case 17 - Idezetek Forrasmegjelolese Ellenorzese
    [Documentation]    17 - Idézetek forrásmegjelölése
    [Tags]    formai    idezetek_forrasmegjelolese
    Test Case 17 - Idezetek Forrasmegjelolese Ellenorzese

Test Case 18 - Kompetencia Teszt Megoldokulcs Ellenorzese
    [Documentation]    18 - Kompetencia teszt megoldókulcs ellenőrzése
    [Tags]    formai    kompetencia_teszt_megoldokulcs
    Test Case 18 - Kompetencia Teszt Megoldokulcs Ellenorzese

Test Case 19 - Idegen Nyelvu Illusztraciok Ellenorzese
    [Documentation]    19 - Idegen nyelvű illusztrációk
    [Tags]    formai    idegen_nyelvu_illusztraciok
    Test Case 19 - Idegen Nyelvu Illusztraciok Ellenorzese

Test Case 20 - Lapjai Szamozottak Ellenorzese
    [Documentation]    20 - Lapjai számozottak
    [Tags]    formai    lapjai_szamozottak
    Test Case 20 - Lapjai Szamozottak Ellenorzese

Test Case 21 - Szerkesztheto Docx Formatum Ellenorzese
    [Documentation]    21 - Szerkeszthető DOCX formátum
    [Tags]    formai    szerkesztheto_docx_formatum
    Test Case 21 - Szerkesztheto Docx Formatum Ellenorzese

Test Case 22 - Cimlap Tartalom Ellenorzese
    [Documentation]    22 - Címlap tartalom ellenőrzése
    [Tags]    formai    cimlap_tartalom
    Test Case 22 - Cimlap Tartalom Ellenorzese

Test Case 23 - Generalt Tartalomjegyzek Ellenorzese
    [Documentation]    23 - Generált tartalomjegyzék
    [Tags]    formai    generalt_tartalomjegyzek
    Test Case 23 - Generalt Tartalomjegyzek Ellenorzese

Test Case 24 - Cimsorozassal Keszult Ellenorzese
    [Documentation]    24 - Címsorozással készült ellenőrzése
    [Tags]    formai    cimsorozas
    Test Case 24 - Cimsorozassal Keszult Ellenorzese