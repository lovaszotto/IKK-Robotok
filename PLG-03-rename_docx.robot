*** Settings ***
Resource    resources/keywords.robot
Library    OperatingSystem
Library    Process
Library    String
Library    BuiltIn

*** Keywords ***

Rename Docx With Prefix
    [Arguments]    ${file_name}
  

    # Szétszedjük path és filename részre (raw string, hogy ne legyen escape warning)
    ${file_path}=    Evaluate    os.path.dirname(r'''${file_name}''')    modules=os
    ${base_name}=    Evaluate    os.path.basename(r'''${file_name}''')    modules=os
    Log String To Console    file_path = ${file_path}
    Log String To Console    base_name = ${base_name}

    ${rename_prefix}=    Get Variable Value    ${RENAME_PREFIX}    NONE
    ${rename_prefix}=    Strip String    ${rename_prefix}
    # Ha a prefix NONE, nincs átnevezés
    Run Keyword If    '${rename_prefix}' == 'NONE'    Log String To Console    Átnevezés kihagyva: prefix=NONE
    Run Keyword If    '${rename_prefix}' == 'NONE'    Return From Keyword    ${file_name}

    ${should_rename}=    Evaluate    not "${base_name}".startswith("${rename_prefix}")
    IF    not ${should_rename}
        Log String To Console    Már prefix-szel kezdődik: ${base_name}
        Return From Keyword    ${file_name}
    END
    Log String To Console    Rename_Prefix = ${rename_prefix}
    ${new_name}=    Set Variable    ${rename_prefix}${base_name}
    ${src}=    Join Path    ${file_path}    ${base_name}
    ${dst}=    Join Path    ${file_path}    ${new_name}
    
    #Log To Console    >>>>>>>>>>>>>${src}->${dst}
    Move File    ${src}    ${dst}
    #Log To Console    Átnevezve: ${base_name} -> ${new_name}
    ${new_full_path}=    Join Path    ${file_path}    ${new_name}
    Log String To Console    >>>>>>>>>>>>>>>>> Átnevezve: ${new_full_path} 
    
    Return From Keyword    ${new_full_path}
