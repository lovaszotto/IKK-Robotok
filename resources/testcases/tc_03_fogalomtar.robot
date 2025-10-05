*** Settings ***
Library     Collections
# RPA.Browser.Selenium eltávolítva – nem szükséges és hiányzó modul hibát okozott
Resource    ${CURDIR}/../keywords.robot
Resource    ${CURDIR}/../../PLG-02-Excel-kitolto.robot

*** Keywords ***
Get Next Non Empty Paragraph
    [Arguments]    ${paragraphs}    ${start_index}
    ${total}=    Get Length    ${paragraphs}
    ${idx}=    Set Variable    ${start_index}
    WHILE    ${idx} < ${total}
        ${p}=    Get From List    ${paragraphs}    ${idx}
        ${p}=    Strip String    ${p}
        IF    $p != ''
            RETURN    ${p}    ${idx + 1}
        END
        ${idx}=    Evaluate    ${idx} + 1
    END
    RETURN    ${EMPTY}    ${idx}

*** Keywords ***
Test Case 03 - Fogalomtar Ellenorzese
    [Documentation]    03 - Fogalomtár ellenőrzése
    Log To Console     \n\[03/24] Fogalomtár ellenőrzése 
    ${testCase_row}=    Set Variable    5
     ${excel_file}=    Get Variable Value    ${CURRENT_EXCEL_FILE}    ${EMPTY}
    ${sheet_name}=    Get Variable Value    ${CURRENT_SHEET_NAME}    ${EMPTY}
    ${path_part}=       Get Variable Value    ${CURRENT_PATH_PART}    ${EMPTY}
    ${filename_part}=   Get Variable Value    ${CURRENT_FILENAME_PART}    ${EMPTY}
  
    ${docx_file}=    Get Variable Value    ${DOCX_FILE}    ${EMPTY}
    ${docx_json}=    Get Variable Value    ${DOCX_JSON}    ${EMPTY}

    ${errors}=    Create List
    ${err_msg}=    Set Variable    ${EMPTY}
    ${CR}=    Evaluate    chr(13)
    
    ${act_line}=    Set Variable    0
   # docx_file_kompetencia beállítása a docx_file ban csere _tema_kezirata szöveg with kompetencia_tesztek_kezirata            
    ${docx_file_kompetencia}=    Replace String    ${docx_file}    _tema_kezirata    _fogalomtar_kezirata
    # Biztonságos beolvasás (TRY/EXCEPT helyett Robot kulcsszintű hibakezelés)
    Log To Console     Fogalomtár kézirata fájl:${docx_file_kompetencia}
    ${read_status}    ${docx_json}=    Run Keyword And Ignore Error    DocxReader.Read Docx All    ${docx_file_kompetencia}
    IF    '$read_status' == 'FAIL'
        ${new_err}=    Set Variable    Olvasási hiba (${docx_json})
        Append To List    ${errors}    ${new_err}
        Log To Console     [ERROR] ${new_err}
        ${paragraphs}=    Create List
    ELSE
        Log To Console     Kompetencia fájl:${docx_file_kompetencia}   >>>BEOLVASVA ${docx_json}
        Set Global Variable    ${DOCX_JSON}    ${docx_json}
        ${paragraphs}=    Get From Dictionary    ${docx_json}    paragraphs
    END
  
        #------------------------------- második sor Egyedi megrendelés azonosítója ellenőrzése --------------------
        ${second_paragraph}    ${act_line}=    Get Next Non Empty Paragraph    ${paragraphs}    ${act_line}
        Log To Console    Második sor: ${second_paragraph}
        IF    $second_paragraph == ''
            ${new_err}=    Set Variable    A második sor nem található!
            Append To List    ${errors}    ${new_err}
            Log To Console     [ERROR] ${new_err}
        ELSE
            # Ha a prefix nem megfelelő
            ${pref_ok}=    Run Keyword And Return Status    Should Start With    ${second_paragraph}    Egyedi megrendelés azonosítója
            IF    '${pref_ok}' == 'False'
                ${new_err}=    Set Variable    A második sor kezdete kötelezően: Egyedi megrendelés azonosítója...
                Append To List    ${errors}    ${new_err}
                Log To Console     [ERROR] ${new_err}
            END
            #összehasonlítás a globálisan elmentett azonosítóval
            ${global_azonosito}=    Get Variable Value    ${EGYEDI_AZONOSITO}    ${EMPTY}
            IF    "${second_paragraph}" != "${global_azonosito}"
                ${new_err}=    Set Variable    Az egyedi megrendelés azonosító nem egyezik a Téma kéziratában megadottal!
                Append To List    ${errors}    ${new_err}
                Log To Console     [ERROR] ${new_err}
    
                Log To Console     [TEMA] ${second_paragraph}
                Log To Console     [FOGALOMTAR] ${global_azonosito}
            END
        END
        
        #------------------------------- harmadik sor cím ellenőrzése --------------------
        ${third_paragraph}    ${act_line}=    Get Next Non Empty Paragraph    ${paragraphs}    ${act_line}
        Log To Console    Harmadik sor: ${third_paragraph}
        Log To Console    Harmadik sor(Orig): ${DOKUMENTUM_CIMSOR}
        IF    $third_paragraph == ''
            ${new_err}=    Set Variable    A harmadik sor kötelezően nem lehet üres!
            Append To List    ${errors}    ${new_err}
            Log To Console     [ERROR] ${new_err}
        END
        #összehasonlítás a globálisan elmentett címmel
        ${global_cim}=    Get Variable Value    ${DOKUMENTUM_CIMSOR}    ${EMPTY}
        #trimmeljük mindkettőt
        ${third_paragraph}=    Strip String    ${third_paragraph}
        ${global_cim}=    Strip String    ${global_cim}
        IF    "${third_paragraph}" != "${global_cim}"    
            ${new_err}=    Set Variable    A cím nem egyezik a Téma kéziratában megadottal!
            Append To List    ${errors}    ${new_err}
            Log To Console     [ERROR] ${new_err}
            Log To Console     [TEMA] ${third_paragraph}
            Log To Console     [FOGALOMTAR] ${global_cim}
        END
        #------------------------------- negyedik sor Témák kézirata ellenőrzése --------------------
        ${fourth_paragraph}    ${act_line}=    Get Next Non Empty Paragraph    ${paragraphs}    ${act_line}
        Log To Console    Negyedik sor: ${fourth_paragraph}
        ${normalized_fourth}=    Strip String    ${fourth_paragraph}
        IF    $normalized_fourth != 'Fogalomtár kézirata'
            ${new_err}=    Set Variable    A negyedik sor kötelezően: "Fogalomtár kézirata" !
            Append To List    ${errors}    ${new_err}
            Log To Console     [ERROR] ${new_err}
        END

    ${unique_errors}=    Remove Duplicates    ${errors}

    ${err_msg}=    Catenate    SEPARATOR=${CR}    @{unique_errors}
    Mark Test Status    ${excel_file}    ${sheet_name}    ${testCase_row}    ${err_msg}





   