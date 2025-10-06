*** Settings ***
Library     Collections
Resource    ${CURDIR}/../keywords.robot
Resource    ${CURDIR}/../../PLG-02-Excel-kitolto.robot
*** Keywords ***
Test Case 22 - Cimlap Tartalom Ellenorzese
    [Documentation]    22 - Címlap tartalom ellenőrzése
    Log To Console    [22/24] Címlap tartalom ellenőrzése
    ${excel_file}=    Get Variable Value    ${CURRENT_EXCEL_FILE}    ${EMPTY}
    ${sheet_name}=    Get Variable Value    ${CURRENT_SHEET_NAME}    ${EMPTY}
    ${testCase_row}=    Set Variable    24
    ${CR}=    Set Variable    ;
    ${err_list}=    Create List
    ${ok}    ${cover}    ${base_err}=    Parse Cover Table
    IF    not ${ok}
        Append To List    ${err_list}    ${base_err}
    ELSE
        # Alias mapping – alternatív elnevezések támogatása (eredeti + normalizált + space nélküli variánsok)
        ${aliases}=    Create Dictionary    Kéziratíró=Kéziratíró|Szerző|Kézirat író|keziratíró|keziratiro|szerzo    Szakmai lektor=Szakmai lektor|Lektor|szakmai lektor|szakmailektor|lektor    Ágazat=Ágazat|Ágazat megnevezése|agazat|agazatmegnevezese    Szakma=Szakma|Szakma megnevezése|szakma|szakmamegnevezese    Tanulási terület=Tanulási terület|Tanulasi terulet|tanulási terület|tanulasiterulet|tanulasiter    Tantárgy=Tantárgy|Tantargy|tantargy    Évfolyam=Évfolyam|Evfolyam|evfolyam    Óraszám=Óraszám|Óraszam|oraszam
        ${normalized}=    Create Dictionary
        FOR    ${main}    ${alts}    IN    &{aliases}
            ${found}=    Set Variable    ${EMPTY}
            ${alt_list}=    Split String    ${alts}    |
            FOR    ${candidate}    IN    @{alt_list}
                ${has_key}=    Run Keyword And Return Status    Dictionary Should Contain Key    ${cover}    ${candidate}
                IF    ${has_key}
                    ${found}=    Get From Dictionary    ${cover}    ${candidate}
                    Exit For Loop
                END
            END
            IF    '${found}' != ''
                Set To Dictionary    ${normalized}    ${main}=${found}
            END
        END
        FOR    ${k}    ${v}    IN    &{normalized}
            ${already}=    Run Keyword And Return Status    Dictionary Should Contain Key    ${cover}    ${k}
            IF    not ${already}
                Set To Dictionary    ${cover}    ${k}=${v}
            END
        END
        # Kötelező mező kulcsok és hiba szövegek
        @{required}=    Create List    Kéziratíró    Szakmai lektor    Ágazat    Szakma    Tanulási terület    Tantárgy    Évfolyam    Óraszám
        FOR    ${field}    IN    @{required}
            ${present}=    Run Keyword And Return Status    Dictionary Should Contain Key    ${cover}    ${field}
            IF    not ${present}
                Append To List    ${err_list}    A ${field} mező nem létezik a címlapon!
            ELSE
                ${value}=    Get From Dictionary    ${cover}    ${field}
                ${is_blank}=    Run Keyword And Return Status    Should Be True    '${value.strip()}' == '' or '${value.strip()}' == '#'
                IF    ${is_blank}
                    Append To List    ${err_list}    A ${field} mező üres!
                END
            END
        END
    END
    ${unique_errs}=    Remove Duplicates    ${err_list}
    ${err_msg}=    Catenate    SEPARATOR=\n    @{unique_errs}
    Mark Test Status    ${excel_file}    ${sheet_name}    ${testCase_row}    ${err_msg}
