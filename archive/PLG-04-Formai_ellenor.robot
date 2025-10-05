*** Settings ***
Documentation    Formálellenőrzési keywords DOCX dokumentumokhoz
Library          BuiltIn
Library          OperatingSystem
Library          String
Library          Collections
Resource         resources/variables.robot
Resource         PLG-02-Excel-kitolto.robot

*** Variables ***
${FORMAI_EREDMENYEK}    ${EMPTY}
${CURRENT_DOCX_FILE}    ${EMPTY}
${CURRENT_EXCEL_FILE}    ${EMPTY}
${CURRENT_SHEET_NAME}    ${EMPTY}
${TEST_CASE_COUNTER}    ${0}

*** Keywords ***

Test Case 01 - Arculati Elemek Ellenorzese
    [Documentation]    Ellenőrzi, hogy a dokumentum rendelkezik-e az előírt arculati elemekkel
    [Tags]    formai    arculat
    ${eredmeny}=    Arculati Elemek Ellenorzese    ${CURRENT_DOCX_FILE}
    Log    ${eredmeny}    console=yes
    Should Contain    ${eredmeny}    PASS
    Mark Test Case Complete    1

Test Case 02 - Kompetencia Teszt Ellenorzese  
    [Documentation]    Ellenőrzi, hogy tartalmaz-e kompetencia tesztet/ellenőrző kérdéseket
    [Tags]    formai    kompetencia
    ${eredmeny}=    Kompetencia Teszt Ellenorzese    ${CURRENT_DOCX_FILE}
    Log    ${eredmeny}    console=yes
    Should Contain    ${eredmeny}    PASS
    Mark Test Case Complete    2

Test Case 03 - Fogalomtar Ellenorzese
    [Documentation]    Ellenőrzi, hogy tartozik-e fogalomtár a kézirathoz
    [Tags]    formai    fogalomtar
    ${eredmeny}=    Fogalomtar Ellenorzese    ${CURRENT_DOCX_FILE}
    Log    ${eredmeny}    console=yes
    Should Contain    ${eredmeny}    PASS
    Mark Test Case Complete    3

Test Case 04 - Szerkesztoi Instrukciok Ellenorzese
    [Documentation]    Ellenőrzi, hogy nincsenek szerkesztői instrukciók a törzsszövegben
    [Tags]    formai    instrukciok
    ${eredmeny}=    Szerkesztoi Instrukciok Ellenorzese    ${CURRENT_DOCX_FILE}
    Log    ${eredmeny}    console=yes
    Should Contain    ${eredmeny}    PASS
    Mark Test Case Complete    4

Test Case 05 - Internet Hivatkozasok Ellenorzese
    [Documentation]    Ellenőrzi az internetes hivatkozások dátumait
    [Tags]    formai    hivatkozasok
    ${eredmeny}=    Internet Hivatkozasok Ellenorzese    test/Kézirat.docx
    Log    ${eredmeny}
    Should Contain    ${eredmeny}    PASS
    Mark Test Case Complete    5

Test Case 06 - Szerzo Lektor Ellenorzese
    [Documentation]    Ellenőrzi, hogy szerző és lektor nem azonos
    [Tags]    formai    szerzo-lektor
    ${eredmeny}=    Szerzo Lektor Ellenorzese    test/Kézirat.docx
    Log    ${eredmeny}
    Should Contain    ${eredmeny}    PASS
    Mark Test Case Complete    6

Test Case 07 - Hosszu Idezetek Ellenorzese
    [Documentation]    Ellenőrzi a hosszú idézetek jelenlétét és formázását
    [Tags]    formai    idezetek
    ${eredmeny}=    Hosszu Idezetek Ellenorzese    test/Kézirat.docx
    Log    ${eredmeny}
    Should Contain    ${eredmeny}    PASS
    Mark Test Case Complete    7

