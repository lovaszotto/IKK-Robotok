*** Settings ***
Library     Collections
Resource    ${CURDIR}/../keywords.robot
Resource    ${CURDIR}/../../PLG-02-Excel-kitolto.robot
*** Keywords ***
Test Case 22 - Cimlap Tartalom Ellenorzese
    [Documentation]    22 - Címlap tartalom ellenőrzése
    Log To Console     \n\[22/24] Címlap tartalom ellenőrzése

    ${excel_file}=    Get Variable Value    ${CURRENT_EXCEL_FILE}    ${EMPTY}
    ${sheet_name}=    Get Variable Value    ${CURRENT_SHEET_NAME}    ${EMPTY}
  
   ${testCase_row}=    Set Variable    24
    ${path_part}=       Get Variable Value    ${CURRENT_PATH_PART}    ${EMPTY}
    ${filename_part}=   Get Variable Value    ${CURRENT_FILENAME_PART}    ${EMPTY}
  
    ${docx_file}=    Get Variable Value    ${DOCX_FILE}    ${EMPTY}
    ${docx_json}=    Get Variable Value    ${DOCX_JSON}    ${EMPTY}
    ${err_msg}=    Set Variable    ${EMPTY}
    ${CR}=    Evaluate    chr(13)

    #DOCX_JSON betöltése globaé-ból

    ${docx_json}=    Get Variable Value    ${DOCX_JSON}    ${EMPTY}
    # Ellenőrizd, hogy a docx_json tényleg dictionary, különben hibát jelezz
    ${is_dict}=    Evaluate    isinstance(${docx_json}, dict)
    IF    not ${is_dict}
        ${err_msg}=    Set Variable    DOCX_JSON nem elérhető vagy nem megfelelő típus (${docx_json})
        Log To Console     \n\[ERROR] ${err_msg}
        # Hibás állapotban ne folytassuk a táblázat ellenőrzést
    ELSE
        # vedd ki az első docx tablest, ha van
        # Biztonságos táblázat kinyerés TRY/EXCEPT-tel
        TRY
            ${tables}=    Get From Dictionary    ${docx_json}    tables
        EXCEPT    AS    ${e}
            ${tables}=    Set Variable    ${EMPTY}
            ${err_msg}=    Set Variable    DOCX_JSON['tables'] nem található (${e})
            Log To Console     \n\[ERROR] ${err_msg}
        END
        ${is_tables_list}=    Evaluate    isinstance(${tables}, list)
        IF    not ${is_tables_list}
            ${err_msg}=    Set Variable    DOCX_JSON['tables'] nem lista vagy hiányzik (${tables})
            Log To Console     \n\[ERROR] ${err_msg}
        ELSE
            #-----------------  első sor Üres ellenőrzése --------------------
            TRY
                ${first_table}=    Get From List    ${tables}    0
                #Log To Console    ----------TABLE------------ 
                #Log To Console    ${first_table}
                #Log To Console    ---------------------- 
                  # dict létrehozása és kulcsok/értékek 'tisztítása' Python comprehension-nel
               #${clean} -ben minden # kidobása
                #Log To Console    ------CLEAN------------ 
                #Log To Console    ${first_table}
                #Log To Console    ------------------ 
                # ----------------- Kötelező zábla szövegek ellenőrzése ellenőrzése --------------------
                #a Kéziratíró: szövegnek kötelezően szerepelnie kell a ${clean}-ben
                IF    'Kéziratíró' not in ${first_table}
                    ${new_err}=    Set Variable    A Kéziratíró mező nem létezik a címlapon!
                    IF    $err_msg == ''
                        ${err_msg}=    Set Variable    ${new_err}
                    ELSE
                        ${err_msg}=    Catenate    SEPARATOR=${CR}    ${err_msg}    ${new_err}
                    END
                    Log To Console     \n\[ERROR] ${new_err}
                END
                #a Szakmai lektor: szövegnek kötelezően szerepelnie kell a ${clean}-ben
                IF    'Szakmai lektor' not in ${first_table}
                    ${new_err}=    Set Variable    A Szakmai lektor mező nem létezik a címlapon!
                    IF    $err_msg == ''
                        ${err_msg}=    Set Variable    ${new_err}
                    ELSE
                        ${err_msg}=    Catenate    SEPARATOR=${CR}    ${err_msg}    ${new_err}
                    END
                    Log To Console     \n\[ERROR] ${new_err}
                END
                
                #a Ágazat: szövegnek kötelezően szerepelnie kell a ${clean}-ben
                IF    'Ágazat' not in ${first_table}
                    ${new_err}=    Set Variable    A Ágazat mező nem létezik a címlapon!
                    IF    $err_msg == ''
                        ${err_msg}=    Set Variable    ${new_err}
                    ELSE
                        ${err_msg}=    Catenate    SEPARATOR=${CR}    ${err_msg}    ${new_err}
                    END
                    Log To Console     \n\[ERROR] ${new_err}
                END

                #a Szakma: szövegnek kötelezően szerepelnie kell a ${clean}-ben
                IF    'Szakma' not in ${first_table}
                    ${new_err}=    Set Variable    A Szakma mező nem létezik a címlapon!
                    IF    $err_msg == ''
                        ${err_msg}=    Set Variable    ${new_err}
                    ELSE
                        ${err_msg}=    Catenate    SEPARATOR=${CR}    ${err_msg}    ${new_err}
                    END
                    Log To Console     \n\[ERROR] ${new_err}
                END
                #a Tanulási terület: szövegnek kötelezően szerepelnie kell a ${clean}-ben
                IF    'Tanulási terület' not in ${first_table}
                    ${new_err}=    Set Variable    A Tanulási terület mező nem létezik a címlapon!
                    IF    $err_msg == ''
                        ${err_msg}=    Set Variable    ${new_err}
                    ELSE
                        ${err_msg}=    Catenate    SEPARATOR=${CR}    ${err_msg}    ${new_err}
                    END
                    Log To Console     \n\[ERROR] ${new_err}
                END
                #a Tantárgy: szövegnek kötelezően szerepelnie kell a ${clean}-ben
                IF    'Tantárgy' not in ${first_table}
                    ${new_err}=    Set Variable    A Tantárgy mező nem létezik a címlapon!
                    IF    $err_msg == ''
                        ${err_msg}=    Set Variable    ${new_err}
                    ELSE
                        ${err_msg}=    Catenate    SEPARATOR=${CR}    ${err_msg}    ${new_err}
                    END
                    Log To Console     \n\[ERROR] ${new_err}
                END

                #a Évfolyam: szövegnek kötelezően szerepelnie kell a ${clean}-ben
                IF    'Évfolyam' not in ${first_table}
                    ${new_err}=    Set Variable    A Évfolyam mező nem létezik a címlapon!
                    IF    $err_msg == ''
                        ${err_msg}=    Set Variable    ${new_err}
                    ELSE
                        ${err_msg}=    Catenate    SEPARATOR=${CR}    ${err_msg}    ${new_err}
                    END
                    Log To Console     \n\[ERROR] ${new_err}
                END
                #a Óraszám: szövegnek kötelezően szerepelnie kell a ${clean}-ben
                IF    'Óraszám' not in ${first_table}
                    ${new_err}=    Set Variable    A Óraszám mező nem létezik a címlapon!
                    IF    $err_msg == ''
                        ${err_msg}=    Set Variable    ${new_err}
                    ELSE
                        ${err_msg}=    Catenate    SEPARATOR=${CR}    ${err_msg}    ${new_err}
                    END
                    Log To Console     \n\[ERROR] ${new_err}
                END


                ${clean}=    Evaluate    {k.rstrip(':').strip(): v.strip() for k, v in dict(${first_table}).items()}
                # ----------------- Kéziratíró mező ellenőrzése --------------------
                ${szerzo}=    Get From Dictionary    ${clean}    Kéziratíró
                Log To Console    >>>>>>>>>>>>>>>>>>>>>>>>>>> Szerző: ${szerzo}
                IF    $szerzo == '' or $szerzo == '#'
                    ${new_err}=    Set Variable    A Kéziratíró mező nem létezik, vagy üres!
                    IF    $err_msg == ''
                        ${err_msg}=    Set Variable    ${new_err}
                    ELSE
                        ${err_msg}=    Catenate    SEPARATOR=${CR}    ${err_msg}    ${new_err}
                    END
                    Log To Console     \n\[ERROR] ${new_err}
                END
                # ----------------- Szakmai lektor mező ellenőrzése --------------------
                ${szakmai_lektor}=    Get From Dictionary    ${clean}    Szakmai lektor
                Log To Console    >>>>>>>>>>>>>>>>>>>>>>>>>>> Szakmai lektor: ${szakmai_lektor}
                IF    $szakmai_lektor == '' or $szakmai_lektor == '#'
                    ${new_err}=    Set Variable    A Szakmai lektor mező nem létezik, vagy üres!
                    IF    $err_msg == ''
                        ${err_msg}=    Set Variable    ${new_err}
                    ELSE
                        ${err_msg}=    Catenate    SEPARATOR=${CR}    ${err_msg}    ${new_err}
                    END
                    Log To Console     \n\[ERROR] ${new_err}
                END
                # ----------------- Ágazat mező ellenőrzése --------------------
                ${agazat}=    Get From Dictionary    ${clean}    Ágazat
                Log To Console    >>>>>>>>>>>>>>>>>>>>>>>>>>> Ágazat: ${agazat}
                IF    $agazat == '' or $agazat == '#'
                    ${new_err}=    Set Variable    Az Ágazat mező nem létezik, vagy üres!
                    IF    $err_msg == ''
                        ${err_msg}=    Set Variable    ${new_err}
                    ELSE
                        ${err_msg}=    Catenate    SEPARATOR=${CR}    ${err_msg}    ${new_err}
                    END
                    Log To Console     \n\[ERROR] ${new_err}
                END
                # ----------------- Tanulási terület megnevezése mező ellenőrzése --------------------
                ${tanulasi_terulet}=    Get From Dictionary    ${clean}    Tanulási terület
                Log To Console    >>>>>>>>>>>>>>>>>>>>>>>>>>> Tanulási terület: ${tanulasi_terulet}
                IF    $tanulasi_terulet == '' or $tanulasi_terulet == '#'
                    ${new_err}=    Set Variable    A Tanulási terület mező nem létezik, vagy üres!
                    IF    $err_msg == ''
                        ${err_msg}=    Set Variable    ${new_err}
                    ELSE
                        ${err_msg}=    Catenate    SEPARATOR=${CR}    ${err_msg}    ${new_err}
                    END
                    Log To Console     \n\[ERROR] ${new_err}
                END
               # ----------------- Tantárgy mező ellenőrzése --------------------
                ${tantargy}=    Get From Dictionary    ${clean}    Tantárgy
                Log To Console    >>>>>>>>>>>>>>>>>>>>>>>>>>> Tantárgy: ${tantargy}
                IF    $tantargy == '' or $tantargy == '#'
                    ${new_err}=    Set Variable    A Tantárgy mező nem létezik, vagy üres!
                    IF    $err_msg == ''
                        ${err_msg}=    Set Variable    ${new_err}
                    ELSE
                        ${err_msg}=    Catenate    SEPARATOR=${CR}    ${err_msg}    ${new_err}
                    END
                    Log To Console     \n\[ERROR] ${new_err}
                END
                  # ----------------- Évfolyam mező ellenőrzése --------------------
                ${evfolyam}=    Get From Dictionary    ${clean}    Évfolyam
                Log To Console    >>>>>>>>>>>>>>>>>>>>>>>>>>> Évfolyam: ${evfolyam}
                IF    $evfolyam == '' or $evfolyam == '#'
                    ${new_err}=    Set Variable    A Évfolyam mező nem létezik, vagy üres!
                    IF    $err_msg == ''
                        ${err_msg}=    Set Variable    ${new_err}
                    ELSE
                        ${err_msg}=    Catenate    SEPARATOR=${CR}    ${err_msg}    ${new_err}
                    END
                    Log To Console     \n\[ERROR] ${new_err}
                END
             # ----------------- Óraszám mező ellenőrzése --------------------
                ${oraszam}=    Get From Dictionary    ${clean}    Óraszám
                Log To Console    >>>>>>>>>>>>>>>>>>>>>>>>>>> Óraszám: ${oraszam}
                IF    $oraszam == '' or $oraszam == '#'
                    ${new_err}=    Set Variable    A Óraszám mező nem létezik, vagy üres!
                    IF    $err_msg == ''
                        ${err_msg}=    Set Variable    ${new_err}
                    ELSE
                        ${err_msg}=    Catenate    SEPARATOR=${CR}    ${err_msg}    ${new_err}
                    END
                    Log To Console     \n\[ERROR] ${new_err}
                END
            EXCEPT    AS    ${e}
                ${first_table}=    Set Variable    ${EMPTY}
                Log To Console     \n\[ERROR] A címlap táblázat nem létezik! (${e})
                ${new_err}=    Set Variable    A címlap táblázat hibás!
                IF    $err_msg == ''
                    ${err_msg}=    Set Variable    ${new_err}
                ELSE
                    ${err_msg}=    Catenate    SEPARATOR=${CR}    ${err_msg}    ${new_err}
                END
            END
        END
    END
      # Teszt státusz és Excel jelölés végrehajtása a megadott soron
      Log To Console   ___________________________________ ${err_msg}
    Mark Test Status    ${excel_file}    ${sheet_name}    ${testCase_row}    ${err_msg}
