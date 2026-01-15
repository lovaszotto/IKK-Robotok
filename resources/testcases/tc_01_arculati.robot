*** Settings ***
Library     Collections
Library     OperatingSystem
# RPA.JSON eltávolítva – nem használt és hiányzó modul hibát okozott
Resource    ${CURDIR}/../keywords.robot
Resource    ${CURDIR}/../../PLG-02-Excel-kitolto.robot
*** Keywords ***

# Segéd a nem üres bekezdés következő megtalálására (duplikáció elkerülése, mint TC02-ben)
Get Next Non Empty Paragraph TC01
    [Arguments]    ${paragraphs}    ${start_index}
    ${total}=    Get Length    ${paragraphs}
    ${idx}=    Set Variable    ${start_index}
    Log String To Console    \n\nGet Next Non Empty Paragraph TC01 called with start_index=${start_index} in ${total} paragraphs
    WHILE    ${idx} < ${total}
        ${p}=    Get From List    ${paragraphs}    ${idx}

        ${p}=    Strip String    ${p}
        #irja ki a p hosszát is
        ${len_p}=    Get Length    ${p}
        Log String To Console    [DEBUG] Get Next Non Empty Paragraph TC01 idx=${idx} p="${p}" ${len_p}
        IF    ${len_p} > 0
            ${next}=    Evaluate    ${idx} + 1
            RETURN    ${p}    ${next}
        END
        ${idx}=    Evaluate    ${idx} + 1
    END
    RETURN    ${EMPTY}    ${idx}