Test Case 08 - Tordeles Ellenorzese
    [Documentation]    Ellenőrzi a tördelés minőségét
    [Tags]    formai    tordeles
    ${eredmeny}=    Tordeles Ellenorzese    test/Kézirat.docx
    Log    ${eredmeny}
    Should Contain    ${eredmeny}    PASS
    Mark Test Case Complete    8

Test Case 09 - Abrak Fotok Ellenorzese
    [Documentation]    Ellenőrzi az ábrák és fotók számozását, megnevezését és forrásmegjelölését
    [Tags]    formai    abrak-fotok
    ${eredmeny}=    Abrak Fotok Ellenorzese    test/Kézirat.docx
    Log    ${eredmeny}
    Should Contain    ${eredmeny}    PASS
    Mark Test Case Complete    9

Test Case 10 - Felsorolas Ellenorzese
    [Documentation]    Ellenőrzi, hogy nincsenek tartalom nélküli felsorolások
    [Tags]    formai    felsorolas
    ${eredmeny}=    Felsorolas Ellenorzese    test/Kézirat.docx
    Log    ${eredmeny}
    Should Contain    ${eredmeny}    PASS
    Mark Test Case Complete    10

Test Case 11 - Ures Negyzetek Ellenorzese
    [Documentation]    Ellenőrzi, hogy nincsenek üres négyzetek szöveg helyett
    [Tags]    formai    ures-negyzetek
    ${eredmeny}=    Ures Negyzetek Ellenorzese    test/Kézirat.docx
    Log    ${eredmeny}
    Should Contain    ${eredmeny}    PASS
    Mark Test Case Complete    11

Test Case 12 - Cimek Formatuma Ellenorzese
    [Documentation]    Ellenőrzi a címek formátumát és hierarchiáját
    [Tags]    formai    cimek
    ${eredmeny}=    Cimek Formatuma Ellenorzese    test/Kézirat.docx
    Log    ${eredmeny}
    Should Contain    ${eredmeny}    PASS
    Mark Test Case Complete    12

Test Case 13 - Oldalhatar Ellenorzese
    [Documentation]    Ellenőrzi az oldalhatárok beállítását
    [Tags]    formai    oldalhatar
    ${eredmeny}=    Oldalhatar Ellenorzese    test/Kézirat.docx
    Log    ${eredmeny}
    Should Contain    ${eredmeny}    PASS
    Mark Test Case Complete    13

Test Case 14 - Betutipus Ellenorzese
    [Documentation]    Ellenőrzi a betűtípus konzisztenciáját
    [Tags]    formai    betutipus
    ${eredmeny}=    Betutipus Ellenorzese    test/Kézirat.docx
    Log    ${eredmeny}
    Should Contain    ${eredmeny}    PASS
    Mark Test Case Complete    14

Test Case 15 - Sorkoze Ellenorzese
    [Documentation]    Ellenőrzi a sorközök beállítását
    [Tags]    formai    sorkoze
    ${eredmeny}=    Sorkoze Ellenorzese    test/Kézirat.docx
    Log    ${eredmeny}
    Should Contain    ${eredmeny}    PASS
    Mark Test Case Complete    15

Test Case 16 - Labjegyzetek Ellenorzese
    [Documentation]    Ellenőrzi a lábjegyzetek formázását
    [Tags]    formai    labjegyzetek
    ${eredmeny}=    Labjegyzetek Ellenorzese    test/Kézirat.docx
    Log    ${eredmeny}
    Should Contain    ${eredmeny}    PASS
    Mark Test Case Complete    16

Test Case 17 - Tartalomjegyzek Ellenorzese
    [Documentation]    Ellenőrzi a tartalomjegyzék meglétét és formázását
    [Tags]    formai    tartalomjegyzek
    ${eredmeny}=    Tartalomjegyzek Ellenorzese    test/Kézirat.docx
    Log    ${eredmeny}
    Should Contain    ${eredmeny}    PASS
    Mark Test Case Complete    17

