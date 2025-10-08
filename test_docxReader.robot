*** Settings ***
Library    ./libraries/DocxReader.py
Library    BuiltIn
Library    Collections

*** Variables ***
${DOCX}    ${EMPTY}
${DEBUG}   ${TRUE}

*** Test Cases ***
Read DOCX And Print JSON
    [Documentation]    Olvassa be a DOCX-et és írja ki a teljes JSON-t a konzolra.
    Run Keyword If    '${DOCX}' == '${EMPTY}'    Fail    Állítsd be a ${DOCX} változót a futtatásnál: -v DOCX:c:/path/to/file.docx
    ${json}=    Read Docx All As Json    ${DOCX}    debug=${DEBUG}
    ${length}=    Get Length    ${json}
    Log String To Console    JSON hossza (karakter): ${length}
    Should Contain    ${json}    paragraphs
    # Opcionális: JSON parse és bekezdések száma
    ${data}=    Evaluate    __import__('json').loads(r'''${json}''')    modules=json
    ${paragraphs}=    Get From Dictionary    ${data}    paragraphs
    ${pcount}=    Get Length    ${paragraphs}
    Log String To Console    Bekezdések száma: ${pcount}
