*** Settings ***
Library     Collections
Resource    ${CURDIR}/../keywords.robot
Resource    ${CURDIR}/../../PLG-02-Excel-kitolto.robot
*** Keywords ***
Test Case 01 - Arculati Elemek Ellenorzese
    [Documentation]    01 - Arculati elemek ellenőrzése
    #Log To Console    [01/23] Arculati elemek ellenőrzése
    ${testCase_row}=    Set Variable    3
    ${excel_file}=    Get Variable Value    ${CURRENT_EXCEL_FILE}    ${EMPTY}
    ${sheet_name}=    Get Variable Value    ${CURRENT_SHEET_NAME}    ${EMPTY}
    ${path_part}=       Get Variable Value    ${CURRENT_PATH_PART}    ${EMPTY}
    ${filename_part}=   Get Variable Value    ${CURRENT_FILENAME_PART}    ${EMPTY}
  
    ${docx_file}=    Get Variable Value    ${DOCX_FILE}    ${EMPTY}
    ${docx_json}=    Get Variable Value    ${DOCX_JSON}    ${EMPTY}
    # DOCX struktúra beolvasása (biztosan dict-et ad vissza)
    ${docx_json}=    DocxReader.Read Docx All    ${docx_file}
    #mentés globálisba
    Set Global Variable    ${DOCX_JSON}    ${docx_json}   # Teljes JSON mentése globális változóba
    ${err_msg}=    Set Variable    ${EMPTY}
    ${CR}=    Evaluate    chr(13)

    # vedd ki az első docx paragraphs
    ${paragraphs}=    Get From Dictionary    ${docx_json}    paragraphs
    # Bekezdések biztonságos kiolvasása (kevesebb bekezdés esetén se dőljön el)
    #-----------------  első sor Üres ellenőrzése --------------------
    TRY
        ${first_paragraph}=    Get From List    ${paragraphs}    0
        ${first_paragraph}=    Strip String    ${first_paragraph}
        Log To Console    Első sor: ${first_paragraph}
        #legyen is_success false, ha nem üres (csak az első bekezdésre)
        IF    $first_paragraph != ''   
            ${new_err}=    Set Variable    Az első sor kötelezően üres!
            IF    $err_msg == ''
                ${err_msg}=    Set Variable    ${new_err}
            ELSE
                ${err_msg}=    Catenate    SEPARATOR=${CR}    ${err_msg}    ${new_err}
            END
            Log To Console    [ERROR] ${new_err}
        END
    EXCEPT    AS    ${e}
        ${first_paragraph}=    Set Variable    ${EMPTY}
        Log To Console    [INFO] Első sor nem elérhető (${e})
    END
    
    #------------------------------- második sor Egyedi megrendelés azonosítója ellenőrzése --------------------
    TRY
        ${second_paragraph}=    Get From List    ${paragraphs}    1
        ${second_paragraph}=    Strip String    ${second_paragraph}
        Log To Console    Második sor: ${second_paragraph}
        #legyen is_success false, ha a második bekezdés kezdete nem Egyedi megrendelés szöveggel kezdődik (és nem üres)
        IF    $second_paragraph != '' and $second_paragraph[0:30] != 'Egyedi megrendelés azonosítója'
            ${new_err}=    Set Variable    A második sor kezdete kötelezően: Egyedi megrendelés!
            IF    $err_msg == ''
                ${err_msg}=    Set Variable    ${new_err}
            ELSE
                ${err_msg}=    Catenate    SEPARATOR=${CR}    ${err_msg}    ${new_err}
            END
            Log To Console    [ERROR] ${new_err}
        END
    EXCEPT    AS    ${e}
        ${second_paragraph}=    Set Variable    ${EMPTY}
        Log To Console    [INFO] Második sor nem elérhető (${e})
    END
    
    #------------------------------- harmadik sor cím ellenőrzése --------------------
    TRY
        ${third_paragraph}=    Get From List    ${paragraphs}    2
        ${third_paragraph}=    Strip String    ${third_paragraph}
        Log To Console    Harmadik sor: ${third_paragraph}
        # a harmadik bekezdés nem lehet üres
        # Megjegyzés: Robotban ne használj `.length`; helyette használd az üresség ellenőrzést
        IF    $third_paragraph == ''   
            ${new_err}=    Set Variable    A harmadik sor kötelezően nem lehet üres!
            IF    $err_msg == ''
                ${err_msg}=    Set Variable    ${new_err}
            ELSE
                ${err_msg}=    Catenate    SEPARATOR=${CR}    ${err_msg}    ${new_err}
            END
            Log To Console    [ERROR] ${new_err}
        END
    EXCEPT    AS    ${e}
        ${third_paragraph}=    Set Variable    ${EMPTY}
        Log To Console    [INFO] Harmadik bekezdés nem elérhető (${e})
    END
    
    #------------------------------- negyedik sor Témák kézirata ellenőrzése --------------------
    TRY
        ${fourth_paragraph}=    Get From List    ${paragraphs}    3
        ${fourth_paragraph}=    Strip String    ${fourth_paragraph}
        Log To Console    Negyedik sor: ${fourth_paragraph}
        ${fourth_trimmed}=    Strip String    ${fourth_paragraph}
        # Elfogadjuk a "Téma kézirata" és a "Témák kézirata" változatot is
        IF    $fourth_trimmed != 'Téma kézirata' 
            ${new_err}=    Set Variable    A negyedik sor kötelezően: "Téma kézirata" !
            IF    $err_msg == ''
                ${err_msg}=    Set Variable    ${new_err}
            ELSE
                ${err_msg}=    Catenate    SEPARATOR=${CR}    ${err_msg}    ${new_err}
            END
            Log To Console    [ERROR] ${new_err}
        END
    EXCEPT    AS    ${e}
        ${fourth_paragraph}=    Set Variable    ${EMPTY}
        Log To Console    [INFO] Negyedik sor nem elérhető (${e})
    END

    #Kézirat címe
    Fill Excel Cell    ${excel_file}    ${sheet_name}    1    2    ${third_paragraph}
   
    # Teszt státusz és Excel jelölés végrehajtása a megadott soron
    Mark Test Status    ${excel_file}    ${sheet_name}    ${testCase_row}    ${err_msg}


    

  
