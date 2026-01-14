*** Settings ***
Library     Collections
Resource    ${CURDIR}/../keywords.robot
Resource    ${CURDIR}/../../PLG-02-Excel-kitolto.robot
*** Keywords ***
Test Case 22 - Cimlap Tartalom Ellenorzese
    [Documentation]    22 - Címlap tartalom ellenőrzése
    Log String To Console    [22/24] Címlap tartalom ellenőrzése
    ${excel_file}=    Get Variable Value    ${CURRENT_EXCEL_FILE}    ${EMPTY}
    ${sheet_name}=    Get Variable Value    ${CURRENT_SHEET_NAME}    ${EMPTY}
    ${testCase_row}=    Set Variable    24
    ${CR}=    Set Variable    ;
    ${err_list}=    Create List

   ${read_status}    ${xmlAllText}=    Run Keyword And Ignore Error    Read Docx All as XML    ${docx_file}
   # az xmlAllTextben szerepel-e a Kéziratíró,Szerző,Kézirat író,keziratíró,keziratiro,szerzo szavak egyike
   
    IF    $read_status == 'FAIL'
        Append To List    ${err_list}    Olvasási hiba a dokumentumban: ${docx_file}
        #Kilép a kulcsszó végrehajtásából, mivel nem sikerült beolvasni a fájlt
        ${unique_errs}=    Remove Duplicates    ${err_list}
        ${err_msg}=    Catenate    SEPARATOR=\n    @{unique_errs}
        Mark Test Status    ${excel_file}    ${sheet_name}    ${testCase_row}    ${err_msg}
        RETURN
    END
    #alakítsa csupa kisbetűsre az xmlAllText változót
    ${xmlAllText}=    Convert To Lower Case    ${xmlAllText}


    # Ellenőrizze, hogy az xmlAllText tartalmazza-e a szerző/kéziratíró szavak valamelyikét
    ${author_keywords}=    Create List    kéziratíró    szerző    kézirat író    keziratíró    keziratiro    szerzo     fordító     eredeti könyv szerzője
    ${found_author}=    Set Variable    False
    FOR    ${kw}    IN    @{author_keywords}
        ${found}=    Run Keyword And Return Status    Should Contain    ${xmlAllText}    ${kw}
        IF    ${found}
            ${found_author}=    Set Variable    True
            Exit For Loop
        END
    END
    IF    not ${found_author}
        Append To List    ${err_list}    Az xmlAllText nem tartalmazza a szerző/kéziratíró szavak egyikét sem!
    END

    # Ellenőrizze, hogy az xmlAllText tartalmazza-e a Szakmai lektor szót
    ${found_lektor}=    Run Keyword And Return Status    Should Contain    ${xmlAllText}    szakmai lektor
    IF    not ${found_lektor}
        Append To List    ${err_list}    Az xmlAllText nem tartalmazza a Szakmai lektor szót!
    END
    #Ellenőrizze,hogy az xmlAllText tartalmazza-e a iskolai felhasználási cé szót
    ${found_iskolai}=    Run Keyword And Return Status    Should Contain    ${xmlAllText}    iskolai felhasználási cél
    IF    not ${found_iskolai}
        Append To List    ${err_list}    A címlap nem tartalmazza az iskolai felhasználási cél szót!
    END

    ${unique_errs}=    Remove Duplicates    ${err_list}
    ${err_msg}=    Catenate    SEPARATOR=\n    @{unique_errs}
    Log String To Console   Címlap hiba[${err_msg}]

    Mark Test Status    ${excel_file}    ${sheet_name}    ${testCase_row}    ${err_msg}