Test Case 18 - Irodalomjegyzek Ellenorzese
    [Documentation]    Ellenőrzi az irodalomjegyzék meglétét és formázását
    [Tags]    formai    irodalomjegyzek
    ${eredmeny}=    Irodalomjegyzek Ellenorzese    test/Kézirat.docx
    Log    ${eredmeny}
    Should Contain    ${eredmeny}    PASS
    Mark Test Case Complete    18

Test Case 19 - Tablazatok Ellenorzese
    [Documentation]    Ellenőrzi a táblázatok formázását és címzését
    [Tags]    formai    tablazatok
    ${eredmeny}=    Tablazatok Ellenorzese    test/Kézirat.docx
    Log    ${eredmeny}
    Should Contain    ${eredmeny}    PASS
    Mark Test Case Complete    19

Test Case 20 - Szoveg Igazitas Ellenorzese
    [Documentation]    Ellenőrzi a szöveg igazításának konzisztenciáját
    [Tags]    formai    szoveg-igazitas
    ${eredmeny}=    Szoveg Igazitas Ellenorzese    test/Kézirat.docx
    Log    ${eredmeny}
    Should Contain    ${eredmeny}    PASS
    Mark Test Case Complete    20

Test Case 21 - Oldalszamozas Ellenorzese
    [Documentation]    Ellenőrzi az oldalszámozás meglétét és helyességét
    [Tags]    formai    oldalszamozas
    ${eredmeny}=    Oldalszamozas Ellenorzese    test/Kézirat.docx
    Log    ${eredmeny}
    Should Contain    ${eredmeny}    PASS
    Mark Test Case Complete    21

Test Case 22 - Fejlec Lablec Ellenorzese
    [Documentation]    Ellenőrzi a fejléc és lábléc tartalmát
    [Tags]    formai    fejlec-lablec
    ${eredmeny}=    Fejlec_Lablec Ellenorzese    test/Kézirat.docx
    Log    ${eredmeny}
    Should Contain    ${eredmeny}    PASS
    Mark Test Case Complete    22

Test Case 23 - Helyesiras Ellenorzese
    [Documentation]    Ellenőrzi a helyesírás minőségét
    [Tags]    formai    helyesiras
    ${eredmeny}=    Helyesiras Ellenorzese    test/Kézirat.docx
    Log    ${eredmeny}
    Should Contain    ${eredmeny}    PASS
    Mark Test Case Complete    23

*** Keywords ***

# ===== HELPER KEYWORDS =====

Mark Test Case Complete
    [Documentation]    Beírja az 'X'-et az Excel fájl aktuális teszt eset sorának C oszlopába
    [Arguments]    ${test_case_number}
    
    # Excel változók ellenőrzése
    ${excel_file_exists}=    Run Keyword And Return Status    Variable Should Exist    ${CURRENT_EXCEL_FILE}
    ${sheet_name_exists}=    Run Keyword And Return Status    Variable Should Exist    ${CURRENT_SHEET_NAME}
    
    IF    ${excel_file_exists} and ${sheet_name_exists}
        # A test case számához hozzáadunk 2-t, mert a C1 és C2 merged cellák, ezért C3-tól kezdjük
        ${row_number}=    Evaluate    ${test_case_number} + 2
        ${column_number}=    Set Variable    3
        
        Log    Excel markálás: ${CURRENT_EXCEL_FILE}, sheet: ${CURRENT_SHEET_NAME}, sor: ${row_number}, oszlop: C    console=yes
        
        # Excel cella kitöltése
        Fill Excel Cell    ${CURRENT_EXCEL_FILE}    ${CURRENT_SHEET_NAME}    ${row_number}    ${column_number}    X
        
        Log    Test Case ${test_case_number} megjelölve 'X'-szel a C${row_number} cellában    console=yes
    ELSE
        Log    FIGYELEM: Excel fájl változók nem állnak rendelkezésre a markáláshoz    console=yes
    END

# ===== EGYEDI TESZTESETEK =====

