*** Settings ***
Resource    resources/keywords.robot
Resource    resources/variables.robot
Resource    resources/IKK02-Kurzusaim-bejarasa.robot
Resource    resources/IKK03-Kurzus-ellenorzo.robot
Resource    PLG-05-WEB-ellenor-main.robot
Library     String
Library     BuiltIn
Library     Collections
Library     OperatingSystem
Library     Process
Library    libraries/keep_awake.py
# Removed SeleniumLibrary and RPA.RobotLogListener to avoid missing module errors

Suite Setup    Prevent Sleep
Suite Teardown    Allow Sleep
Test Teardown    Update Test Counters

*** Variables ***

*** Test Cases ***

Batch inicializálás
    [Documentation]    Dokumentum feldolgozás inicializálása
    ${start_time}=    Get Time    epoch
    Set Global Variable    ${BATCH_START_TIME}    ${start_time}

    # Globális log fájl inicializálása (a gyökérben)
    Initialize Global Log File

    # Teszt számlálók nullázása
   Initialize Test Counters

    # Formálellenőrzés számlálók nullázása
    Initialize Check Counters

    # Konfiguracio betöltése minden futás elején
    Konfiguráció Betöltése

    # Log fájl áthelyezése az output mappába
    Move Log File To Output Folder


    # DOCX fájlok keresése és globális változók beállítása
    Log String To Console    ===Initialize DOCX Files List ===
    Initialize DOCX Files List
    
    # *RRF221_tema.kezirata.docx létezés ellenőrzés 


    # DOC kiterjesztésű fájlok keresése és listázása
    Initialize DOC Files List

    # Recovery fájl csak akkor jön létre, ha még nem létezik
    ${recovery_exists}=    Run Keyword And Return Status    File Should Exist    ${CONFIG_OUTPUT_FOLDER}${/}_Recovery.csv
    IF    not ${recovery_exists}
      Create File    ${CONFIG_OUTPUT_FOLDER}${/}_Recovery.csv    encoding=UTF-8
    END

Összes DOC fájl keresése
    Log String To Console    \n=== ÖSSZES DOC FELDOLGOZÁSA ===
    Initialize DOC Files List
    
