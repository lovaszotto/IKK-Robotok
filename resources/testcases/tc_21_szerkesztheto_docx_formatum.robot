*** Settings ***
Library    ${CURDIR}/../../libraries/DocxPageNumbers.py
Library    ${CURDIR}/../../libraries/DocxEditable.py
Resource   ${CURDIR}/../keywords.robot
Resource   ${CURDIR}/../../PLG-02-Excel-kitolto.robot

*** Keywords ***
Test Case 21 - Szerkesztheto Docx Formatum Ellenorzese
    [Documentation]    21 - Szerkeszthető DOCX formátum. Ellenőrizendő, hogy a kézirat szerkeszthető DOCX formátumban van-e.
    Log String To Console     \n\[21/24] Szerkesztheto Docx Formatum Ellenorzese
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
    ${vedett}=    Set Variable    0
    ${CR}=    Set Variable    ;
    ${err_msg}=    Set Variable     ${EMPTY}
    
    # Részletes ellenőrzések
    #${err_msg}=    Verify Editable Docx Test For Current File
  # Teszt státusz és Excel jelölés végrehajtása a megadott soron
    #Mark Test Status    ${excel_file}    ${sheet_name}    ${question_row}    ${err_msg}

    ${is_docx}=    Is Docx Extension    ${docx_file}
    #Log String To Console     \n\[21] Formátum .docx: ${is_docx}
    IF    ${is_docx} == 'False'
        ${new_err}=    Set Variable    Nem docx formátumú!
        Log String To Console     [ERROR] ${new_err}
    END
    ${has_struct}=    Has Valid Docx Structure    ${docx_file}
    #Log String To Console     \n\[21] Szerkezet (ZIP+word/document.xml): ${has_struct}
    IF    ${has_struct} == 'False'
         ${new_err}=    Set Variable    Hibás szerkezetű!
         IF    $err_msg == ''
            ${err_msg}=    Set Variable    ${new_err}
        ELSE
            ${err_msg}=    Catenate    SEPARATOR=${CR}    ${err_msg}    ${new_err}
        END
    END
    
    ${no_protect}=    Has No Document Protection    ${docx_file}
    #Log String To Console     \n\[21] Védelem (documentProtection nincs): ${no_protect}
    IF    ${no_protect} == 'True'
         ${new_err}=    Set Variable    Védett dokumentum (settings.xml)!
         IF    $err_msg == ''
            ${err_msg}=    Set Variable    ${new_err}
        ELSE
            ${err_msg}=    Catenate    SEPARATOR=${CR}    ${err_msg}    ${new_err}
        END
    END
    

    ${can_open}=    Can Open With PythonDocx    ${docx_file}
    #Log String To Console     \n\[21] Megnyithatóság (python-docx): ${can_open}
    IF    ${can_open} == 'True'
         ${new_err}=    Set Variable    Nem nyitható meg a dokumentum!
         IF    $err_msg == ''
            ${err_msg}=    Set Variable    ${new_err}
        ELSE
            ${err_msg}=    Catenate    SEPARATOR=${CR}    ${err_msg}    ${new_err}
        END
    END
    
    ${writable}=    Is Writable File    ${docx_file}
    #Log String To Console     \n\[21] Írhatóság (fájlrendszer): ${writable}
    IF    ${writable} == 'False'
         ${new_err}=    Set Variable    Nem írható a fájl a fájlrendszeren!
         IF    $err_msg == ''
            ${err_msg}=    Set Variable    ${new_err}
        ELSE
            ${err_msg}=    Catenate    SEPARATOR=${CR}    ${err_msg}    ${new_err}
        END
    END
   #Log String To Console     \n\[21] Összes hibaüzenet: ${err_msg}
    Mark Test Status    ${excel_file}    ${sheet_name}    ${question_row}    ${err_msg}


#Verify Editable Docx Test For Current File
#    [Documentation]    Ellenőrzi, hogy a ${DOCX_FILE} szerkeszthető DOCX formátumban készült-e.
#    ${docx_file}=    Get Variable Value    ${DOCX_FILE}    ${EMPTY}
#    ${err_msg}=    Set Variable    ${EMPTY}
#    Run Keyword If    '${docx_file}' == ''    Set Variable    ${err_msg}    Üres DOCX fájlnév változó: ${docx_file}
#    ${is_docx}=    Is Docx Extension    ${docx_file}
#    ${has_struct}=    Has Valid Docx Structure    ${docx_file}
#    ${no_protect}=    Has No Document Protection    ${docx_file}
#    ${can_open}=    Can Open With PythonDocx    ${docx_file}
#    ${writable}=    Is Writable File    ${docx_file}
#    ${is_editable}=    Is Editable Docx    ${docx_file}
#    IF    '${err_msg}' == ''
#        IF    not ${is_docx}
#            ${err_msg}=    Set Variable    Nem .docx kiterjesztés!
#        ELSE IF    not ${has_struct}
#            ${err_msg}=    Set Variable    Hibás DOCX szerkezet!
#        ELSE IF    not ${no_protect}
#            ${err_msg}=    Set Variable    Védett dokumentum (settings.xml)!
#        ELSE IF    not ${can_open}
#            ${err_msg}=    Set Variable    python-docx nem tudja megnyitni!
#        ELSE IF    not ${writable}
#            ${err_msg}=    Set Variable    Fájl írhatatlan a fájlrendszeren!
#        ELSE IF    not ${is_editable}
#            ${err_msg}=    Set Variable    A dokumentum nem szerkeszthető DOCX formátum!
#        END
#    END
#    RETURN    ${err_msg}