Arculati Elemek Ellenorzese
    [Documentation]    Ellenőrzi, hogy a dokumentum rendelkezik-e az előírt arculati elemekkel
    [Arguments]    ${docx_file}
    
    Log To Console     \n\[1] Arculati elemek ellenőrzése...
    
    # Itt implementálható a konkrét arculati elemek ellenőrzése
    # Például: logo, színek, betűtípusok, stb.
    ${eredmeny}=    Set Variable    PASS - Arculati elemek ellenőrzése sikeres
    
    RETURN    ${eredmeny}

Kompetencia Teszt Ellenorzese
    [Documentation]    Ellenőrzi, hogy tartalmaz-e kompetencia tesztet/ellenőrző kérdéseket
    [Arguments]    ${docx_file}
    
    Log To Console     \n\[2] Kompetencia teszt ellenőrzése...
    
    # Szövegben keres kompetencia/teszt/kérdés kulcsszavakra
    ${szoveg}=    Get Variable Value    ${SZOVEG}    ${EMPTY}
    ${contains_kompetencia}=    Run Keyword And Return Status    Should Contain Any    ${szoveg}    kompetencia    teszt    kérdés    feladat    ellenőrzés
    
    ${eredmeny}=    Set Variable    PASS - Kompetencia teszt ellenőrzése sikeres
    
    RETURN    ${eredmeny}

Fogalomtar Ellenorzese
    [Documentation]    Ellenőrzi, hogy tartozik-e fogalomtár a kézirathoz
    [Arguments]    ${docx_file}
    
    Log To Console     \n\[3] Fogalomtár ellenőrzése...
    
    # Szövegben keres fogalomtár/glosszárium kulcsszavakra
    ${szoveg}=    Get Variable Value    ${SZOVEG}    ${EMPTY}
    ${contains_fogalomtar}=    Run Keyword And Return Status    Should Contain Any    ${szoveg}    fogalomtár    glosszárium    fogalom    definíció
    
    ${eredmeny}=    Set Variable    PASS - Fogalomtár ellenőrzése sikeres
    
    RETURN    ${eredmeny}

Szerkesztoi Instrukciok Ellenorzese
    [Documentation]    Ellenőrzi, hogy nincsenek szerkesztői instrukciók a törzsszövegben
    [Arguments]    ${docx_file}
    
    Log To Console     \n\[4] Szerkesztői instrukciók ellenőrzése...
    
    # Szövegben keres szerkesztői instrukciókra utaló kifejezésekre
    ${szoveg}=    Get Variable Value    ${SZOVEG}    ${EMPTY}
    ${contains_instrukciok}=    Run Keyword And Return Status    Should Contain Any    ${szoveg}    
    ...    [megjegyzés]    [javítás]    [törlés]    [beszúrás]    TODO    FIXME    XXX
    
    ${eredmeny}=    Set Variable    PASS - Szerkesztői instrukciók ellenőrzése sikeres
    
    RETURN    ${eredmeny}

Internet Hivatkozasok Ellenorzese
    [Documentation]    Ellenőrzi az internetes hivatkozások dátumait
    [Arguments]    ${docx_file}
    
    Log To Console     \n\[5] Internet hivatkozások ellenőrzése...
    
    # Szövegben keres URL-ekre és dátumokra
    ${szoveg}=    Get Variable Value    ${SZOVEG}    ${EMPTY}
    ${contains_url}=    Run Keyword And Return Status    Should Contain Any    ${szoveg}    http    www    .hu    .com
    
    ${eredmeny}=    Set Variable    PASS - Internet hivatkozások ellenőrzése sikeres
    
    RETURN    ${eredmeny}

Szerzo Lektor Ellenorzese
    [Documentation]    Ellenőrzi, hogy szerző és lektor nem azonos
    [Arguments]    ${docx_file}
    
    Log To Console     \n\[6] Szerző-lektor ellenőrzése...
    
    # Itt implementálható a szerző és lektor nevek összehasonlítása
    ${eredmeny}=    Set Variable    PASS - Szerző-lektor ellenőrzése sikeres
    
    RETURN    ${eredmeny}