Összes DOCX feldolgozása
    [Documentation]    Minden talált DOCX dokumentum feldolgozása formálellenőrzéssel
    @{docx_files}=    Set Variable    ${BATCH_DOCX_FILES}
    ${file_count}=    Get Length    ${docx_files}
      #selenium-screenshot törlése selenium-screenshot*.png fájlok törlése
    ${SELENIUM_SCREENSHOT_FILE}=    Set Variable    selenium-screenshot*.png
    Run Keyword And Ignore Error    Remove File    ${SELENIUM_SCREENSHOT_FILE}
    
    Log String To Console    \n=== ÖSSZES DOCX FELDOLGOZÁSA ===
    Log String To Console    Talált fájlok száma: ${file_count}
    
    FOR    ${index}    IN RANGE    ${file_count}
        ${docx_file}=    Get From List    ${docx_files}    ${index}
        ${file_number}=    Evaluate    ${index} + 1
        
        #Recovery ellenőrzés: ha a _Recovery.csv fájl  tartalmazza a  ${docx_files} szöveget, akkor kihagyjuk
        ${recovery_file}=    Set Variable    ${CONFIG_OUTPUT_FOLDER}${/}_Recovery.csv
        ${is_in_recovery}=    Should Contain File    ${recovery_file}    ${docx_file}
        ${is_in_recovery_type}=    Evaluate    type(${is_in_recovery}).__name__
        IF    ${is_in_recovery}==${True}
          Log String To Console    [RECOVERY]  ${docx_file} 
          CONTINUE
        END

        # Fájl név kinyerése az elnevezéshez
        ${file_parts}=    Split String    ${docx_file}    ${/}
        ${file_parts_len}=    Get Length    ${file_parts}
        ${file_name}=    Get From List    ${file_parts}    -1
        ${docx_file_fixed}=    Replace String    ${docx_file}    \\    /
        # A warning elkerülésére: minden backslash /-re cserélve, így nem lesz invalid escape sequence
        ${CURRENT_DIR}=    Evaluate    __import__('os').path.dirname('${docx_file_fixed}')    modules=os
        
    
        #Log String To Console    \n>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
        Log String To Console    >>> FELDOLGOZÁS: (${file_number}/${file_count}) ${docx_file}
        IF    '${docx_file}' != '' and 'docx.docx' in '${docx_file}'
          ${docx_file_fixed}=    Replace String    ${docx_file}    \\    /
          # A warning elkerülésére: minden backslash /-re cserélve
          ${new_file_name}=    Replace String    ${docx_file_fixed}    .docx.docx    .docx
          Move File    ${docx_file_fixed}    ${new_file_name}
          Log String To Console    Átnevezve: ${docx_file_fixed} -> ${new_file_name}
          ${docx_file}=    Set Variable    ${new_file_name}
        END
        # Verzió ellenőrzés: ellenőrzi, hogy az aktuális könyvtárban van-e azonos fájlnévvel 
        # --- Verziókezelő blokk: csak a legnagyobb verzió marad, a többit átnevezi ---
       # az only_file_name változó a docx_file-ból csak a fájl nevet tartalmazza kiterjesztés nélkül
        ${only_file_name}=    Get File Name Base    ${docx_file}
        ${orig_file_name}=    Set Variable    ${docx_file}
        ${new_name}=    Set Variable    ${docx_file}
        
       #Log String To Console    >>> VERZIÓ ELLENŐRZÉS only_file_name >>> ${only_file_name}
        # a ${docx_file} -ból csak az útvonal rész kerül az only_path változóba
        ${only_path}=    Get File Directory    ${docx_file}

       #Log String To Console    >>> VERZIÓ ELLENŐRZÉS only_path >>> ${only_path}    
       # Ha a ${only_file_name} neve nem tartalmazza a \\.v(\\d+)\\.docx$" számozást, akkor átnevezzük átnevezzük v0-ra
        ${has_version}=    Run Keyword And Return Status    Should Match Regexp    ${only_file_name}    \\.v\\d+\\.
        IF    not ${has_version}
            ${new_name}=    Set Variable    ${only_file_name}.v0.docx
            Move File    ${only_path}/${only_file_name}.docx    ${only_path}/${new_name}
           #Log String To Console    Átnevezve (v0 hozzáadva): ${only_file_name}.docx -> ${new_name}
           
        END

        ${verzio_pattern}=    Set Variable    ${only_file_name}.v*.docx
        ${verzio_files}=    List Files In Directory    ${CURRENT_DIR}    pattern=${verzio_pattern}
      #Log String To Console    >>> VERZIÓ verzio_pattern >> ${verzio_pattern}
     #Log String To Console    >>> VERZIÓ ELLENŐRZÉS verzio_files >>> ${verzio_files}
   
        ${verzio_list}=    Create List
        FOR    ${vf}    IN    @{verzio_files}
            ${verzio_num}=    Evaluate    int(re.search(r"\\.v(\\d+)\\.docx$", r'''${vf}''').group(1))    modules=re
            Append To List    ${verzio_list}    ${verzio_num}
          #Log String To Console    >>> VERZIÓ LIST >>> ${verzio_num}
       
        END
        ${max_verzio}=    Set Variable    0
        IF    ${verzio_list}
            ${max_verzio}=    Evaluate    max(${verzio_list})
          #Log String To Console    >>> MAX >>> ${max_verzio}
            
        END
        FOR    ${vf}    IN    @{verzio_files}
             #Log String To Console    >>> vf >>> ${vf}
            ${verzio_num}=    Evaluate    int(re.search(r"\\.v(\\d+)\\.docx$", r'''${vf}''').group(1))    modules=re
            IF    ${verzio_num} != ${max_verzio}
                Move File    ${only_path}/${vf}    ${only_path}/${vf}_old
                #Log String To Console    Átnevezve (régi verzió): ${vf} -> ${vf}_old
            END
        END
        # ha van a fájlnévben .v0.docx akkor átnevezzük a fájlt a verzió nélkülire
        ${has_v0}=    Run Keyword And Return Status    Should Match Regexp    ${new_name}    \\.v0\\.docx$
        IF    ${has_v0} and ${max_verzio} == 0
            Move File    ${only_path}/${new_name}   ${docx_file}
            #Log String To Console    Átnevezve (v0 eltávolítva): ${new_name} -> ${docx_file}
        END
        Log String To Console    >>>>>>>>>>>>>>>>>>>>>>>>>>>>FÁJLNÉV ELLENŐRZÉS: ${file_name}\n
  
        #${name_ok}=    Run Keyword And Return Status    Should Contain    ${file_name}    RRF221_tema_kezirata.docx
        ${name_ok}=    Run Keyword And Return Status    Should Contain    ${file_name}    RRF221_tema_kezirat
        IF    not ${name_ok}
            ${is_fogalomtar1}=    Run Keyword And Return Status    Should Contain    ${file_name}    fogalomtar
            ${is_fogalomtar2}=    Run Keyword And Return Status    Should Contain    ${file_name}    fogalomtár
            ${is_kompetencia}=    Run Keyword And Return Status    Should Contain    ${file_name}    kompetencia
            IF     $is_fogalomtar1 or $is_fogalomtar2 or $is_kompetencia
              Log String To Console    [SKIP] Fájl kihagyva (fogalomtár/kompetencia): ${file_name} 
              #
              #bejegyzés a recovery fájlba
              #
              ${recovery_file}=    Set Variable    ${CONFIG_OUTPUT_FOLDER}${/}_Recovery.csv
              #Log String To Console    Recovery file: ${recovery_file}
              Append To File    ${recovery_file}    ${docx_file}\n   
              CONTINUE
            END
            #tema_kezirat név hibás
            Log String To Console    [SKIP] Fájl kihagyva (név nem egyezik): ${file_name} 
            Write SumError fájl    ${EMPTY}    ${EMPTY}    tc-0    Fájlnév nem tartalmazza az RRF221_tema_kezirat szöveget;${file_name}
            CONTINUE
        END

        Process Single DOCX File As Test Case    ${docx_file}    ${file_number}    ${file_count}    Formálellenőrzés - ${file_name}
        Log String To Console    <<<  BEFEJEZVE: ${docx_file}
        
        #WEB-es ellenőrzés indítása
        IF    ${RUN_WEB_CHECK}==${True}
          Log String To Console    \n---------------------------------------WEB---------------------------------------------\n
          PLG-05-WEB-ellenor-main.Web-alkalmazás indítása és bejelentkezés
        END

       #selenium-screenshot törlése selenium-screenshot*.png fájlok törlése
       ${SELENIUM_SCREENSHOT_FILE}=    Set Variable    selenium-screenshot*.png
      Run Keyword And Ignore Error    Remove File    ${SELENIUM_SCREENSHOT_FILE}
      #
      #bejegyzés a recovery fájlba
      #
        ${recovery_file}=    Set Variable    ${CONFIG_OUTPUT_FOLDER}${/}_Recovery.csv
        Log String To Console    Recovery file: ${recovery_file}
        #írd ki a pontos időt a recovery fájlba
        ${current_time}=    Get Time    result_format=%Y-%m-%d %H:%M:%S
        Append To File    ${recovery_file}    ${docx_file};${current_time}\n    
   END

