*** Settings ***
Resource    resources/keywords.robot
Resource    resources/variables.robot
Library     String
Library     BuiltIn
Library     Collections

*** Keywords ***
DOCX Beolvasás Teszt
    #Log To Console    [TRACE] DOCX Beolvasás Teszt elindult
    [Arguments]    ${file_path}    ${redundancia_id}
    # Redundancia ID beállítása globális változóként
    Set Global Variable    ${REDUNDANCIA_ID}    ${redundancia_id}
    Set Global Variable    ${DOCX_FILE}    ${file_path}
    [Documentation]    DOCX fájl feldolgozása hash-eléssel és plagiarízmus ellenőrzéssel.
    ...                10 karakternél rövidebb sorokat kihagyja a feldolgozásból.
    #Log To Console    <<< BEOLVASÁS INDUL >>>
    #${szoveg}=    Beolvasom A DOCX Fájlt
    ${szoveg}=    Set Variable    ${SZOVEG}
   
   ${overview_string}=    Set Variable    ${EMPTY}    # Progress karakterek gyűjtése            
    ${current_status}=    Set Variable    Üres
    
    #Log To Console     ${szoveg}
   
   