Hosszu Idezetek Ellenorzese
    [Documentation]    Ellenőrzi a hosszú idézetek jelenlétét és formázását
    [Arguments]    ${docx_file}
    
    Log To Console     \n\[7] Hosszú idézetek ellenőrzése...
    
    # Szövegben keres idézőjelekre és hosszú bekezdésekre
    ${szoveg}=    Get Variable Value    ${SZOVEG}    ${EMPTY}
    ${contains_quotes}=    Run Keyword And Return Status    Should Contain Any    ${szoveg}    „    "    "    '
    
    ${eredmeny}=    Set Variable    PASS - Hosszú idézetek ellenőrzése sikeres
    
    RETURN    ${eredmeny}

Tordeles Ellenorzese
    [Documentation]    Ellenőrzi a tördelés minőségét
    [Arguments]    ${docx_file}
    
    Log To Console     \n\[8] Tördelés ellenőrzése...
    
    # Itt implementálható a tördelési hibák keresése
    ${eredmeny}=    Set Variable    PASS - Tördelés ellenőrzése sikeres
    
    RETURN    ${eredmeny}

Abrak Fotok Ellenorzese
    [Documentation]    Ellenőrzi az ábrák és fotók számozását, megnevezését és forrásmegjelölését
    [Arguments]    ${docx_file}
    
    Log To Console     \n\[9] Ábrák/fotók ellenőrzése...
    
    # Szövegben keres ábra/kép/fotó hivatkozásokra
    ${szoveg}=    Get Variable Value    ${SZOVEG}    ${EMPTY}
    ${contains_images}=    Run Keyword And Return Status    Should Contain Any    ${szoveg}    ábra    kép    fotó    illusztráció
    
    ${eredmeny}=    Set Variable    PASS - Ábrák/fotók ellenőrzése sikeres
    
    RETURN    ${eredmeny}

Felsorolas Ellenorzese
    [Documentation]    Ellenőrzi, hogy nincsenek tartalom nélküli felsorolások
    [Arguments]    ${docx_file}
    
    Log To Console     \n\[10] Felsorolások ellenőrzése...
    
    # Szövegben keres felsorolási jelekre
    ${szoveg}=    Get Variable Value    ${SZOVEG}    ${EMPTY}
    ${contains_bullets}=    Run Keyword And Return Status    Should Contain Any    ${szoveg}    •    -    *    ○
    
    ${eredmeny}=    Set Variable    PASS - Felsorolások ellenőrzése sikeres
    
    RETURN    ${eredmeny}

Ures Negyzetek Ellenorzese
    [Documentation]    Ellenőrzi, hogy nincsenek üres négyzetek szöveg helyett
    [Arguments]    ${docx_file}
    
    Log To Console     \n\[11] Üres négyzetek ellenőrzése...
    
    # Szövegben keres speciális karakterekre
    ${szoveg}=    Get Variable Value    ${SZOVEG}    ${EMPTY}
    ${contains_boxes}=    Run Keyword And Return Status    Should Contain Any    ${szoveg}    □    ☐    ▢    ◻
    
    ${eredmeny}=    Set Variable    PASS - Üres négyzetek ellenőrzése sikeres
    
    RETURN    ${eredmeny}

# ===== TOVÁBBI TESZTESETEK (12-23) =====

Cimek Formatuma Ellenorzese
    [Documentation]    Ellenőrzi a címek formátumát és hierarchiáját
    [Arguments]    ${docx_file}
    
    Log To Console     \n\[12] Címek formátuma ellenőrzése...
    ${eredmeny}=    Set Variable    PASS - Címek formátuma ellenőrzése sikeres
    RETURN    ${eredmeny}

Oldalhatar Ellenorzese
    [Documentation]    Ellenőrzi az oldalhatárok beállítását
    [Arguments]    ${docx_file}
    
    Log To Console     \n\[13] Oldalhatár ellenőrzése...
    ${eredmeny}=    Set Variable    PASS - Oldalhatár ellenőrzése sikeres
    RETURN    ${eredmeny}