Batch lezárás
    [Documentation]    Batch feldolgozás lezárása: eredmények összesítése
    
    # Eredmények automatikus ellenőrzése
    Log String To Console    EREDMÉNYEK ELEMZÉSE INDUL...
    Log String To Console    \n════════════════════════════════════════════════════════════════
    # Redundancia Eredmények Ellenőrzése eltávolítva (adatbázis kezelés végleg letiltva)

    # Feldolgozott dokumentumok számának és futásidőnek kiírása
    ${file_count}=    Get Variable Value    ${BATCH_FILE_COUNT}    0
    ${start_time}=    Get Variable Value    ${BATCH_START_TIME}    ${EMPTY}
    ${end_time}=    Get Time    epoch
    ${elapsed}=    Evaluate    int(${end_time} - ${start_time})
    ${hours}=    Evaluate    ${elapsed} // 3600
    ${minutes}=    Evaluate    (${elapsed} % 3600) // 60
    ${seconds}=    Evaluate    ${elapsed} % 60

    
    Log String To Console    \nTELJES FELDOLGOZÁS KÉSZ!
    Log String To Console    \n════════════════════════════════
    Log String To Console    \nFeldolgozott dokumentumok száma: ${file_count}
    Log String To Console    \nFutás teljes ideje: ${hours} óra ${minutes} perc ${seconds} másodperc

    # Dinamikus (valós) összesítés a saját logba (Robot TC-k és 23-as ellenőrzések)
    ${TC_TOTAL}=    Get Variable Value    ${TC_TOTAL}    0
    ${TC_PASSED}=   Get Variable Value    ${TC_PASSED}   0
    ${TC_FAILED}=   Get Variable Value    ${TC_FAILED}   0
    ${CHECK_TOTAL}=    Get Variable Value    ${CHECK_TOTAL}    0
    ${CHECK_PASSED}=   Get Variable Value    ${CHECK_PASSED}   0
    ${CHECK_FAILED}=   Get Variable Value    ${CHECK_FAILED}   0
    Log String To Console    \nROBOT ÖSSZESÍTÉS
    Log String To Console    Robot testcases: ${TC_TOTAL} tests, ${TC_PASSED} passed, ${TC_FAILED} failed
    Log String To Console    Formálellenőrzések: ${CHECK_TOTAL} tests, ${CHECK_PASSED} passed, ${CHECK_FAILED} failed