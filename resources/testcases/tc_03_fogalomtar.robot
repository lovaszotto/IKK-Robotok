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
            ${next_idx}=    Evaluate    ${idx} + 1
            RETURN    ${p}    ${next_idx}
        END
        ${idx}=    Evaluate    ${idx} + 1
    END
    RETURN    ${EMPTY}    ${idx}

*** Keywords ***
Test Case 03 - Fogalomtar Ellenorzese
    [Documentation]    03 - Fogalomtár ellenőrzése
    Log String To Console With File     \n\[03/24] Fogalomtár ellenőrzése 
    ${testCase_row}=    Set Variable    5
     ${excel_file}=    Get Variable Value    ${CURRENT_EXCEL_FILE}    ${EMPTY}
    ${sheet_name}=    Get Variable Value    ${CURRENT_SHEET_NAME}    ${EMPTY}
    ${path_part}=       Get Variable Value    ${CURRENT_PATH_PART}    ${EMPTY}
    ${filename_part}=   Get Variable Value    ${CURRENT_FILENAME_PART}    ${EMPTY}
  
    ${docx_file}=    Get Variable Value    ${DOCX_FILE}    ${EMPTY}
    #${docx_json_fog}=    Get Variable Value    ${docx_json_fog}    ${EMPTY}

    ${errors}=    Create List
    ${err_msg}=    Set Variable    ${EMPTY}
    ${CR}=    Set Variable    ;
    
    ${act_line}=    Set Variable    0
   # docx_file_kompetencia beállítása a docx_file ban csere _tema_kezirata szöveg with kompetencia_tesztek_kezirata            
    ${docx_file_fog}=    Replace String    ${docx_file}    _tema_kezirata    _fogalomtar_kezirata
    # Biztonságos beolvasás (TRY/EXCEPT helyett Robot kulcsszintű hibakezelés)
    #Log String To Console     Fogalomtár kézirata fájl:${docx_file_fog}
    ${read_status}    ${docx_json_fog}=    Run Keyword And Ignore Error    DocxReader.Read Docx All    ${docx_file_fog}
    IF    $read_status == 'FAIL'
        ${err_msg}=    Set Variable    Olvasási hiba (${docx_json_fog})
        Log String To Console With File     [ERROR] ${err_msg}
        Mark Test Status    ${excel_file}    ${sheet_name}    ${testCase_row}    ${err_msg}
         RETURN
    ELSE
        #Log String To Console     Fogalomtár fájl:${docx_file_fog}   >>>BEOLVASVA ${docx_json_fog}
        #Set Global Variable    ${docx_json_fog}    ${docx_json_fog}
        ${paragraphs}=    Get From Dictionary    ${docx_json_fog}    paragraphs
    END
  
        #------------------------------- második sor Egyedi megrendelés azonosítója ellenőrzése --------------------
        ${second_paragraph}    ${act_line}=    Get Next Non Empty Paragraph    ${paragraphs}    ${act_line}
        Log String To Console With File    Második sor: ${second_paragraph}
        IF    $second_paragraph == ''
            ${new_err}=    Set Variable    A második sor nem található!
            Append To List    ${errors}    ${new_err}
            Log String To Console With File     [ERROR] ${new_err}
        ELSE
            # Ha a prefix nem megfelelő
            ${pref_ok}=    Run Keyword And Return Status    Should Start With    ${second_paragraph}    Egyedi megrendelés azonosítója
            IF    '${pref_ok}' == 'False'
                ${new_err}=    Set Variable    A második sor kezdete kötelezően: Egyedi megrendelés azonosítója...
                Append To List    ${errors}    ${new_err}
                Log String To Console With File     [ERROR] ${new_err}
            END
            #összehasonlítás a globálisan elmentett azonosítóval
            ${global_azonosito}=    Get Variable Value    ${EGYEDI_AZONOSITO}    ${EMPTY}
            IF    "${second_paragraph}" != "${global_azonosito}"
                ${new_err}=    Set Variable    Az egyedi megrendelés azonosító nem egyezik a Téma kéziratában megadottal!
                Append To List    ${errors}    ${new_err}
                Log String To Console With File     [ERROR] ${new_err}
    
                Log String To Console With File     [TEMA] ${second_paragraph}
                Log String To Console With File     [FOGALOMTAR] ${global_azonosito}
            END
        END
        
        #------------------------------- harmadik sor cím ellenőrzése --------------------
        ${third_paragraph}    ${act_line}=    Get Next Non Empty Paragraph    ${paragraphs}    ${act_line}
        Log String To Console With File    Harmadik sor: ${third_paragraph}
        Log String To Console With File    Harmadik sor(Orig): ${DOKUMENTUM_CIMSOR}
        IF    $third_paragraph == ''
            ${new_err}=    Set Variable    A harmadik sor kötelezően nem lehet üres!
            Append To List    ${errors}    ${new_err}
            Log String To Console With File     [ERROR] ${new_err}
        END
        #összehasonlítás a globálisan elmentett címmel
        ${global_cim}=    Get Variable Value    ${DOKUMENTUM_CIMSOR}    ${EMPTY}
        #trimmeljük mindkettőt
        ${third_paragraph}=    Strip String    ${third_paragraph}
        ${global_cim}=    Strip String    ${global_cim}
        IF    "${third_paragraph}" != "${global_cim}"    
            ${new_err}=    Set Variable    A cím nem egyezik a Téma kéziratában megadottal!
            Append To List    ${errors}    ${new_err}
            Log String To Console With File     [ERROR] ${new_err}
            Log String To Console With File     [TEMA] ${third_paragraph}
            Log String To Console With File     [FOGALOMTAR] ${global_cim}
        END
        #------------------------------- negyedik sor Témák kézirata ellenőrzése --------------------
        ${fourth_paragraph}    ${act_line}=    Get Next Non Empty Paragraph    ${paragraphs}    ${act_line}
        Log String To Console With File    Negyedik sor: ${fourth_paragraph}
        ${normalized_fourth}=    Strip String    ${fourth_paragraph}
        IF    $normalized_fourth != 'Fogalomtár kézirata'
            ${new_err}=    Set Variable    A negyedik sor kötelezően: "Fogalomtár kézirata" !
            Append To List    ${errors}    ${new_err}
            Log String To Console With File     [ERROR] ${new_err}
        END

    ${unique_errors}=    Remove Duplicates    ${errors}

    ${err_msg}=    Catenate    SEPARATOR=${CR}    @{unique_errors}
    Mark Test Status    ${excel_file}    ${sheet_name}    ${testCase_row}    ${err_msg}





   