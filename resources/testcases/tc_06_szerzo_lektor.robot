*** Settings ***
Library     Collections
Resource    ${CURDIR}/../keywords.robot
Resource    ${CURDIR}/../../PLG-02-Excel-kitolto.robot

*** Keywords ***
Test Case 06 - Szerzo Lektor Ellenorzese
    [Documentation]    06 - Szerző-lektor ellenőrzése
    Log To Console    [06/24] Szerző-lektor ellenőrzése
    ${excel_file}=    Get Variable Value    ${CURRENT_EXCEL_FILE}    ${EMPTY}
    ${sheet_name}=    Get Variable Value    ${CURRENT_SHEET_NAME}    ${EMPTY}
    ${testCase_row}=    Set Variable    8
    ${CR}=    Evaluate    chr(13)
    ${err_list}=    Create List
    ${ok}    ${cover}    ${base_err}=    Parse Cover Table
    IF    not ${ok}
        Append To List    ${err_list}    ${base_err}
    ELSE
        # Alias mapping: ha a dokumentumban alternatív kulcsnevek szerepelnek
        ${aliases}=    Create Dictionary    Kéziratíró=Kéziratíró|Szerző|Kézirat író    Szakmai lektor=Szakmai lektor|Lektor
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
        # Eredeti + normalizált összeolvasztás – ne írjuk felül a létező main kulcsot ha már megvan
        FOR    ${k}    ${v}    IN    &{normalized}
            ${already}=    Run Keyword And Return Status    Dictionary Should Contain Key    ${cover}    ${k}
            IF    not ${already}
                Set To Dictionary    ${cover}    ${k}=${v}
            END
        END
        # Két kulcs ellenőrzése: létezés + nem üres + nem egyezhetnek teljesen
        @{fields}=    Create List    Kéziratíró    Szakmai lektor
        FOR    ${f}    IN    @{fields}
            ${present}=    Run Keyword And Return Status    Dictionary Should Contain Key    ${cover}    ${f}
            IF    not ${present}
                Append To List    ${err_list}    A ${f} mező nem létezik a címlapon!
            ELSE
                ${val}=    Get From Dictionary    ${cover}    ${f}
                ${is_blank}=    Run Keyword And Return Status    Should Be True    '${val.strip()}' == '' or '${val.strip()}' == '#'
                IF    ${is_blank}
                    Append To List    ${err_list}    A ${f} mező üres!
                END
            END
        END
        # Csak akkor hasonlítunk, ha mindkettő kulcs létezik
        ${both}=    Run Keyword And Return Status    Evaluate    'Kéziratíró' in ${cover} and 'Szakmai lektor' in ${cover}
        IF    ${both}
            ${writer}=    Get From Dictionary    ${cover}    Kéziratíró
            ${lector}=    Get From Dictionary    ${cover}    Szakmai lektor
            # Lista bontás vessző szerint
            ${w_list}=    Split String    ${writer}    ,
            ${l_list}=    Split String    ${lector}    ,
            # Normalizált összehasonlítás: trim + case-sensitive maradhat
            FOR    ${w}    IN    @{w_list}
                ${w}=    Strip String    ${w}
                FOR    ${l}    IN    @{l_list}
                    ${l}=    Strip String    ${l}
                    IF    '${w}' != '' and '${w}' == '${l}'
                        Append To List    ${err_list}    A Kéziratíró és a Szakmai lektor nem lehet azonos! (${w})
                        Exit For Loop
                    END
                END
            END
        END
    END
    ${unique}=    Remove Duplicates    ${err_list}
    ${err_msg}=    Catenate    SEPARATOR=${CR}    @{unique}
    Mark Test Status    ${excel_file}    ${sheet_name}    ${testCase_row}    ${err_msg}

# Eltávolítva: korábbi szerteágazó ellenőrző keyword (helyette egységes logika a fenti blokkban)
