*** Settings ***
Library    SeleniumLibrary 
Resource   ${CURDIR}/../keywords.robot
Resource   ${CURDIR}/../../PLG-02-Excel-kitolto.robot


*** Keywords ***
Tartalmaz fogalomtárat ellenőrzése
    [Documentation]   Tartalmaz fogalomtárat ellenőrzése
    Log String To Console    \n**************************************************************************
    Log String To Console    * wtc_11-Tartalmaz fogalomtárat ellenőrzése
    Log String To Console    **************************************************************************\n
    ${testCase_row}=    Set Variable    11
   ${err_msg}=    Set Variable    ${EMPTY}
   ${errors}=    Create List
   ${CR}=    Set Variable    ;

    ${rc}    ${msg}=    Run Keyword And Ignore Error     Wait Until Page Contains Element    xpath=//button[contains(@aria-label,'Fogalomtár megnyitása')]   2s    
    Log String To Console    \Fogalomtár megnyitás várakozás eredménye: ${rc} ${msg}
 
  IF    '${rc}' == 'PASS'
       Log String To Console    >> A dokumentum tartalmaz fogalomtárat.
       # Overlay eltávolításának várakozása, ha szükséges
       #Popup Handler


       Click Button       xpath=//button[contains(@aria-label,'Fogalomtár megnyitása')]
         Log String To Console    >>> Fogalomtár megnyitó gomb clicked
       Wait Until Page Contains Element    xpath=//glossary-panel   5s     

       #Fogalomtár panel megjelent
       #
       #találatok számának ellenőrzése
       #
       # Paginátor beolvasása
       Wait Until Element Is Visible    xpath=(//*[contains(@class,'mat-mdc-paginator-range-label')])   5s 
        ${pages_text}=    Get Text    xpath=(//*[contains(@class,'mat-mdc-paginator-range-label')])
         ${szoveg_norm}=    Replace String    ${pages_text}    –    -
         ${szoveg_norm}=    Strip String    ${szoveg_norm}
       # Paginátor információk kiírása
       Log String To Console    >> Paginátor információk: [${szoveg_norm}]
        IF    '${szoveg_norm}' == '0 - 0 of 0'
          #Nincsenek bejegyzések a fogalomtárban
          ${new_err}=    Set Variable    A lecke fogalomtára üres!
          IF    '${err_msg}' == ''
              ${err_msg}=    Set Variable    ${new_err}
          ELSE
              ${err_msg}=    Catenate    SEPARATOR=${CR}    ${err_msg}    ${new_err}
          END
          Log String To Console     [ERROR] ${new_err}
          Append To List    ${errors}    ${new_err}
        ELSE
              Log String To Console    >> A lecke fogalomtára nem üres.
      END
    ELSE
        ${new_err}=    Set Variable    A dokumentum nem tartalmaz fogalomtárat!
        IF    ${err_msg} == ''
            ${err_msg}=    Set Variable    ${new_err}
        ELSE
            ${err_msg}=    Catenate    SEPARATOR=${CR}    ${err_msg}    ${new_err}
        END
        Log String To Console     [ERROR] ${new_err}
        #Append To List    ${errors}    ${new_err}
    END

    #Végeredmény visszaírása az Excel-be
    Log String To Console   \n>>>>> Végeredmény visszaírása az Excel-be:[${err_msg}]
   # ${unique_errors}=    Remove Duplicates    ${errors}
   # ${err_msg}=    Catenate    SEPARATOR=${CR}    @{unique_errors}
 
    #Log String To Console    \nEredmény visszaírása:${DIGITALIS_EXCEL_FILE}  :  ${CURRENT_SHEET_NAME}    ${testCase_row}    ${unique_errors}
    Mark WebTest Status    ${DIGITALIS_EXCEL_FILE}    ${CURRENT_SHEET_NAME}    ${testCase_row}    ${err_msg}



