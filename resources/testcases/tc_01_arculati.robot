*** Settings ***
Library     Collections
Resource    ${CURDIR}/../keywords.robot
Resource    ${CURDIR}/../../PLG-02-Excel-kitolto.robot
*** Keywords ***

# Segéd a nem üres bekezdés következő megtalálására (duplikáció elkerülése, mint TC02-ben)
Get Next Non Empty Paragraph TC01
    [Arguments]    ${paragraphs}    ${start_index}
    ${total}=    Get Length    ${paragraphs}
    ${idx}=    Set Variable    ${start_index}
    WHILE    ${idx} < ${total}
        ${p}=    Get From List    ${paragraphs}    ${idx}
        ${p}=    Strip String    ${p}
        IF    $p != ''
            ${next}=    Evaluate    ${idx} + 1
            RETURN    ${p}    ${next}
        END
        ${idx}=    Evaluate    ${idx} + 1
    END
    RETURN    ${EMPTY}    ${idx}

Test Case 01 - Arculati Elemek Ellenorzese
    [Documentation]    01 - Arculati elemek ellenőrzése
    Log To Console     \n\[01/24] Arculati elemek ellenőrzése
    ${testCase_row}=    Set Variable    3
    ${excel_file}=    Get Variable Value    ${CURRENT_EXCEL_FILE}    ${EMPTY}
    ${sheet_name}=    Get Variable Value    ${CURRENT_SHEET_NAME}    ${EMPTY}
    ${path_part}=       Get Variable Value    ${CURRENT_PATH_PART}    ${EMPTY}
    ${filename_part}=   Get Variable Value    ${CURRENT_FILENAME_PART}    ${EMPTY}
  
    ${docx_file}=    Get Variable Value    ${DOCX_FILE}    ${EMPTY}
    ${docx_json}=    Get Variable Value    ${DOCX_JSON}    ${EMPTY}
    ${CR}=    Set Variable    ;
    ${errors}=    Create List
    ${err_msg}=    Set Variable    ${EMPTY}
    ${act_line}=    Set Variable    0
    # DOCX beolvasás biztonságosan
    ${read_status}    ${docx_json}=    Run Keyword And Ignore Error    DocxReader.Read Docx All    ${docx_file}
    IF    '$read_status' == 'FAIL'
        ${errors}=    Create List    Olvasási hiba a docx fájlban (${docx_json})
        Log To Console     [ERROR] Olvasási hiba a docx fájlban (${docx_json})
        ${paragraphs}=    Create List
    ELSE
        Set Global Variable    ${DOCX_JSON}    ${docx_json}
        ${paragraphs}=    Get From Dictionary    ${docx_json}    paragraphs
    END
    # Stílusok begyűjtése a dokumentumban
    # (a docx modulból a Document osztályt használva, mert a DOCX_JSON nem tartalmazza a stílusokat)

    ${docx_path}=    Get Variable Value    ${DOCX_FILE}    ${EMPTY}
    ${pars}=    Evaluate    [{'idx': i+1, 'text': p.text, 'style': (p.style.name if p.style else 'N/A')} for i,p in enumerate(__import__('docx').Document(r'''${docx_path}''').paragraphs)]
      #style begyűjtése egy uniq listába
     ${styles}=    Create List  

            FOR    ${par}    IN    @{pars}
                ${style}=    Get From Dictionary    ${par}    style
                ${already}=    Run Keyword And Return Status    List Should Contain Value    ${styles}    ${style}
                IF    not ${already}
                        Append To List    ${styles}    ${style}
                END
            END
    Log To Console   §§§§§§§§§§§§§§§§§§§§§§§§§ Stílusok a dokumentumban: ${styles}
    #sTILUSOK FELÍRÁSA EXCELBE
     Set Global Variable    ${STILUSOK}    ${styles}
    Fill Excel Cell    ${excel_file}    ${sheet_name}    27    2    ${styles}

    # 2. sor – Egyedi megrendelés azonosítója
    ${second_paragraph}    ${act_line}=    Get Next Non Empty Paragraph TC01    ${paragraphs}    ${act_line}
    Log To Console    Második sor: ${second_paragraph}
     Set Global Variable    ${EGYEDI_AZONOSITO}    ${second_paragraph}
     Log To Console    EGYEDI AZONOSITO: ${EGYEDI_AZONOSITO}

    IF    $second_paragraph == ''
        Append To List    ${errors}    A második sor nem található!
    ELSE
        ${pref_ok}=    Run Keyword And Return Status    Should Start With    ${second_paragraph}    Egyedi megrendelés azonosítója
        IF    '${pref_ok}' == 'False'
            Append To List    ${errors}    A második sor kezdete kötelezően: Egyedi megrendelés!
        END
    END

    # 3. sor – Cím (nem lehet üres)
    ${third_paragraph}    ${act_line}=    Get Next Non Empty Paragraph TC01    ${paragraphs}    ${act_line}
    Log To Console    Harmadik sor: ${third_paragraph}

    IF    $third_paragraph == ''
        Append To List    ${errors}    A harmadik sor kötelezően nem lehet üres!
    END
   Set Global Variable    ${DOKUMENTUM_CIMSOR}    ${third_paragraph}
   Log To Console    DOKUMENTUM_CIMSOR: ${DOKUMENTUM_CIMSOR}

    # 4. sor – "Téma kézirata" vagy többes változat
    ${fourth_paragraph}    ${act_line}=    Get Next Non Empty Paragraph TC01    ${paragraphs}    ${act_line}
    Log To Console    Negyedik sor: ${fourth_paragraph}
 
    ${fourth_norm}=    Strip String    ${fourth_paragraph}
    ${accepted}=    Create List    Téma kézirata    Témák kézirata
    ${found}=    Run Keyword And Return Status    List Should Contain Value    ${accepted}    ${fourth_norm}
    IF    '${found}' == 'False'
        Append To List    ${errors}    A negyedik sor kötelezően: "Téma kézirata" (vagy megengedett alternatíva)!
    END
 
    # Kézirat címe (ha találtunk harmadik sort)
    IF    $third_paragraph != ''
        Fill Excel Cell    ${excel_file}    ${sheet_name}    1    2    ${third_paragraph}
    END
   
    # Teszt státusz és Excel jelölés végrehajtása a megadott soron
    ${unique}=    Remove Duplicates    ${errors}
    ${err_msg}=    Catenate    SEPARATOR=${CR}    @{unique}
    Mark Test Status    ${excel_file}    ${sheet_name}    ${testCase_row}    ${err_msg}


    

  
