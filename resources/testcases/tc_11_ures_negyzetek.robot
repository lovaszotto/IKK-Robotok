*** Settings ***
Library    ../../libraries/DocxReader.py
Library    OperatingSystem
Library    String
Library    Collections
Library    ../../libraries/DocxXmlExtractor.py
Resource   ${CURDIR}/../keywords.robot
Resource   ${CURDIR}/../../PLG-02-Excel-kitolto.robot

*** Keywords ***
Test Case 11 - Ures Negyzetek Ellenorzese
    [Documentation]    11 - Üres négyzetek ellenőrzése
    Log String To Console     \n\[11/24] Üres négyzetek ellenőrzése
   ${docx_json}=    Get Variable Value    ${DOCX_JSON}    ${EMPTY}
   ${testCase_row}=    Set Variable    13
    ${excel_file}=    Get Variable Value    ${CURRENT_EXCEL_FILE}    ${EMPTY}
    ${sheet_name}=    Get Variable Value    ${CURRENT_SHEET_NAME}    ${EMPTY}
    ${err_msg}=    Set Variable    ${EMPTY}

    ${pars}=    Evaluate    [{'idx': i+1, 'text': p.text, 'style': (p.style.name if p.style else 'N/A')} for i,p in enumerate(__import__('docx').Document(r'''${docx_file}''').paragraphs)]
    FOR    ${par}    IN    @{pars}
    ${text}=    Get From Dictionary    ${par}    text
    # A Python Evaluate kifejezeseknel biztonsagosan escape-eljuk a szoveget
    ${text_escaped}=    Evaluate    repr("""${text}""")
    # Egyszeru karakter-szures a checkbox/square szimbolumokra es a hibas/garbled karakterekre (PUA, halfwidth/fullwidth, replacement)
    ${matches}=    Evaluate    [ch for ch in ${text_escaped} if (ch in '\u2610\u2611\u2612\u25A1\u25A0\u25CB\u25CF') or (0xE000 <= ord(ch) <= 0xF8FF) or (0xFF00 <= ord(ch) <= 0xFFEF) or (ord(ch) == 0xFFFD)]
    ${matches_count}=    Get Length    ${matches}
        #írja ki az első találatot követő 50 karaktert
        IF    ${matches_count} > 0    
            ${first_match}=    Set Variable    ${matches}[0]
            ${first_code}=    Evaluate    "U+%04X" % ord("""${first_match}""")
            ${first_match_pos}=    Evaluate    (${text_escaped}).find("""${first_match}""")
            ${text_preview}=    Evaluate    (${text_escaped})[${first_match_pos}:${first_match_pos}+50]
            ${err_msg}=    Set Variable    Tiltott/hibás karakter(ek) a dokumentumban (pl. üres négyzet, garbled). Első: "${first_match}" (${first_code}) (darab: ${matches_count}). Kontextus: "${text_preview}"
            Log String To Console    ${err_msg}
        END        
    END
    Mark Test Status    ${excel_file}    ${sheet_name}    ${testCase_row}    ${err_msg}
