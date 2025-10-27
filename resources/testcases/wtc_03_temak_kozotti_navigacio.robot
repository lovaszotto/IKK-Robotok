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
    Log String To Console    \n[wtc_03_temak_kozotti_navigacio] Témák közötti navigáció ellenőrzése
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


    ${rc}    ${msg}=    Run Keyword And Ignore Error     Wait Until Page Contains Element    xpath=//button[contains(@aria-label,'Következő oldalra lépés')]   10s    
    Log String To Console    \nVárakozás eredménye: ${rc} ${msg}
 
    IF    '${rc}' == 'PASS'
        TRY 
           WHILE    ${is_disabled} is ${NONE}
                #Log String To Console    Következő oldal gomb engedélyezett, lépés a következő oldalra.
                TRY 
                #${next_button}=    Get WebElement    xpath=//button[contains(@aria-label,'Következő oldalra lépés')]
                   Log To Console    Következő oldal gomb kattintás előtt
                    #felugró teszt megszakítása gomb kezelése
                    Run Keyword And Ignore Error    Wait Until Element Is Visible    xpath=//button[contains(., 'Teszt megszakítása')]    0.1s
                    Run Keyword And Ignore Error    Click Element    xpath=//button[contains(., 'Teszt megszakítása')]
                    Run Keyword And Ignore Error    Wait Until Element Is Not Visible    xpath=//button[contains(., 'Teszt megszakítása')]    0.1s
            

                    Wait Until Page Does Not Contain Element    css=.cdk-overlay-backdrop    5s
                    Wait Until Element Is Visible   xpath=//button[contains(@aria-label,'Következő oldalra lépés')]    1s
                    Click Button       xpath=//button[contains(@aria-label,'Következő oldalra lépés')]
                   #Log To Console    Következő oldal gomb kattintás után
                      #felugró teszt megszakítása gomb kezelése
                    #Run Keyword And Ignore Error    Wait Until Element Is Visible    xpath=//button[contains(., 'Teszt megszakítása')]    0.1s
                    #Run Keyword And Ignore Error    Click Element    xpath=//button[contains(., 'Teszt megszakítása')]
                    #Run Keyword And Ignore Error    Wait Until Element Is Not Visible    xpath=//button[contains(., 'Teszt megszakítása')]    0.1s
                
                    #todo egy oldal tartalmának ellenőrzése
       
                    ${images}=    Get WebElements    xpath=//app-image-field//img
                    ${image_count}=    Get Length    ${images}
                    Log String To Console    \n\n>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>Talált képek száma: ${image_count}
                   
                    FOR    ${img}    IN    @{images}
                     
                        ${alt}=    Get Element Attribute    xpath=${img}    alt
                        Log String To Console    \nKép alt: ${alt}

                        ${src}=    Get Element Attribute    ${img}    src
                        #Log String To Console    Kép forrás: ${src}
                         # Az ${src}-ben lecseréljük a ${BASE} rész üresre
                         # így csak a PATHQ marad meg
                        ${PATHQ}=    Replace String    ${src}    ${BASE}    ${EMPTY}
                        #Log String To Console    Kép PATHQ: ${PATHQ}
                        
                        Log To Console    CREATE SESSION előtt
                        Create Session    ${SESSION}    ${BASE}    verify=True
                        Log To Console    CREATE SESSION után

                        ${resp}=    Get On Session    ${SESSION}    ${PATHQ}    expected_status=200
                        Log To Console    Kép letöltés válasza státusz: ${resp.status_code}

                        ${ctype}=   Get From Dictionary    ${resp.headers}    Content-Type
                        Log To Console    Kép Content-Type: ${ctype}
                        ${disp}=    Get From Dictionary    ${resp.headers}    Content-Disposition    default=None
                        Log To Console    Kép Content-Disposition: ${disp}

                        ${ext}=     Determine Extension From Content-Type    ${ctype}
                        ${fname}=   Determine File Name From Response    ${resp}    ${DEFAULT_BASENAME}${ext}
                        
                        
                        #${outfile}=     Set Variable    ${OUTPUT_DIR}/${OUT_BASENAME}${ext}
                        #Log To Console    Kép letöltés előtt: ${outfile}

                        #Save Response Body To File    ${resp}    ${outfile}
                        Log To Console    <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< Kép letöltve: ${fname}.${ext}\n\n
                        Delete All Sessions
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
                 Log To Console   -----  Következő oldal gomb állapot lekérdezése előtt -----
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
   Run Keyword And Ignore Error    Wait Until Element Is Visible    xpath=//button[contains(., 'Újrakezdés')]    1s
    Run Keyword And Ignore Error    Click Element    xpath=//button[contains(., 'Újrakezdés')]
   Run Keyword And Ignore Error    Wait Until Element Is Not Visible    xpath=//button[contains(., 'Újrakezdés')]    1s



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