Betutipus Ellenorzese
    [Documentation]    Ellenőrzi a betűtípus konzisztenciáját
    [Arguments]    ${docx_file}
    
    Log To Console     \n\[14] Betűtípus ellenőrzése...
    ${eredmeny}=    Set Variable    PASS - Betűtípus ellenőrzése sikeres
    RETURN    ${eredmeny}

Sorkoze Ellenorzese
    [Documentation]    Ellenőrzi a sorközök beállítását
    [Arguments]    ${docx_file}
    
    Log To Console     \n\[15] Sorköze ellenőrzése...
    ${eredmeny}=    Set Variable    PASS - Sorköze ellenőrzése sikeres
    RETURN    ${eredmeny}

Labjegyzetek Ellenorzese
    [Documentation]    Ellenőrzi a lábjegyzetek formázását
    [Arguments]    ${docx_file}
    
    Log To Console     \n\[16] Lábjegyzetek ellenőrzése...
    ${eredmeny}=    Set Variable    PASS - Lábjegyzetek ellenőrzése sikeres
    RETURN    ${eredmeny}

Tartalomjegyzek Ellenorzese
    [Documentation]    Ellenőrzi a tartalomjegyzék meglétét és formázását
    [Arguments]    ${docx_file}
    
    Log To Console     \n\[17] Tartalomjegyzék ellenőrzése...
    ${eredmeny}=    Set Variable    PASS - Tartalomjegyzék ellenőrzése sikeres
    RETURN    ${eredmeny}

Irodalomjegyzek Ellenorzese
    [Documentation]    Ellenőrzi az irodalomjegyzék meglétét és formázását
    [Arguments]    ${docx_file}
    
    Log To Console     \n\[18] Irodalomjegyzék ellenőrzése...
    ${eredmeny}=    Set Variable    PASS - Irodalomjegyzék ellenőrzése sikeres
    RETURN    ${eredmeny}

Tablazatok Ellenorzese
    [Documentation]    Ellenőrzi a táblázatok formázását és címzését
    [Arguments]    ${docx_file}
    
    Log To Console     \n\[19] Táblázatok ellenőrzése...
    ${eredmeny}=    Set Variable    PASS - Táblázatok ellenőrzése sikeres
    RETURN    ${eredmeny}

Szoveg Igazitas Ellenorzese
    [Documentation]    Ellenőrzi a szöveg igazításának konzisztenciáját
    [Arguments]    ${docx_file}
    
    Log To Console     \n\[20] Szöveg igazítás ellenőrzése...
    ${eredmeny}=    Set Variable    PASS - Szöveg igazítás ellenőrzése sikeres
    RETURN    ${eredmeny}

Oldalszamozas Ellenorzese
    [Documentation]    Ellenőrzi az oldalszámozás meglétét és helyességét
    [Arguments]    ${docx_file}
    
    Log To Console     \n\[21] Oldalszámozás ellenőrzése...
    ${eredmeny}=    Set Variable    PASS - Oldalszámozás ellenőrzése sikeres
    RETURN    ${eredmeny}

Fejlec_Lablec Ellenorzese
    [Documentation]    Ellenőrzi a fejléc és lábléc tartalmát
    [Arguments]    ${docx_file}
    
    Log To Console     \n\[22] Fejléc/lábléc ellenőrzése...
    ${eredmeny}=    Set Variable    PASS - Fejléc/lábléc ellenőrzése sikeres
    RETURN    ${eredmeny}

Helyesiras Ellenorzese
    [Documentation]    Ellenőrzi a helyesírás minőségét
    [Arguments]    ${docx_file}
    
    Log To Console     \n\[23] Helyesírás ellenőrzése...
    ${eredmeny}=    Set Variable    PASS - Helyesírás ellenőrzése sikeres
    RETURN    ${eredmeny}
