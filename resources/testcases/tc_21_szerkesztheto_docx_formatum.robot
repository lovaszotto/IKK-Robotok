*** Settings ***
Library    ${CURDIR}/../../libraries/DocxPageNumbers.py
Library    ${CURDIR}/../../libraries/DocxEditable.py
Resource   ${CURDIR}/../keywords.robot
Resource   ${CURDIR}/../../PLG-02-Excel-kitolto.robot

*** Keywords ***
Test Case 21 - Szerkesztheto Docx Formatum Ellenorzese
    [Documentation]    21 - Szerkeszthető DOCX formátum. Ellenőrizendő, hogy a kézirat szerkeszthető DOCX formátumban van-e.
    #Formátum: tényleg .docx (nem .doc/.pdf).
    #Szerkezet: DOCX = ZIP + word/document.xml.
    #Védelem: nincs documentProtection a word/settings.xml-ben.
    #Megnyithatóság: a python-docx gond nélkül megnyitja (nem jelszavas/sérült).
    #Írhatóság: a fájl nem “read-only” a fájlrendszeren.

    ${excel_file}=    Get Variable Value    ${CURRENT_EXCEL_FILE}    ${EMPTY}
    ${sheet_name}=    Get Variable Value    ${CURRENT_SHEET_NAME}    ${EMPTY}
    ${docx_file}=    Get Variable Value    ${DOCX_FILE}    ${EMPTY}

    ${question_row}=    Set Variable    23
    ${col_present}=    Set Variable    3
    ${col_missing}=    Set Variable    4

    Log To Console    [21] Ellenőrzött DOCX: ${docx_file}
    # Részletes ellenőrzések
    ${err_msg}=    Verify Editable Docx Test For Current File
  # Teszt státusz és Excel jelölés végrehajtása a megadott soron
    Mark Test Status    ${excel_file}    ${sheet_name}    ${question_row}    ${err_msg}

    #${is_docx}=    Is Docx Extension    ${docx_file}
    #Log To Console    [21] Formátum .docx: ${is_docx}
    #${has_struct}=    Has Valid Docx Structure    ${docx_file}
    #Log To Console    [21] Szerkezet (ZIP+word/document.xml): ${has_struct}
    #${no_protect}=    Has No Document Protection    ${docx_file}
    #Log To Console    [21] Védelem (documentProtection nincs): ${no_protect}
    #${can_open}=    Can Open With PythonDocx    ${docx_file}
    #Log To Console    [21] Megnyithatóság (python-docx): ${can_open}
    #${writable}=    Is Writable File    ${docx_file}
    #Log To Console    [21] Írhatóság (fájlrendszer): ${writable}

    #${editable}=    Is Editable Docx    ${docx_file}
    #Log To Console    [21] Szerkeszthető DOCX (összesített): ${editable}
    #IF    ${editable}
    #    Log To Console    [21] Szerkeszthető DOCX: Megtalálható
    #    Fill Excel Cell    ${excel_file}    ${sheet_name}    ${question_row}    ${col_present}    X
    #    Log To Console    [21] Jelölés: X beírva a C${question_row} cellába
    #ELSE
    #    Log To Console    [21] Szerkeszthető DOCX: NINCS megadva
    #    ${err_msg}=    Verify Editable Docx Test For Current File
    #    Run Keyword If    '${err_msg}' == ''    Set Variable    ${err_msg}    Ismeretlen hiba
    #    Log To Console    [21] Hiba oka: ${err_msg}
    #    Fill Excel Cell    ${excel_file}    ${sheet_name}    ${question_row}    ${col_missing}    X
    #    Log To Console    [21] Jelölés: X beírva a D${question_row} cellába
    #    Run Keyword And Continue On Failure    Fail    [21] Szerkeszthető DOCX: HIBA - ${err_msg} (X a D${question_row})
    #END

Verify Editable Docx Test For Current File
    [Documentation]    Ellenőrzi, hogy a ${DOCX_FILE} szerkeszthető DOCX formátumban készült-e.
    ${docx_file}=    Get Variable Value    ${DOCX_FILE}    ${EMPTY}
    ${err_msg}=    Set Variable    ${EMPTY}
    Run Keyword If    '${docx_file}' == ''    Set Variable    ${err_msg}    Üres DOCX fájlnév változó: ${docx_file}
    ${is_docx}=    Is Docx Extension    ${docx_file}
    ${has_struct}=    Has Valid Docx Structure    ${docx_file}
    ${no_protect}=    Has No Document Protection    ${docx_file}
    ${can_open}=    Can Open With PythonDocx    ${docx_file}
    ${writable}=    Is Writable File    ${docx_file}
    ${is_editable}=    Is Editable Docx    ${docx_file}
    IF    '${err_msg}' == ''
        IF    not ${is_docx}
            ${err_msg}=    Set Variable    Nem .docx kiterjesztés!
        ELSE IF    not ${has_struct}
            ${err_msg}=    Set Variable    Hibás DOCX szerkezet!
        ELSE IF    not ${no_protect}
            ${err_msg}=    Set Variable    Védett dokumentum (settings.xml)!
        ELSE IF    not ${can_open}
            ${err_msg}=    Set Variable    python-docx nem tudja megnyitni!
        ELSE IF    not ${writable}
            ${err_msg}=    Set Variable    Fájl írhatatlan a fájlrendszeren!
        ELSE IF    not ${is_editable}
            ${err_msg}=    Set Variable    A dokumentum nem szerkeszthető DOCX formátum!
        END
    END
    [Return]    ${err_msg}
