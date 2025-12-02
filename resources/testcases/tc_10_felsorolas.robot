*** Settings ***
Library     Collections
# RPA.JSON eltávolítva – nem használt és hiányzó modul hibát okozott
Resource    ${CURDIR}/../keywords.robot
Resource    ${CURDIR}/../../PLG-02-Excel-kitolto.robot

*** Keywords ***
Test Case 10 - Felsorolas Ellenorzese
    [Documentation]    10 - Felsorolások ellenőrzése
    Log String To Console     \n\>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>[10/24] Felsorolások ellenőrzése 
      ${testCase_row}=    Set Variable    12
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
    #Log String To Console    docx_file fájl:${docx_file}

      ${pars}=    Evaluate    [{'idx': i+1, 'text': p.text, 'style': (p.style.name if p.style else 'N/A')} for i,p in enumerate(__import__('docx').Document(r'''${docx_file}''').paragraphs)]
 
    FOR    ${par}    IN    @{pars}
        ${idx}=    Get From Dictionary    ${par}    idx
        ${text}=    Get From Dictionary    ${par}    text
        # Trim whitespace safely (avoid Evaluate complications)
        ${text}=    Set Variable    ${text}
        ${text}=    Replace String    ${text}    \r\n    \n
        ${text}=    Replace String    ${text}    \n    \n
        ${text}=    Strip String    ${text}
        ${style}=    Get From Dictionary    ${par}    style
    # Üres bekezdések naplózása – hossz alapú ellenőrzés (nincs idéző / Evaluate problémák)
    ${_len}=    Get Length    ${text}
    #IF    ${_len} == 0
    #ha nem normal és nem body text, akkor naplózzuk
        #IF    "${style}" != "Normal" and "${style}" != "Body Text"
            #Log String To Console    ${idx}: [${style}] "${text}"
        #END
    #END
        
    END    
    # Változók törlése
    Delete Variables    ${pars}    ${par}    ${text}