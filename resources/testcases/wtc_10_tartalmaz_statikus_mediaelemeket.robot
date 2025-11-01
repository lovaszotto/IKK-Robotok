*** Settings ***
Library    SeleniumLibrary 
Resource   ${CURDIR}/../keywords.robot
Resource   ${CURDIR}/../../PLG-02-Excel-kitolto.robot


*** Keywords ***
Tartalmaz statikus mediaelemeket ellenőrzése
    [Documentation]   Tartalmaz statikus mediaelemeket ellenőrzése
    Log String To Console    \n**************************************************************************
    Log String To Console    * wtc_10-Tartalmaz statikus mediaelemeket ellenőrzése
    Log String To Console    **************************************************************************\n
    ${testCase_row}=    Set Variable    12
   ${err_msg}=    Set Variable    ${EMPTY}
   ${errors}=    Create List
   ${CR}=    Set Variable    ;
   ${next_button}=    Set Variable    ${EMPTY}
   ${is_disabled}=    Set Variable    None
  # Nyelv detektálás változók inicializálása
    ${hungarian_count}=    Set Variable    0
    ${other_lang_count}=    Set Variable    0
    ${total_valid_texts}=    Set Variable    0

     #Oldal szövegek ellenőrzése
     ${found_count}=    Set Variable    0
     ${not_found_count}=    Set Variable    0
    
      ${media_has_picture}=   Get Variable Value    ${MEDIA_HAS_PICTURE}    ${False}

    IF     $media_has_picture == ${False}
        ${new_err}=    Set Variable    Nincsenek statikus médiaelemek a dokumentumban!
        IF    $err_msg == ''
            ${err_msg}=    Set Variable    ${new_err}
        ELSE
            ${err_msg}=    Catenate    SEPARATOR=${CR}    ${err_msg}    ${new_err}
        END
        Log String To Console     [ERROR] ${new_err}
        Append To List    ${errors}    ${new_err}
    END

    #Végeredmény visszaírása az Excel-be
    Log String To Console   \n>>>>> Végeredmény visszaírása az Excel-be
    ${unique_errors}=    Remove Duplicates    ${errors}
    ${err_msg}=    Catenate    SEPARATOR=${CR}    @{unique_errors}
 
    #Log String To Console    \nEredmény visszaírása:${DIGITALIS_EXCEL_FILE}  :  ${CURRENT_SHEET_NAME}    ${testCase_row}    ${unique_errors}
    Mark WebTest Status    ${DIGITALIS_EXCEL_FILE}    ${CURRENT_SHEET_NAME}    ${testCase_row}    ${err_msg}
   
 

