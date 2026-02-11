*** Settings ***
Library     Collections
Library     String
Resource    ${CURDIR}/../keywords.robot
Resource    ${CURDIR}/../../PLG-02-Excel-kitolto.robot
*** Keywords ***
Test Case 05 - Internet Hivatkozasok Ellenorzese
    [Documentation]    05 - Internet hivatkozások ellenőrzése
    Log String To Console     \n\[05/24] Internet hivatkozások ellenőrzése

    ${excel_file}=    Get Variable Value    ${CURRENT_EXCEL_FILE}    ${EMPTY}
    ${sheet_name}=    Get Variable Value    ${CURRENT_SHEET_NAME}    ${EMPTY}
    ${testCase_row}=    Set Variable    7
    ${path_part}=       Get Variable Value    ${CURRENT_PATH_PART}    ${EMPTY}
    ${filename_part}=   Get Variable Value    ${CURRENT_FILENAME_PART}    ${EMPTY}
    ${errors}=    Create List
    ${errors_regi_datum}=    Create List
    Append To List    ${errors_regi_datum}    Az utolsó megnyitás dátuma túl régi
    
    ${errors_nincs_datum}=    Create List
    Append To List    ${errors_nincs_datum}    Nincs utolsó megnyitás dátuma

    ${docx_file}=    Get Variable Value    ${DOCX_FILE}    ${EMPTY}
    ${docx_json}=    Get Variable Value    ${DOCX_JSON}    ${EMPTY}
    ${err_msg}=    Set Variable    ${EMPTY}
    ${CR}=    Set Variable    ;
   
           #dolgozza fel az összes talált url-t (jelenleg csak az elsőt)
    ${nincs_utolso_megnyitas_datum}=    Set Variable        ${EMPTY}
    ${tul_regi_utolso_megnyitas_datum}=    Set Variable      ${EMPTY}
    ${was_regi_datum_error}=    Set Variable    ${False}
    ${was_nincs_datum_error}=    Set Variable   ${False}

    #XML alapú beolvasás
    ${read_status}    ${xmlAllText}=    Run Keyword And Ignore Error    Read Docx All as XML    ${docx_file}
    IF    $read_status == 'FAIL'
        ${err_msg}=    Set Variable    Olvasási hiba (${docx_file})    
        Log String To Console     [ERROR] ${err_msg}
         Mark Test Status    ${excel_file}    ${sheet_name}    ${testCase_row}    ${err_msg}
         RETURN
    END
    ${xmlAllText}=    Replace String    ${xmlAllText}    \n    ''



    ${paragraph_str}=    Set Variable    ${xmlAllText}
    
    # Replace all line breaks and tabs with spaces to join split URLs
    ${paragraph_str}=    Replace String Using Regexp    ${paragraph_str}    [\r\n\t]    ${SPACE}
    ${paragraph_length}=    Get Length    ${paragraph_str}
    IF    ${paragraph_length} == 0
        Continue For Loop
    END
    #URL-ek kikeresése

    ${urls}=    Split String    ${paragraph_str}   https://

    ${url_count}=    Get Length    ${urls}
    Log String To Console    [DEBUG] https found: ${url_count}
    IF    ${url_count} == 0
        Continue For Loop
    END
    #ha van a címlapon Nem kell ellenőrizni akkor kihagyja
    ${ignore_nosource}=    Get Variable Value    ${IGNORE_NOSOURCE}
    IF    ${ignore_nosource} == ${True}
        Log String To Console    [INFO] IGNORE_NOSOURCE beállítva, kihagyva az ábrák/fotók  ellenőrzését.
            # Teszt státusz és Excel jelölés végrehajtása a megadott soron
        Mark Test Status    ${excel_file}    ${sheet_name}    ${testCase_row}    ${EMPTY}
        RETURN
    END
    
    ${split_index}=    Set Variable    -1
     Log String To Console     \n[DEBUG] Summa URL #${split_index}
     FOR    ${url}    IN    @{urls}
        #ellenőrizze, hogy van e benne (.*\s*dddd.dd.dd.)   
        #irja ki a talált url-t
        ${split_index}=    Evaluate    ${split_index} + 1
        Log String To Console     \n[DEBUG] Processing URL #${split_index}
        #ha a split_index 0, akkor az első elem lesz, ami nem tartalmazza a https:// részt, ezért azt kihagyjuk
        IF     ${split_index} == 0
            CONTINUE
        END
        #Log String To Console     \n\n[DEBUG] Found URL: ${url}
        #${match}=    Evaluate    re.search(r'\\d{4}\\s*\\.\\s*\\d{1,2}\\s*\\.\\s*\\d{1,2}', '''${url}''')    modules=re
        ${match}=    Evaluate    re.search(r'\\d{4}\\s*[\\.\\-\\s]\\s*\\d{1,2}\\s*[\\.\\-\\s]\\s*\\d{1,2}', '''${url}''')    modules=re

        Log String To Console     \n[DEBUG] Match found: ${match}
        IF     ${match}
            ${last_open_date}=    Set Variable    ${match.group(0)}
            Log String To Console    MEGVAN : ${last_open_date}
            # ellenőrizze, hogy a dátum nem régebbi mint  2024.06.17 év
            ${is_recent}=     Evaluate    int('''${last_open_date}'''.replace('.','').replace(' ','')) >= 20240617
            IF    not ${is_recent}
                    ${was_regi_datum_error}=    Set Variable    ${True}
                    # ${url_first}=    Split String    ${url}    ${SPACE}     max_split=1
                    Append To List           ${errors_regi_datum}   ${last_open_date}
                  #  ${tul_regi_utolso_megnyitas_datum}=    Catenate    SEPARATOR=${CR}    ${tul_regi_utolso_megnyitas_datum}    ${url}
                    Log String To Console  TÚL RÉGI:\n  ${last_open_date}
            END      
        ELSE
            ${was_nincs_datum_error}=    Set Variable    ${True}    
            #Log String To Console    Eredeti:${url[0:100]}
            #az első szóközig levágása a url-ből, mert az első elemben marad a https:// előtti rész, ami nem kell
            ${url_first}=    Split String    ${url}    ${SPACE}     max_split=1
            Log String To Console    Levágott:${url_first[0]}
            #${nincs_utolso_megnyitas_datum}=    Catenate    SEPARATOR=${CR}    ${nincs_utolso_megnyitas_datum}    ${url_first[0]}
            Append To List    ${errors_nincs_datum}    ${url_first[0]}
        END
        Log String To Console    <<< URL #${split_index} feldolgozva.  
    END
    Log String To Console     \n[DEBUG] URL feldolgozás vége. Regi datum error: ${was_regi_datum_error}
    Log String To Console     \n[DEBUG] URL feldolgozás vége. Nincs datum error: ${was_nincs_datum_error}

   IF     ${was_regi_datum_error}
            ${unique}=    Remove Duplicates    ${errors_regi_datum}
            ${err_msg}=    Catenate    SEPARATOR=${CR}    @{unique}
    END
    IF     ${was_nincs_datum_error}
        ${unique}=    Remove Duplicates    ${errors_nincs_datum}
        #füzze össze az err_msg-ben az eredeti tartalmat és az unique listát
        ${err_msg}=    Catenate    SEPARATOR=${CR}   ${err_msg}  @{unique}
    END

      Log String To Console  \n\nEredmény visszaírása Excelbe...\n\n
               #ciklus után írja be a hibákat
 
 # Teszt státusz és Excel jelölés végrehajtása a megadott soron
    #${unique}=    Remove Duplicates    ${err_msg}

    #${err_msg}=    Catenate    SEPARATOR=${CR}    @{unique}
   Log String To Console     [ERROR-felírás] ${err_msg}
    Mark Test Status    ${excel_file}    ${sheet_name}    ${testCase_row}    ${err_msg}

       
