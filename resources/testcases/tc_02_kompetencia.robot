*** Settings ***
Library     Collections
# RPA.Robocorp.Process eltávolítva – nem használt és hiányzó modul hibát okozott
# RPA.Browser.Selenium eltávolítva – nem szükséges és hiányzó modul hibát okozott
Resource    ${CURDIR}/../keywords.robot
Resource    ${CURDIR}/../../PLG-02-Excel-kitolto.robot
Library     DocxReader
Library     DocxXmlReader



*** Keywords ***
Normalize Text For Title Compare
    [Arguments]    ${text}
    ${t}=    Convert To String    ${text}
        # Normalizálás eltávolítva kérésre, visszaadjuk az eredeti szöveget
    RETURN    ${t}
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

Test Case 02 - Kompetencia Teszt Ellenorzese
    # --- Refaktor: hibák gyűjtése listába ---
    [Documentation]    02 - Kompetencia teszt ellenőrzése
    Log String To Console     \n\[02/24] Kompetencia teszt ellenőrzése 
   ${testCase_row}=    Set Variable    4

    ${excel_file}=    Get Variable Value    ${CURRENT_EXCEL_FILE}    ${EMPTY}
    ${sheet_name}=    Get Variable Value    ${CURRENT_SHEET_NAME}    ${EMPTY}
    ${path_part}=       Get Variable Value    ${CURRENT_PATH_PART}    ${EMPTY}
    ${filename_part}=   Get Variable Value    ${CURRENT_FILENAME_PART}    ${EMPTY}
  
    ${docx_file}=    Get Variable Value    ${DOCX_FILE}    ${EMPTY}
    #${docx_json_komp}=    Get Variable Value    ${docx_json_komp}    ${EMPTY}

    ${errors}=    Create List
    ${err_msg}=    Set Variable    ${EMPTY}
    ${CR}=    Set Variable    ;
    
    ${act_line}=    Set Variable    0
   # docx_file_kompetencia beállítása a docx_file ban csere _tema_kezirata szöveg with kompetencia_tesztek_kezirata            
    ${docx_file_kompetencia}=    Replace String    ${docx_file}    _tema_kezirata    _kompetencia_tesztek_kezirata
    Log String To Console   Read kompetencia file: ${docx_file_kompetencia}

    ${read_status}    ${xmlAllText}=    Run Keyword And Ignore Error    Read Docx All as XML    ${docx_file_kompetencia}
    
    @{xml_lines}=    Split To Lines    ${xmlAllText}
    #kiirja eg xml_line.txt fájlba az xml sorokat
    #${idx}=    Set Variable    0
    #FOR    ${line}    IN    @{xml_lines}
        #Log To Console    ${idx}:${line}
    #    Append To File    xml_line.txt    ${idx}:${line}\n
    #    ${idx}=    Evaluate    ${idx} + 1
    #END

    #Log String To Console    JSON:${docx_json_komp}
    IF    $read_status == 'FAIL'
        ${err_msg}=    Set Variable    Olvasási hiba (${docx_file_kompetencia})    
        Log String To Console     [ERROR] ${err_msg}
         Mark Test Status    ${excel_file}    ${sheet_name}    ${testCase_row}    ${err_msg}
         RETURN
    END
    #Második sor ellenőrzése: Egyedi megrendelés azonosítója
    ${second_paragraph}=    Get From List    ${xml_lines}    0    
    Log String To Console    Második sor(0): ${second_paragraph}
    IF    $second_paragraph == ''
        ${new_err}=    Set Variable    A második sor nem található!
        Append To List    ${errors}    ${new_err}
        Log String To Console     [ERROR] ${new_err}
    ELSE
    
        #összehasonlítás a globálisan elmentett azonosítóval
        ${global_azonosito}=    Get Variable Value    ${EGYEDI_AZONOSITO}    ${EMPTY}
        Log String To Console     [DEBUG]global_azonosito: ${global_azonosito}\n${second_paragraph}
        IF    "${second_paragraph}" != "${global_azonosito}"
            ${new_err}=    Set Variable    Az egyedi megrendelés azonosító nem egyezik a Téma kéziratában megadottal!
            Append To List    ${errors}    ${new_err}
            Log String To Console     [ERROR] ${new_err} 
        END
    END
    
        #------------------------------- harmadik sor cím ellenőrzése --------------------
        #${third_paragraph}    ${act_line}=    Get Next Non Empty Paragraph TC01   ${paragraphs}    ${act_line}
        ${third_paragraph}=    Get From List    ${xml_lines}    1 
        Log String To Console    Harmadik sor(1): ${third_paragraph}
        IF    $third_paragraph == ''
            ${new_err}=    Set Variable    A harmadik sor kötelezően nem lehet üres!
            Append To List    ${errors}    ${new_err}
            Log String To Console     [ERROR] ${new_err}
        END
        #összehasonlítás a globálisan elmentett címmel
        ${global_cim}=    Get Variable Value    ${DOKUMENTUM_CIMSOR}    ${EMPTY}
        #trimmeljük mindkét oldalt
        ${third_paragraph}=    Strip String    ${third_paragraph}
        ${global_cim}=    Strip String    ${global_cim}
        ${n_third}=    Normalize Text For Title Compare    ${third_paragraph}
        ${n_global}=   Normalize Text For Title Compare    ${global_cim}
        #kisbetűsítés
        ${n_third}=    Convert To Lowercase    ${n_third}
        ${n_global}=   Convert To Lowercase    ${n_global}
        
        IF    "${n_third}" != "${n_global}"
            ${new_err}=    Set Variable    A kompetencia címe nem egyezik a Téma kéziratában megadottal! - téma címe: ${n_global} - kompetencia címe: ${n_third}
            Append To List    ${errors}    ${new_err}
            Log String To Console     [ERROR] ${new_err}
            Log String To Console     [TEMA] ${third_paragraph} (norm: ${n_third})
            Log String To Console     [KOMPETENCIA] ${global_cim} (norm: ${n_global})
        END
        #------------------------------- negyedik sor Témák kézirata ellenőrzése --------------------
         
        #${fourth_paragraph}    ${act_line}=    Get Next Non Empty Paragraph TC01   ${paragraphs}    ${act_line}
        ${fourth_paragraph}=    Get From List    ${xml_lines}    2 
        Log String To Console    Negyedik sor(2): ${fourth_paragraph}
        ${normalized_fourth}=    Strip String    ${fourth_paragraph}
        IF    $normalized_fourth != 'Kompetencia tesztek kézirata'
            ${new_err}=    Set Variable    A negyedik sor kötelezően: "Kompetencia tesztek kézirata" ! - Talált szöveg: ${fourth_paragraph}    
            Append To List    ${errors}    ${new_err}
            Log String To Console     [ERROR] ${new_err}
        END

    ${unique_errors}=    Remove Duplicates    ${errors}

    ${err_msg}=    Catenate    SEPARATOR=${CR}    @{unique_errors}
    Mark Test Status    ${excel_file}    ${sheet_name}    ${testCase_row}    ${err_msg}






   