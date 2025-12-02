*** Settings ***
Resource   ${CURDIR}/../keywords.robot
Resource   ${CURDIR}/../../PLG-02-Excel-kitolto.robot

*** Keywords ***
Impresszum megfelelőség ellenőrzése
    [Documentation]    Impresszum megfelelőség ellenőrzése
    Log String To Console With File    \n**************************************************************************
    Log String To Console With File    * wtc_02-Impresszum megfelelőség ellenőrzése
    Log String To Console With File    **************************************************************************\n
 
    ${testCase_row}=    Set Variable    4
   ${err_msg}=    Set Variable    ${EMPTY}
   ${errors}=    Create List
    ${szerzo}=    Set Variable    ${EMPTY}
    ${szakmai_lektor}=    Set Variable    ${EMPTY}

  #impresszum keresése és kiválasztása
    Wait Until Element Is Visible    xpath=//span[contains(text(),'Impresszum')]    5s
    ${impresszum_button}=    Get WebElement    xpath=//span[contains(text(),'Impresszum')]
    ${impresszum_title}=    Get Text   ${impresszum_button}    
    Click Button    ${impresszum_button}    
    
    ##############################################################################################
    #IKK logo ellenőrzése
    ##############################################################################################
     Log String To Console With File   \n>>>>> IKK logó ellenőrzése
     ${ALT_TEXT}     Set Variable    Az Innovatív Képzéstámogató Központ logója
     
     ${rc}    ${msg}=    Run Keyword And Ignore Error     Wait Until Element Is Visible    xpath=//img[contains(@alt, 'Az Innovatív Képzéstámogató Központ logója')]    2s
     IF    '${rc}' == 'PASS'
            ${src}=    Get Element Attribute    xpath=//img[contains(@alt, 'Az Innovatív Képzéstámogató Központ logója')]    src
            Log String To Console With File    \nIKK logója URL: ${src}
            #ha scr üres
            IF    '${src}' == ''
                ${new_err}=    Set Variable     Az IKK logó nem található meg az impresszumban!
                Append To List    ${errors}    ${new_err}
            END
    ELSE
              ${new_err}=    Set Variable     Az IKK logó nem található meg az impresszumban!
              Append To List    ${errors}    ${new_err}
    END
    ##############################################################################################
    #Széchenyi logo ellenőrzése
    ##############################################################################################
    # Log String To Console With File   \n>>>>> Széchenyi 2020 program logója ellenőrzése
    # ${ALT_TEXT2}     Set Variable    A Széchenyi 2020 program logója
    # ${rc2}    ${msg2}=    Run Keyword And Ignore Error     Wait Until Element Is Visible    xpath=//img[contains(@alt, 'A Széchenyi 2020 program logója')]    10s
    # Log String To Console With File    \nImpresszum logó ellenőrzés eredménye: ${rc2} ${msg2}
    # IF    '${rc2}' == 'PASS'
    #        ${src2}=    Get Element Attribute    xpath=//img[contains(@alt, 'A Széchenyi 2020 program logója')]    src
    #        Log String To Console With File    \nSzéchenyi 2020 program logója URL: ${src2}
    #ELSE
    #          Log String To Console With File    \nSzéchenyi 2020 program logója nem található meg.
    #          ${new_err}=    Set Variable     Az Széchenyi 2020 program logója nem található meg az impresszumban!
    #          Append To List    ${errors}    ${new_err}
    #END
    ##############################################################################################
    #szerző ellenőrzése
    ##############################################################################################
     Log String To Console With File   \n>>>>> Szerző ellenőrzése
    ${rc}    ${msg}=    Run Keyword And Ignore Error     Wait Until Element Is Visible   xpath=//div[contains(@class,'custom-format')]//strong[normalize-space(.)='Szerző:']/following-sibling::span[1]    2s
    IF    '${rc}' == 'PASS'
        ${raw}=    Get Text    xpath=//div[contains(@class,'custom-format')]//strong[normalize-space(.)='Szerző:']/following-sibling::span[1]
        ${szerzo}=    Strip String    ${raw}
        ${szerzo}=   Convert To UpperCASE    ${szerzo}
  
        ${dokumentum_szerzo} =    Get Variable Value    ${DOKUMENTUM_SZERZO}    ${EMPTY}
        ${dokumentum_szerzo}=    Convert To Uppercase    ${dokumentum_szerzo}

        Log String To Console With File    Szerző neve: ${szerzo}
        Log String To Console With File    Dokumentum szerző neve: ${dokumentum_szerzo}
        
        IF    $dokumentum_szerzo != $szerzo
            ${new_err}=    Set Variable     A dokumentum szerzője nem egyezik meg a várt értékkel. Kézirat: ${dokumentum_szerzo} DT: ${szerzo}
            Append To List    ${errors}    ${new_err}
            Log String To Console With File    A dokumentum szerzője nem egyezik meg a várt értékkel. Kézirat: ${dokumentum_szerzo} DT: ${szerzo}
        ELSE
              Log String To Console With File    A dokumentum szerzője rendben.  DT: '${szerzo}'
        END
    ELSE
        ${new_err}=    Set Variable     Szerző mező nem található meg az impresszumban!
        Append To List    ${errors}    ${new_err}
    END
    
    ##############################################################################################
    #Lektorok ellenőrzése
    ##############################################################################################
    Log String To Console With File   \n>>>>> Lektorok ellenőrzése
    ${rc}    ${msg}=    Run Keyword And Ignore Error     Wait Until Element Is Visible    xpath=//strong[contains(., 'További szakmai közreműködők')]    2s
     IF    '${rc}' == 'PASS'
        ${szakmai_lektor}=    Get Text    xpath=//strong[contains(., 'További szakmai közreműködők')]/following-sibling::*[1]
        ${szakmai_lektor}=    Strip String    ${szakmai_lektor}
        ${szakmai_lektor}=   Convert To UpperCASE    ${szakmai_lektor}    
        ${szakmai_lektor_list}=    Split String    ${szakmai_lektor}    ,
      Log String To Console With File    WEB szakmai közreműködők: ${szakmai_lektor_list}

        ${dokumentum_szakmai_lektor} =    Get Variable Value    ${DOKUMENTUM_SZAKMAI_LEKTOR}    ${EMPTY}
        ${dokumentum_szakmai_lektor}=    Strip String    ${dokumentum_szakmai_lektor}
        ${dokumentum_szakmai_lektor}=   Convert To UpperCASE    ${dokumentum_szakmai_lektor}    
        ${dokumentum_szakmai_lektor_list}=     Split String    ${dokumentum_szakmai_lektor}    ,

        Log String To Console With File    Dokumentum szakmai közreműködők: ${dokumentum_szakmai_lektor_list}
      

        FOR    ${act_lektor}    IN    @{dokumentum_szakmai_lektor_list}
            ${act_lektor}=    Strip String    ${act_lektor}
            Log String To Console With File    Ellenőrzés alatt álló lektor: ${act_lektor}
      
              ${is_in_list}=    Run Keyword And Return Status    List Should Contain Value    ${szakmai_lektor_list}    ${act_lektor}

            Log String To Console With File    Ellenőrzéseredménye: ${is_in_list}

            IF    not ${is_in_list}
                ${new_err}=    Set Variable    A dokumentum szakmai lektora NINCS a webes listában. Kézirat: '${act_lektor}'
                Append To List    ${errors}    ${new_err}
            END

        END
     ELSE
          ${new_err}=    Set Variable     További szakmai közreműködők mező nem található meg az impresszumban!
          Append To List    ${errors}    ${new_err}
     END
     Log String To Console With File   \n>>>>> Lektorok ellenőrzése - vége
    ##############################################################################################
    #Szerző és Lektor nem azonos ellenőrzése
    ##############################################################################################
    Log String To Console With File   \n>>>>> Szerző Lektorok ellenőrzése
     ${szerzo_list}=    Split String    ${szerzo}    ,
    ${szakmai_lektor_list}=    Split String    ${szakmai_lektor}    ,
    #Log String To Console    Szerző lista: ${szerzo_list}
    #Log String To Console    Lektor lista: ${szakmai_lektor_list}
    FOR    ${szerzo_item}    IN    @{szerzo_list}
        FOR    ${lektor_item}    IN    @{szakmai_lektor_list}
            ${szerzo_item}=    Strip String    ${szerzo_item}
            ${lektor_item}=    Strip String    ${lektor_item}
            #Log String To Console    Compare:${szerzo_item} and ${lektor_item}
            IF    '${szerzo_item}' == '${lektor_item}'
                #Log String To Console    Megegyezik a szerző és a lektor: ${szerzo_item}
                ${new_err}=    Set Variable    A Kéziratíró és a Szakmai lektor nem lehet azonos!
                IF    $err_msg == ''
                    ${err_msg}=    Set Variable    ${new_err}
                ELSE
                    ${err_msg}=    Catenate    SEPARATOR=${CR}    ${err_msg}    ${new_err}
                END
            END
        END
    END

    ##############################################################################################
    #Tananyagot készítette ellenőrzése
    ##############################################################################################
    Log String To Console With File   \n>>>>> Tananyagot készítette ellenőrzése
    ${rc}    ${msg}=    Run Keyword And Ignore Error     Wait Until Element Is Visible    xpath=//strong[contains(., 'A tananyagot készítette')]    2s
     IF    '${rc}' == 'PASS'
        ${text}=    Get Text    xpath=//strong[contains(., 'A tananyagot készítette')]/following-sibling::*[1]
        ${text}=    Strip String    ${text}
        ${text}=   Convert To UpperCASE    ${text}    
        IF    $text == ''
            ${new_err}=    Set Variable     A tananyagot készítette mező üres a dokumentumban!
            Append To List    ${errors}    ${new_err}
        END 
     ELSE
          ${new_err}=    Set Variable     Tananyagot készítette mező nem található meg az impresszumban!
          Append To List    ${errors}    ${new_err}
     END
    
    #Végeredmény visszaírása az Excel-be
    Log String To Console With File   \n>>>>> Végeredmény visszaírása az Excel-be
    ${unique_errors}=    Remove Duplicates    ${errors}
    ${err_msg}=    Catenate    SEPARATOR=${CR}    @{unique_errors}
 
    Log String To Console With File    \nEredmény visszaírása:${DIGITALIS_EXCEL_FILE}  :  ${CURRENT_SHEET_NAME}    ${testCase_row}    ${err_msg}
    Mark WebTest Status    ${DIGITALIS_EXCEL_FILE}    ${CURRENT_SHEET_NAME}    ${testCase_row}    ${err_msg}
   