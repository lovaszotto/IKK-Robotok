*** Settings ***
Library    SeleniumLibrary 
Library    RequestsLibrary
Library    Collections
Library    OperatingSystem

Resource   ${CURDIR}/../keywords.robot
Resource   ${CURDIR}/../../PLG-02-Excel-kitolto.robot

*** Variables ***
${BASE}     https://nexiuscontent.blob.core.windows.net
${PATHQ}    /947aa28d-3fa0-3b1b-67b9-41f55739d3ab/content/assets/BE/69/F17H8B924HD357E8CCH0B54EC8HF?sv=2018-03-28&sr=c&sig=VidbK4nblBzfJ10g5FAJ%2B%2BaPIsB%2FVkCp77knLeu9yW8%3D&st=2025-10-27T09%3A52%3A45Z&se=2025-10-27T16%3A22%3A45Z&sp=r
${SESSION}  blob
${OUT_BASENAME}    image
${DEFAULT_BASENAME}    media


*** Keywords ***
Témák közötti navigáció ellenőrzése
    [Documentation]    Témák közötti navigáció ellenőrzése
     Log String To Console    \n**************************************************************************
    Log String To Console    * wtc_03- Témák közötti navigáció ellenőrzése
    Log String To Console    **************************************************************************\n
    ${testCase_row}=    Set Variable    5
  
   ${err_msg}=    Set Variable    ${EMPTY}
   ${errors}=    Create List
    ${CR}=    Set Variable    ;
     ${next_button}=    Set Variable    ${EMPTY}
    ${is_disabled}=    Set Variable    None
     ${leckek_szama}=    Set Variable    0

    #felugró teszt megszakítása gomb kezelése
    Log String To Console    \nTeszt megszakítás popup kezelés
    Run Keyword And Ignore Error    Wait Until Element Is Visible    xpath=//button[contains(., 'Teszt megszakítása')]    1s
    Run Keyword And Ignore Error    Click Element    xpath=//button[contains(., 'Teszt megszakítása')]
    Run Keyword And Ignore Error    Wait Until Element Is Not Visible    xpath=//button[contains(., 'Teszt megszakítása')]    1s

    #Ha nem futtatunk média ellenőrzést, kilépünk
    IF    $RUN_MEDIA_CHECK == $False
        RETURN
    END

    ${rc}    ${msg}=    Run Keyword And Ignore Error     Wait Until Page Contains Element    xpath=//button[contains(@aria-label,'Következő oldalra lépés')]   10s    
    Log String To Console    \nVárakozás eredménye: ${rc} ${msg}
     # ${szoveg_nodes}=    Get WebElements    xpath=//div[contains(normalize-space(.), 'Oldal')]/preceding-sibling::div[1]
    IF    '${rc}' == 'PASS'
        TRY 
           WHILE    ${is_disabled} is ${NONE}
                Log String To Console    Következő oldal gomb engedélyezett, lépés a következő oldalra.
                TRY 
                    #${next_button}=    Get WebElement    xpath=//button[contains(@aria-label,'Következő oldalra lépés')]
                    #felugró teszt megszakítása gomb kezelése
                    Run Keyword And Ignore Error    Wait Until Element Is Visible    xpath=//button[contains(., 'Teszt megszakítása')]    0.1s
                    Run Keyword And Ignore Error    Click Button    xpath=//button[contains(., 'Teszt megszakítása')]
                    Run Keyword And Ignore Error    Wait Until Element Is Not Visible    xpath=//button[contains(., 'Teszt megszakítása')]    0.1s
            
                    #Wait Until Page Does Not Contain Element    css=.cdk-overlay-backdrop    5s
                    #Wait Until Element Is Visible   xpath=//button[contains(@aria-label,'Következő oldalra lépés')]    1s
                    ${next_button}=    Set Variable    xpath=//button[contains(@aria-label,'Következő oldalra lépés')]
                    #Click Element      ${next_button}
                    Click Element     xpath=//button[contains(@aria-label,'Következő oldalra lépés')]
                    Log String To Console    Következő oldal gombra kattintva.
                    Wait Until Element Is Visible    xpath=//app-image-field[contains(@style, 'display: flex')]//img    10s
                  
                     #${szoveg_nodes}=    Get WebElements    xpath=//div[contains(normalize-space(.), 'Oldal')]/preceding-sibling::div[1]

                    #${node}=    Get From List    ${szoveg_nodes}    ${img_index}
                    #${node_text}=    Get Text    ${node}
                    #Log String To Console    >>>Oldalcím: ${node_text}
                    
                    Wait Until Element Is Visible    xpath=//app-container-field/app-formatted-text-field[1]   1s
                    Log String To Console    Oldalcím elemek láthatóak, váraskozás OK
                    #${title1}=    Get WebElement    xpath=//app-container-field/app-formatted-text-field[1]
                    #${title1_text}=    Get Text    ${title1}

                    #${title2}=    Get WebElement    xpath=//app-container-field/app-formatted-text-field[2]
                    #${title2_text}=    Get Text    ${title2}
                    #Log String To Console    >>>Oldalcím 1: ${title1_text}
                    #Log String To Console    >>>Oldalcím 2: ${title2_text}
              
              #Képek ellenőrzése
                    #Wait For Elements State    //app-image-field//img    visible=True    timeout=10s
                    ${images}=    Get WebElements    //app-image-field[contains(@style, 'display: flex')]//img
                    ${image_count}=    Get Length    ${images}
                    ${img_index}=    Set Variable    0
                  Log String To Console    \n\n>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>Talált képek száma: ${image_count}
                
      
                    #Képek feldolgozása
                    Set Variable    ${img_index}    0
                    FOR    ${img_index}    IN RANGE   ${image_count}    
                        TRY
                      
                        Log String To Console    \nKövetkező Kép: ${img_index}
                    
                            ${img}=    Get WebElement   (//app-image-field[contains(@style, 'display: flex')])[${img_index+1}]//img
                            ${exists}=    Run Keyword And Return Status    Page Should Contain Element    ${img}
                            #Run Keyword If    ${exists}    Log String To Console    "Megvan!"    ELSE    Log String To Console    "Nincs ilyen elem"
                            IF    ${exists} == False
                                Log String To Console    Nincs ilyen elem, kihagyás
                                Continue For Loop
                            END
                            #${visible}=   Run Keyword And Ignore Error    Wait Until Element Is Visible   ${img}   1s
                            #${img}=    Get From List    ${images}    ${img_index}
                            ${visible}=     Run Keyword And Return Status    Element Should Be Visible    ${img}
                            IF    ${visible} == False
                                Log String To Console    A kép nem látható, kihagyás
                                Continue For Loop
                            END
                            Log String To Console    ${img_index}:Következő Kép: ${img_index}

                            #${alt}=    Get Element Attribute    ${img}    alt
                           
                            ${alt}=    Get Element Attribute    (//app-image-field[contains(@style, 'display: flex')])[${img_index+1}]//img   alt
                            Log String To Console    ${img_index}:nKép alt: ${alt}
                            
                          #Menü sor lekérése
                            Wait Until Element Is Visible    xpath=//div[contains(@class,'highlighted-node')]    10s
                            ${highlighted_name}   ${level1_name}   ${level2_name}    ${level3_name}=   Get Highlighted And Parent Titles By Text
                            
                            #${highlighted_name}   ${level1_name}   ${level2_name}    ${level3_name} =    Get Highlighted And Parent Titles (Levels 1-3)

                            #Fill Excel Cell    ${DIGITALIS_EXCEL_FILE}     ${DIGITALIS_EXCEL_SHEET_MK}     ${MEDIA_ROW_INDEX}    3    ${level1_name}/${level2_name}/${level3_name}
                            IF    $level3_name == $highlighted_name
                                 Fill Excel Cell    ${DIGITALIS_EXCEL_FILE}     ${DIGITALIS_EXCEL_SHEET_MK}     ${MEDIA_ROW_INDEX}    3    ${level2_name}
                            ELSE
                                 Fill Excel Cell    ${DIGITALIS_EXCEL_FILE}     ${DIGITALIS_EXCEL_SHEET_MK}     ${MEDIA_ROW_INDEX}    3    ${level2_name}/${level3_name}
                            END
                            
                            Fill Excel Cell    ${DIGITALIS_EXCEL_FILE}     ${DIGITALIS_EXCEL_SHEET_MK}     ${MEDIA_ROW_INDEX}    4    ${highlighted_name}

                            #Alt felírása media katalógusba
                            Fill Excel Cell    ${DIGITALIS_EXCEL_FILE}     ${DIGITALIS_EXCEL_SHEET_MK}     ${MEDIA_ROW_INDEX}    5    ${alt}
                        
                            #${src}=    Get Element Attribute    ${img}    src
                            ${src}=    Get Element Attribute   (//app-image-field[contains(@style, 'display: flex')])[${img_index+1}]//img    src
                            # Log String To Console    Kép forrás: ${src}
                            # Az ${src}-ben lecseréljük a ${BASE} rész üresre
                            # így csak a PATHQ marad meg
                            ${PATHQ}=    Replace String    ${src}    ${BASE}    ${EMPTY}
                            #Log String To Console    Kép PATHQ: ${PATHQ}
                 
                            Create Session    blob    ${BASE}
                            ${resp}=    Get On Session    blob    ${src}
                            Sleep    0.5s
                            Delete All Sessions
                        #Log String To Console    Kép letöltés válasza státusz: ${resp.status_code}

                         # kiterjesztések ellenőrzése
                            ${ctype}=   Get From Dictionary    ${resp.headers}    Content-Type
                            Log String To Console    Kép Content-Type: ${ctype}

                            ${type}    ${category}=   Get Media Type And Category From Mime    ${ctype}
                            Log String To Console    ------------------------------------------------------------- Típus: ${type}, Kategória: ${category}
                            IF    $type == "Statikus"
                                Set Global Variable    ${MEDIA_HAS_PICTURE}    ${True}
                            ELSE
                              Set Global Variable    ${MEDIA_HAS_OTHER_TYPE}    ${True}
                            END
                            


                            ${disp}=    Get From Dictionary    ${resp.headers}    Content-Disposition    default=None
                            Log String To Console    Kép Content-Disposition: ${disp}

                            ${ext}=     Determine Extension From Content-Type    ${ctype}

                            ${fname}=   Determine File Name From Response    ${resp}    ${DEFAULT_BASENAME}${ext}
                            ${fname}=     Get File Name From Header    ${fname}
                            
                            #Media tipus felírása media katalógusba
                            #Fill Excel Cell    ${DIGITALIS_EXCEL_FILE}     ${DIGITALIS_EXCEL_SHEET_MK}     ${MEDIA_ROW_INDEX}    2    ${ctype}
                            Fill Excel Cell    ${DIGITALIS_EXCEL_FILE}     ${DIGITALIS_EXCEL_SHEET_MK}     ${MEDIA_ROW_INDEX}    2    ${type}/ ${category}
                            #Fájl név felírása media katalógusba
                            Fill Excel Cell    ${DIGITALIS_EXCEL_FILE}     ${DIGITALIS_EXCEL_SHEET_MK}     ${MEDIA_ROW_INDEX}    1    ${fname}
                            
                            #Media sheet-en sor növelése
                            ${MEDIA_ROW_INDEX} =    Evaluate    ${MEDIA_ROW_INDEX} + 1

                            #${outfile}=     Set Variable    ${OUTPUT_DIR}/${OUT_BASENAME}${ext}
                            #Log String To Console    Kép letöltés előtt: ${outfile}

                            #Save Response Body To File    ${resp}    ${outfile}
                            Log String To Console    <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< Kép letöltve: ${fname}.${ext}\n\n
                           
                        EXCEPT    AS    ${e2}
                            Log String To Console    [ERROR] Hiba a kép letöltésekor: ${e2}
                        END
                        
                    END
                     ${leckek_szama}=    Evaluate    ${leckek_szama} + 1
                EXCEPT    AS    ${e1}
                    Log String To Console    [WARNING] Hiba a következő oldal gomb kattintásakor: ${e1}
                     #felugró teszt megszakítása gomb kezelése
                    Run Keyword And Ignore Error    Wait Until Element Is Visible    xpath=//button[contains(., 'Teszt megszakítása')]    0.1s
                    Run Keyword And Ignore Error    Click Element    xpath=//button[contains(., 'Teszt megszakítása')]
                    Run Keyword And Ignore Error    Wait Until Element Is Not Visible    xpath=//button[contains(., 'Teszt megszakítása')]    0.1s

                    #felugró teszt újrakezdés gomb kezelése
                    Run Keyword And Ignore Error    Wait Until Element Is Visible    xpath=//button[contains(., 'Újrakezdés')]    0.01s
                    Run Keyword And Ignore Error    Click Element    xpath=//button[contains(., 'Újrakezdés')]
                    Run Keyword And Ignore Error    Wait Until Element Is Not Visible    xpath=//button[contains(., 'Újrakezdés')]    0.01s
                     Sleep    1s
                     #retry
                    Click Button       xpath=//button[contains(@aria-label,'Következő oldalra lépés')]
                END
                  
                #${next_button}=    Get WebElement    xpath=//button[contains(@aria-label,'Következő oldalra lépés')]
                #${is_disabled}=    Get Element Attribute    ${next_button}    disabled
                 Wait Until Element Is Visible    xpath=//button[contains(@aria-label,'Következő oldalra lépés')]     1s
                 Log String To Console   -----  Következő oldal gomb állapot lekérdezése előtt -----
                ${is_disabled}=    Get Element Attribute    xpath=//button[contains(@aria-label,'Következő oldalra lépés')]    disabled

                #Log String To Console    Következő oldal gomb le van tiltva vagy ismeretlen állapot: ${is_enabled}

                IF   $is_disabled == True or $is_disabled == 'true' or $is_disabled == 'True'
                    #Log String To Console    Következő oldal gomb le van tiltva vagy ismeretlen állapot: ${is_disabled}
                    Exit For Loop
                END
           END
           #Sikeres navigáció az összes oldalra
        EXCEPT    AS    ${e}
            #Sikertelen navigáció az összes oldalra
            Log String To Console    [ERROR] Hiba a következő oldal gomb állapot lekérdezésekor: ${e}
            ${new_err}=    Set Variable    Hiba az oldalak közti lapozásban: ${e}
            Append To List    ${errors}    ${new_err}
        END
    END
    #Minden menupont nyitva
     Log String To Console   \n>>>>> Végeredmény visszaírása az Excel-be
    ${unique_errors}=    Remove Duplicates    ${errors}
    ${err_msg}=    Catenate    SEPARATOR=${CR}    @{unique_errors}
    #Log String To Console    \nEredmény visszaírása:${DIGITALIS_EXCEL_FILE}  :  ${CURRENT_SHEET_NAME}    ${testCase_row}    ${unique_errors}
    Mark WebTest Status    ${DIGITALIS_EXCEL_FILE}    ${CURRENT_SHEET_NAME}    ${testCase_row}    ${err_msg}
   
    #oldalszám visszaírása
    Fill Excel Cell    ${DIGITALIS_EXCEL_FILE}     Alapadatok     3    5    ${leckek_szama}
    Fill Excel Cell    ${DIGITALIS_EXCEL_FILE}     ${DIGITALIS_EXCEL_SHEET_MK}      1    7    ${leckek_szama}

   Run Keyword And Ignore Error    Wait Until Element Is Visible    xpath=//button[contains(., 'Újrakezdés')]    1s
    Run Keyword And Ignore Error    Click Element    xpath=//button[contains(., 'Újrakezdés')]
   Run Keyword And Ignore Error    Wait Until Element Is Not Visible    xpath=//button[contains(., 'Újrakezdés')]    1s


*** Keywords ***
Get Parent Title By Highlighted Text
    [Arguments]    ${level}    ${hl_text_raw}
    # 1) pontos egyezés
    #${xpath_exact}=    Set Variable
    #...    (//span[contains(@class,'node-title') and normalize-space(.)='${hl_text_raw}']
    #...     /ancestor::*[@aria-level='${level}'][1]//span[contains(@class,'node-title')])[1]

    ${xpath_exact}=    Set Variable    (//span[contains(@class,'node-title') and contains(normalize-space(.),'${hl_text_raw}')]/ancestor::*[@aria-level='${level}'][1]//span[contains(@class,'node-title')])[1]
    #Log String To Console    \nXPath exact: ${xpath_exact}
    ${status}=    Run Keyword And Return Status    Page Should Contain Element    xpath=${xpath_exact}
    IF    ${status}
        ${txt}=    Get Text    xpath=${xpath_exact}
        RETURN   ${txt}
    END
    # 2) fallback: contains
    #${xpath_contains}=    Set Variable
    #...    (//span[contains(@class,'node-title') and contains(normalize-space(.), '${hl_text_raw}')]
    #...     /ancestor::*[@aria-level='${level}'][1]//span[contains(@class,'node-title')])[1]
    #...    

    ${xpath_contains}=    Set Variable    //*[contains(@class,'highlighted-node')][@aria-level]/preceding::*[@aria-level='${level}'][1]

    ${status2}=    Run Keyword And Return Status    Page Should Contain Element    xpath=${xpath_contains}
    IF    ${status2}
        ${txt}=    Get Text    xpath=${xpath_contains}
        RETURN   ${txt}
    END
    RETURN   N/A

Sanitize Title
    [Arguments]    ${text}
    ${text}=    Convert To String    ${text}
    ${text}=    Replace String    ${text}    \nBlokk    ${EMPTY}
    ${text}=    Replace String    ${text}    \nOldal    ${EMPTY}
    ${text}=    Strip String     ${text}
    RETURN    ${text}

Get Highlighted And Parent Titles By Text
    # 1) highlighted RAW szöveg – ezzel keresünk vissza
    ${hl_text_raw}=    Get Text    xpath=(//div[contains(@class,'highlighted-node')])[1]//span[contains(@class,'node-title')]
    ${hl_text_raw}=    Strip String    ${hl_text_raw}
    ${hl_text_raw}=    Sanitize Title    ${hl_text_raw}
    ${highlighted_name}=    Sanitize Title    ${hl_text_raw}
    
    Log String To Console    RAW highlighted: ${hl_text_raw}

    # 2) parent címek RAW (először exact, aztán contains)
    #${level4_raw}=    Get Parent Title By Highlighted Text    4    ${hl_text_raw}
    #${level4_name}=         Sanitize Title    ${level4_raw}

    ${level3_raw}=    Get Parent Title By Highlighted Text    3    ${hl_text_raw}
    ${level3_name}=         Sanitize Title    ${level3_raw}

    ${level2_raw}=    Get Parent Title By Highlighted Text    2    ${level3_name}
    ${level2_name}=         Sanitize Title    ${level2_raw}

    ${level1_raw}=    Get Parent Title By Highlighted Text    1    ${level2_name}
    ${level1_name}=         Sanitize Title    ${level1_raw}


    Log String To Console    \n--- EREDMÉNY ---\nHighlighted: ${highlighted_name}\nL1: ${level1_name}\nL2: ${level2_name}\nL3: ${level3_name} 


    RETURN    ${highlighted_name}    ${level1_name}    ${level2_name}    ${level3_name}    
 

Get File Name From Header
    [Arguments]    ${header}
    # Elsőként megpróbáljuk a filename* (UTF-8) verziót
    ${has_utf8}=    Evaluate    "'filename*=' in '''${header}'''"
    IF    ${has_utf8}
        ${fname}=    Fetch From Right    ${header}    filename*=
        ${fname}=    Replace String    ${fname}    utf-8''    ${EMPTY}
    ELSE
        ${fname}=    Fetch From Right    ${header}    filename=
    END
    ${fname}=    Replace String    ${fname}    "    ${EMPTY}
    ${fname}=    Replace String    ${fname}    '    ${EMPTY}
    ${fname}=    Replace String    ${fname}    utf-8    ${EMPTY}
    ${fname}=    Strip String    ${fname}
    # kiterjesztések ellenőrzése
    RETURN   ${fname}


Determine Extension From Content-Type
    [Arguments]    ${content_type}
    ${ext}=    Set Variable    .bin
    IF    'image/png' in '${content_type}'
        ${ext}=    Set Variable    .png
    ELSE IF    'image/jpeg' in '${content_type}' or 'image/jpg' in '${content_type}'
        ${ext}=    Set Variable    .jpg
    ELSE IF    'image/gif' in '${content_type}'
        ${ext}=    Set Variable    .gif
    ELSE IF    'image/webp' in '${content_type}'
        ${ext}=    Set Variable    .webp
    ELSE IF    'video/mp4' in '${content_type}'
        ${ext}=    Set Variable    .mp4
    ELSE IF    'video/webm' in '${content_type}'
        ${ext}=    Set Variable    .webm
    ELSE IF    'video/ogg' in '${content_type}'
        ${ext}=    Set Variable    .ogv
    ELSE IF    'audio/mpeg' in '${content_type}'
        ${ext}=    Set Variable    .mp3
    ELSE IF    'audio/ogg' in '${content_type}'
        ${ext}=    Set Variable    .ogg
    ELSE IF    'audio/wav' in '${content_type}'
        ${ext}=    Set Variable    .wav
    ELSE IF    'audio/webm' in '${content_type}'
        ${ext}=    Set Variable    .weba
    ELSE
        Log    ⚠️ Ismeretlen Content-Type: ${content_type}
    END
    RETURN   ${ext}
    

Determine File Name From Response
        [Arguments]    ${resp}    ${default_name}
        ${headers}=    Set Variable    ${resp.headers}
        ${disp}=    Get From Dictionary    ${headers}    Content-Disposition    default=None
        IF    '${disp}' != 'None' and 'filename=' in '${disp}'
            ${fname}=    Fetch From Right    ${disp}    filename=
            ${fname}=    Replace String    ${fname}    "    ${EMPTY}
            ${fname}=    Replace String    ${fname}    '    ${EMPTY}
            ${fname}=    Strip String    ${fname}
        ELSE
            ${fname}=    Set Variable    ${default_name}
        END
        RETURN   ${fname}


*** Keywords ***
Get Media Type And Category From Mime
    [Arguments]    ${mime}
    ${mime}=    Convert To Lowercase    ${mime}

    &{mime_map}=    Create Dictionary
    ...    image/jpeg=Statikus | Kép (raszteres)
    ...    image/jpg=Statikus | Kép (raszteres)
    ...    image/png=Statikus | Kép (raszteres)
    ...    image/bmp=Statikus | Kép (raszteres)
    ...    image/tiff=Statikus | Kép (raszteres)
    ...    image/svg+xml=Statikus | Kép (vektoros)
    ...    audio/mpeg=Statikus | Hang
    ...    audio/wav=Statikus | Hang
    ...    audio/flac=Statikus | Hang
    ...    audio/ogg=Statikus | Hang
    ...    audio/aac=Statikus | Hang
    ...    image/gif=Statikus vagy dinamikus | Kép (raszteres) vagy animáció
    ...    image/webp=Statikus vagy dinamikus | Kép (raszteres) vagy animáció
    ...    video/mp4=Dinamikus | Videó
    ...    video/x-msvideo=Dinamikus | Videó
    ...    video/quicktime=Dinamikus | Videó
    ...    video/x-ms-wmv=Dinamikus | Videó
    ...    video/x-matroska=Dinamikus | Videó
    ...    video/webm=Dinamikus | Videó vagy animáció
    ...    application/x-shockwave-flash=Dinamikus | Animáció

    ${entry}=    Get From Dictionary    ${mime_map}    ${mime}    default=Ismeretlen | Ismeretlen

    ${type}=         Set Variable    ${entry.split(" | ")[0]}
    ${category}=     Set Variable    ${entry.split(" | ")[1]}

    RETURN    ${type}    ${category}
