*** Settings ***
Library     Collections
Library     String
Resource    ${CURDIR}/../keywords.robot
Resource    ${CURDIR}/../../PLG-02-Excel-kitolto.robot
*** Keywords ***
Test Case 05 - Internet Hivatkozasok Ellenorzese
    [Documentation]    05 - Internet hivatkozások ellenőrzése
    Log To Console     \n\[05/24] Internet hivatkozások ellenőrzése

    ${excel_file}=    Get Variable Value    ${CURRENT_EXCEL_FILE}    ${EMPTY}
    ${sheet_name}=    Get Variable Value    ${CURRENT_SHEET_NAME}    ${EMPTY}
    ${testCase_row}=    Set Variable    7
    ${path_part}=       Get Variable Value    ${CURRENT_PATH_PART}    ${EMPTY}
    ${filename_part}=   Get Variable Value    ${CURRENT_FILENAME_PART}    ${EMPTY}
  
    ${docx_file}=    Get Variable Value    ${DOCX_FILE}    ${EMPTY}
    ${docx_json}=    Get Variable Value    ${DOCX_JSON}    ${EMPTY}
    ${err_msg}=    Set Variable    ${EMPTY}
    ${CR}=    Set Variable    ;
   
    #végignézzük a paragrafusokat, és keresünk benne hivatkozásokat  
    ${paragraphs}=    Get From Dictionary    ${docx_json}    paragraphs
    ${paragraphs_count}=    Get Length    ${paragraphs}
    #Log To Console     \n\[DEBUG] Paragraphs found: ${paragraphs_count}
    FOR    ${paragraph}    IN    @{paragraphs}
        ${paragraph_str}=    Convert To String    ${paragraph}
        # Replace all line breaks and tabs with spaces to join split URLs
        ${paragraph_str}=    Replace String Using Regexp    ${paragraph_str}    [\r\n\t]    ${SPACE}
        ${paragraph_length}=    Get Length    ${paragraph_str}
        IF    ${paragraph_length} == 0
            Continue For Loop
        END
        #URL-ek kikeresése
        ${urls}=    Get Regexp Matches    ${paragraph_str}    https?://(.*)$

        ${url_count}=    Get Length    ${urls}
        IF    ${url_count} == 0
            Continue For Loop
        END
        #dolgozza fel az összes talált url-t (jelenleg csak az elsőt)
         FOR    ${url}    IN    @{urls}
       #ellenőrizze, hogy van e benne (.*\s*dddd.dd.dd.)   
            #${match}=    Evaluate    re.search(r'\\d{4}\\.\\d{1,2}\\.\\d{1,2}', '''${url}''')    modules=re
            ${match}=    Evaluate    re.search(r'\\d{4}\\s*\\.\\s*\\d{1,2}\\s*\\.\\s*\\d{1,2}', '''${url}''')    modules=re
            #Log To Console     \n\[DEBUG] Match found: ${match}
            IF     ${match}
                ${last_open_date}=    Set Variable    ${match.group(0)}
                #Log To Console    MEGVAN : ${last_open_date}
                # ellenőrizze, hogy a dátum nem régebbi mint  2024.06.17 év
                ${is_recent}=     Evaluate    int('''${last_open_date}'''.replace('.','').replace(' ','')) >= 20240617
                IF    not ${is_recent}
                    ${new_err}=    Set Variable    Az utolsó megnyitás dátuma túl régi: ${url}
                    IF    $err_msg == ''
                        ${err_msg}=    Set Variable    ${new_err}
                    ELSE
                        ${err_msg}=    Catenate    SEPARATOR=${CR}    ${err_msg}    ${new_err}
                    END
                    Log To Console     [ERROR] ${new_err}
                END
                    
            ELSE
                ${new_err}=    Set Variable    Nincs utolsó megnyitás dátuma: ${url}
                IF    $err_msg == ''
                    ${err_msg}=    Set Variable    ${new_err}
                ELSE
                    ${err_msg}=    Catenate    SEPARATOR=${CR}    ${err_msg}    ${new_err}
                END
                Log To Console     [ERROR] ${new_err}
        END

         END
       

       #split "Forrás:" alapján
        #${forrasok}=    Split String    ${paragraph}    Forrás:
        #Log To Console   -----------------------  [forrasok] ${forrasok}
        #menjünk végig a kapott listán
        #FOR    ${forras}    IN    @{forrasok}
        #     Log To Console   -----------------------  [Forrás] ${forras}
            #ha a sor tartalmaz http vagy www-t, akkor hiba
           # ${has_http}=    Evaluate    'http' in '''${forras}'''
           # ${has_www}=    Evaluate    'www.' in '''${forras}'''
           # IF    ${has_http} or ${has_www}
           #     Log To Console   -----------------------  [Forrás] ${forras}
           # END
        #END

    END
   
 # Teszt státusz és Excel jelölés végrehajtása a megadott soron
    Mark Test Status    ${excel_file}    ${sheet_name}    ${testCase_row}    ${err_msg}

       