Test Case 01 - Arculati Elemek Ellenorzese
    [Documentation]    01 - Arculati elemek ellenőrzése
    Log String To Console     \n\[01/24] Arculati elemek ellenőrzése
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
    Log String To Console    docx_file fájl:${docx_file}
    ${read_status}    ${docx_json}=    Run Keyword And Ignore Error    DocxReader.Read Docx All    ${docx_file}
    IF    '$read_status' == 'FAIL'
        ${errors}=    Create List    Olvasási hiba a docx fájlban (${docx_json})
        Log String To Console     [ERROR] Olvasási hiba a docx fájlban (${docx_json})
        ${paragraphs}=    Create List
    ELSE
        Set Global Variable    ${DOCX_JSON}    ${docx_json}
        #Log String To Console     ${docx_json}
        ${paragraphs}=    Get From Dictionary    ${docx_json}    paragraphs
        #kiirja a paragrafusok számát , ha nincs hitáb ír
        ${np}=      Evaluate    len(${paragraphs})
        Log String To Console    Összes paragrafus a dokumentum fájlban: ${np}
        IF    ${np} == 0
            ${new_err}=    Set Variable    Nincsenek paragrafusok a kompetencia teszt kéziratában!
            Mark Test Status    ${excel_file}    ${sheet_name}    ${testCase_row}    ${new_err}
            RETURN
        END
        ${tables}=    Get From Dictionary    ${docx_json}    tables
    END

       # Paragrafusok száma
       ${np}=      Evaluate    len(${paragraphs})
       Log String To Console    Összes paragrafus: ${np}
   

    # paragraph és stílus kiiratása debug
    #Log String To Console    ------------------- PARAGRAFUSOK A DOCX_JSON-BAN ------------------
    ${pars}=    Evaluate    [{'idx': i+1, 'text': p.text, 'style': (p.style.name if p.style else 'N/A')} for i,p in enumerate(__import__('docx').Document(r'''${docx_file}''').paragraphs)]
 
    FOR    ${par}    IN    @{pars}
        ${idx}=    Get From Dictionary    ${par}    idx
        ${text}=    Get From Dictionary    ${par}    text
        ${style}=    Get From Dictionary    ${par}    style
        #Log String To Console    ${idx}: [${style}] "${text}"
    END    
     # Táblák száma
       ${n}=      Evaluate    len(${tables})
       Log String To Console    Összes táblázat: ${n}
    

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
    #Log String To Console   §§§§§§§§§§§§§§§§§§§§§§§§§ Stílusok a dokumentumban: ${styles}
   # Stílusok kiirása Style.txt fájlba append módban
    ${style_file}=    Set Variable    c:\\tmp\\Styles.csv
    # UTF-8 BOM-mal írás: ha a fájl még nem létezik, hozzuk létre BOM-mal, különben csak appendlünk
    ${styles_line}=    Set Variable    ${filename_part},${styles}\n
    ${exists}=    Run Keyword And Return Status    File Should Exist    ${style_file}
    IF    not ${exists}
        # BOM + első sor
        Create File    ${style_file}    \uFEFF${styles_line}    encoding=UTF-8
    ELSE
        Append To File    ${style_file}    ${styles_line}    encoding=UTF-8
    END

    #sTILUSOK FELÍRÁSA EXCELBE
     Set Global Variable    ${STILUSOK}    ${styles}
    #Csabi kérésére most ne írjuk be az Excelbe 
    #Fill Excel Cell    ${excel_file}    ${sheet_name}    27    2    ${styles}

    #XML formában olvassuk be a docx fájlt a szövegek ellenőrzéséhez
     ${read_status}    ${xmlAllText}=    Run Keyword And Ignore Error    Read Docx All as XML    ${docx_path}
    #ellenőrizzük az Eredeti könyv címe vagy külön forrásmegjelölést nem tartalmazó képek és ábrák  szöveget
    #ha szerepel akkor nem kell forrás híbát kiirni
     ${xmlAllText_lower}=    Convert To Lower Case    ${xmlAllText}

    # Ellenőrizze, hogy az xmlAllText tartalmazza-e a szerző/kéziratíró szavak valamelyikét
    ${nosource_keywords}=    Create List    az eredeti könyv címe    külön forrásmegjelölést nem tartalmazó
    Set Global Variable   ${IGNORE_NOSOURCE}    ${False}
    FOR    ${kw}    IN    @{nosource_keywords}
        ${found}=    Run Keyword And Return Status    Should Contain    ${xmlAllText_lower}    ${kw}
        IF    ${found}
            Set Global Variable    ${IGNORE_NOSOURCE}    ${True}
            Log String To Console    [DEBUG] Talált nosource kulcsszó: ${kw}
            Exit For Loop
        END
    END
      Log String To Console   [DEBUG] IGNORE_NOSOURCE: ${IGNORE_NOSOURCE}
   # Ellenőrizze, hogy az xmlAllText tartalmazza-e a Tartalomjegyzék -et
   #irja ki az első 300 karaktert debugként
    #Log String To Console    [DEBUG] XML első 300 karakter: \n${xmlAllText}[0:1600]\n
     
    ${tartalomjegyzek_keywords}=    Create List    tartalomjegyzék
    Set Global Variable    ${FOUND_TARTALOMJEGYZEK}     ${False}    
    FOR    ${kw}    IN    @{tartalomjegyzek_keywords}
        ${found}=    Run Keyword And Return Status    Should Contain    ${xmlAllText_lower}    ${kw}
        IF    ${found}
            Set Global Variable   ${FOUND_TARTALOMJEGYZEK}    ${True}
            Log String To Console    [DEBUG] Talált tartalomjegyzék kulcsszó: ${kw}
            Exit For Loop
        END
    ${found_short}=    Run Keyword And Return Status    Should Contain    ${xmlAllText_lower}[0:1600]    tartalom
        IF    ${found_short}
            Set Global Variable   ${FOUND_TARTALOMJEGYZEK}    ${True}
            Log String To Console    [DEBUG] Talált TARTALOM kulcsszó: TARTALOM
            Exit For Loop
        END
    END        

      Log String To Console   [DEBUG] FOUND_TARTALOMJEGYZEK: ${FOUND_TARTALOMJEGYZEK}
      
    @{xml_lines}=    Split To Lines    ${xmlAllText}
    #kiirja eg xml_line.txt fájlba az xml sorokat
   

    # 2. sor – Egyedi megrendelés azonosítója
    #${second_paragraph}    ${act_line}=    Get Next Non Empty Paragraph TC01    ${paragraphs}    ${act_line}
     ${second_paragraph}=    Get From List    ${xml_lines}    0    
    Log String To Console    Második sor(0): ${second_paragraph}
     Set Global Variable    ${EGYEDI_AZONOSITO}    ${second_paragraph}
     Log String To Console    EGYEDI AZONOSITO: ${EGYEDI_AZONOSITO}

    IF    $second_paragraph == ''
        Append To List    ${errors}    A második sor nem található!
    ELSE
        ${pref_ok}=    Run Keyword And Return Status    Should Start With    ${second_paragraph}    Egyedi megrendelés azonosítója
        IF    '${pref_ok}' == 'False'
            Append To List    ${errors}    A második sor kezdete kötelezően: Egyedi megrendelés!
        END
    END

    # 3. sor – Cím (nem lehet üres)
    #${third_paragraph}    ${act_line}=    Get Next Non Empty Paragraph TC01    ${paragraphs}    ${act_line}
    ${third_paragraph}=    Get From List    ${xml_lines}    1    
    Log String To Console    Harmadik sor(1): ${third_paragraph}

    IF    $third_paragraph == ''
        Append To List    ${errors}    A harmadik sor kötelezően nem lehet üres!
    END
   Set Global Variable    ${DOKUMENTUM_CIMSOR}    ${third_paragraph}
   Log String To Console    DOKUMENTUM_CIMSOR: ${DOKUMENTUM_CIMSOR}

    # 4. sor – "Téma kézirata" vagy többes változat
    #${fourth_paragraph}    ${act_line}=    Get Next Non Empty Paragraph TC01    ${paragraphs}    ${act_line}
    ${fourth_paragraph}=    Get From List    ${xml_lines}    2    
    Log String To Console    Negyedik sor(2): ${fourth_paragraph}
 
    ${fourth_norm}=    Strip String    ${fourth_paragraph}
    ${accepted}=    Create List    Téma kézirata    Téma kézirat    Témák kézirata
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

    #delete variables
    #Delete Variables      ${paragraphs}    ${tables}    ${pars}    ${par}    ${text}  

    

  
