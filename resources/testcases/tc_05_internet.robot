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

    ${docx_file}=    Get Variable Value    ${DOCX_FILE}    ${EMPTY}
    ${docx_json}=    Get Variable Value    ${DOCX_JSON}    ${EMPTY}
    ${err_msg}=    Set Variable    ${EMPTY}
    ${CR}=    Set Variable    ;
   
           #dolgozza fel az összes talált url-t (jelenleg csak az elsőt)
    ${nincs_utolso_megnyitas_datum}=    Set Variable        ${EMPTY}
    ${tul_regi_utolso_megnyitas_datum}=    Set Variable      ${EMPTY}
    ${was_regi_datum_error}=    Set Variable    ${False}
    ${was_nincs_datum_error}=    Set Variable   ${False}

    #végignézzük a paragrafusokat, és keresünk benne hivatkozásokat  
    ${paragraphs}=    Get From Dictionary    ${docx_json}    paragraphs
    ${paragraphs_count}=    Get Length    ${paragraphs}
      #kiirja a paragrafusok számát , ha nincs hitáb ír
    ${np}=      Evaluate    len(${paragraphs})
    Log String To Console    Összes paragrafus a dokumentum fájlban: ${np}
    IF    ${np} == 0
        ${new_err}=    Set Variable    Nincsenek paragrafusok a kompetencia teszt kéziratában!
            Mark Test Status    ${excel_file}    ${sheet_name}    ${testCase_row}    ${new_err}
        RETURN
    END
    #Log String To Console     \n\[DEBUG] Paragraphs found: ${paragraphs_count}
    FOR    ${i}    IN RANGE    ${paragraphs_count}
          ${paragraph}=    Get From List    ${paragraphs}    ${i}
        ${paragraph_str}=    Convert To String    ${paragraph}
         #Log String To Console    [DEBUG0] Paragraph: ${paragraph_str}
        # a további két sort is ki kell olvasni a  @{paragraphs} listából
        # mert ott vannak a hivatkozások    
        ${next_index}=    Evaluate    ${i} + 1
        #Log String To Console    [DEBUG0] next_index: ${next_index}
        # ir egy ciklust 1..5 hogy a következő 2 sort is hozzá adja
        FOR    ${j}    IN RANGE    1    4

            IF    ${next_index} < ${paragraphs_count}    
                ${next_paragraph}=    Get From List    ${paragraphs}    ${next_index}
                ${next_paragraph_str}=    Convert To String    ${next_paragraph}
                ${paragraph_str}=    Catenate    SEPARATOR=${SPACE}    ${paragraph_str}    ${next_paragraph_str}
            END
                ${next_index}=    Evaluate    ${next_index} + 1
        END       
        
        # Replace all line breaks and tabs with spaces to join split URLs
        ${paragraph_str}=    Replace String Using Regexp    ${paragraph_str}    [\r\n\t]    ${SPACE}
        ${paragraph_length}=    Get Length    ${paragraph_str}
        IF    ${paragraph_length} == 0
            Continue For Loop
        END
        #URL-ek kikeresése
       # ${urls}=    Get Regexp Matches    ${paragraph_str}    https?://(.*)$
       # még 2 sort vissza ad
         ${urls}=    Get Regexp Matches    ${paragraph_str}    https?://(.*)$(?: .*){0,4}     

        ${url_count}=    Get Length    ${urls}
        IF    ${url_count} == 0
            Continue For Loop
        END
        #ha van a címlapon Nem kell ellenőrizni akkor kihagyja
        #${ignore_nosource}=    Get Variable Value    ${IGNORE_NOSOURCE}
        #IF    ${ignore_nosource} == ${True}
        #    Log String To Console    [INFO] IGNORE_NOSOURCE beállítva, kihagyva az ábrák/fotók  ellenőrzését.
              # Teszt státusz és Excel jelölés végrehajtása a megadott soron
        #    Mark Test Status    ${excel_file}    ${sheet_name}    ${testCase_row}    ${EMPTY}
        #    RETURN
        #END
        
         FOR    ${url}    IN    @{urls}
           #ellenőrizze, hogy van e benne (.*\s*dddd.dd.dd.)   
           #irja ki a talált url-t
            #Log String To Console     \n\n[DEBUG] Found URL: ${url}

            #${match}=    Evaluate    re.search(r'\\d{4}\\s*\\.\\s*\\d{1,2}\\s*\\.\\s*\\d{1,2}', '''${url}''')    modules=re
         ${match}=    Evaluate    re.search(r'\\d{4}\\s*[\\.\\-\\s]\\s*\\d{1,2}\\s*[\\.\\-\\s]\\s*\\d{1,2}', '''${url}''')    modules=re
 
    

            #Log String To Console     \n[DEBUG] Match found: ${match}
            IF     ${match}
                ${last_open_date}=    Set Variable    ${match.group(0)}
                #Log String To Console    MEGVAN : ${last_open_date}
                # ellenőrizze, hogy a dátum nem régebbi mint  2024.06.17 év
                ${is_recent}=     Evaluate    int('''${last_open_date}'''.replace('.','').replace(' ','')) >= 20240617
                IF    not ${is_recent}
                     ${was_regi_datum_error}=    Set Variable    ${True}
                     ${tul_regi_utolso_megnyitas_datum}=    Catenate    SEPARATOR=${CR}    ${tul_regi_utolso_megnyitas_datum}    ${url}
                    #Log String To Console    ${tul_regi_utolso_megnyitas_datum}
                END      
            ELSE
                ${was_nincs_datum_error}=    Set Variable    ${True}    
                ${nincs_utolso_megnyitas_datum}=    Catenate    SEPARATOR=${CR}    ${nincs_utolso_megnyitas_datum}    ${url}
                #Log String To Console   ${nincs_utolso_megnyitas_datum}
              
        END

    END


       #split "Forrás:" alapján
        #${forrasok}=    Split String    ${paragraph}    Forrás:
        #Log String To Console   -----------------------  [forrasok] ${forrasok}
        #menjünk végig a kapott listán
        #FOR    ${forras}    IN    @{forrasok}
        #     Log String To Console   -----------------------  [Forrás] ${forras}
            #ha a sor tartalmaz http vagy www-t, akkor hiba
           # ${has_http}=    Evaluate    'http' in '''${forras}'''
           # ${has_www}=    Evaluate    'www.' in '''${forras}'''
           # IF    ${has_http} or ${has_www}
           #     Log String To Console   -----------------------  [Forrás] ${forras}
           # END
        #END

    END
               #ciklus után írja be a hibákat
    IF     ${was_regi_datum_error}
            ${new_err}=    Set Variable       Az utolsó megnyitás dátuma túl régi:${tul_regi_utolso_megnyitas_datum}
            IF    $err_msg == ''
                ${err_msg}=    Set Variable    ${new_err}
            ELSE
                ${err_msg}=    Catenate    SEPARATOR=${CR}    ${err_msg}    ${new_err}
            END
            Log String To Console     [ERROR] ${new_err}
    END
    IF     ${was_nincs_datum_error} 
        ${new_err}=    Set Variable    Nincs utolsó megnyitás dátuma:${nincs_utolso_megnyitas_datum}
            IF    $err_msg == ''
                ${err_msg}=    Set Variable    ${new_err}
            ELSE
                ${err_msg}=    Catenate    SEPARATOR=${CR}    ${err_msg}    ${new_err}
            END
            Log String To Console     [ERROR] ${new_err}
    END   
 # Teszt státusz és Excel jelölés végrehajtása a megadott soron
    Mark Test Status    ${excel_file}    ${sheet_name}    ${testCase_row}    ${err_msg}

       
