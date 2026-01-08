*** Keywords ***
Should Contain File
    [Arguments]    ${file_path}    ${search_string}
    #logolja a bemeneti paramétereket
    #Log String To Console    [DEBUG] Should Contain File hívva: ${file_path} | Keresett string: ${search_string}
    ${exists}=    Run Keyword And Return Status    File Should Exist    ${file_path}
    IF    not ${exists}
        #Log String To Console    [HIBA] _Recovery Fájl nem létezik: ${file_path} | Keresett string: ${search_string} | Visszatér: False
        #Log String To Console    [DEBUG] RETURN (nem létezik): False (type=${type(False).__name__})
        RETURN    False
    END
    ${content}=    Get File    ${file_path}
    #ird ki a konzolra a fájl tartalmát
    #Log String To Console    -------------------------[DEBUG] Fájl tartalma:\n${content}
    ${lines}=    Split To Lines    ${content}
    #Log String To Console    -------------------------
    
    # Ha a fájl üres, azonnal térjünk vissza False-szal
    ${lines_count}=    Get Length    ${lines}
   
    IF    ${lines_count} == 0
        #Log String To Console    [HIBA] _Recovery Fájl üres vagy 0 bájt: ${file_path} | Keresett string: ${search_string} | Visszatér: False
        #Log String To Console    [DEBUG] RETURN (üres): False (type=${type(False).__name__})
        RETURN    False
    END
     #ird ki a konzolra a sorok számát
    #Log String To Console    !!!!!!!!!!!!!!!!!!!! [DEBUG] Sorok száma a _Recovery fájlban: ${lines_count}
    # Normalizáljuk a keresett stringet: \\ -> /, strip
    ${search_norm}=    Replace String    ${search_string}    \\    /
    ${search_norm}=    Strip String    ${search_norm}
     #Log String To Console    [DEBUG1] Keresett: "${search_norm}"
    ${found}=    Set Variable    ${False}
    FOR    ${line}    IN    @{lines}
        ${line_norm}=    Replace String    ${line}    \\    /
        ${line_norm}=    Strip String    ${line_norm}

        #ird ki a konzolra a normalizált sort és a keresett stringet
        #Log String To Console    [DEBUG] Ellenőrzött sor: "${line_norm}" 
        IF    '${line_norm}' == '${search_norm}'
        #ird ki hogy megtaláltam
            #Log String To Console    [DEBUG] Találat a _Recovery fájlban: ${line_norm}
            ${found}=    Set Variable    ${True}
            Exit For Loop
        END
    END
    #Log String To Console    [DEBUG] Should Contain File: ${file_path} | Keresett: ${search_string} | Találat: ${found}
    ${result}=    Evaluate    bool(${found})
    #Log String To Console    [DEBUG] RETURN (találat): ${result} (type=${type(${result}).__name__})
    RETURN    ${result}

*** Settings ***
Library    ../libraries/DocxReader.py
Library    ../libraries/find_docx.py
Library    BuiltIn
Library    DateTime
Library    Process
Library    OperatingSystem
Library    String
Library    Collections
Library    SeleniumLibrary
Resource   variables.robot
Resource   get_file_size.resource
# MEGJEGYZÉS: Legacy resource hivatkozások eltávolítva, mivel ezeket a fájlokat archivláltuk
Resource   testcases/tc_01_arculati.robot
Resource   testcases/tc_02_kompetencia.robot
Resource   testcases/tc_03_fogalomtar.robot
Resource   testcases/tc_04_szerkesztoi.robot
Resource   testcases/tc_05_internet.robot
Resource   testcases/tc_06_szerzo_lektor.robot
Resource   testcases/tc_07_hosszu_idezetek.robot
Resource   testcases/tc_08_tordeles.robot
Resource   testcases/tc_09_abrak_fotok.robot
Resource   testcases/tc_10_felsorolas.robot
Resource   testcases/tc_11_ures_negyzetek.robot
Resource   testcases/tc_12_magyar_nyelven_keszult.robot
Resource   testcases/tc_13_bekezdesek_elkulonulnek.robot
Resource   testcases/tc_14_felsorolasok_egysegesek.robot
Resource   testcases/tc_15_mozaikaszvak.robot
Resource   testcases/tc_16_ldezetek.robot
Resource   testcases/tc_17_idezetek_forrasmegjelolese.robot
Resource   testcases/tc_18_kompetencia_teszt_megoldokulcs.robot
Resource   testcases/tc_19_idegen_nyelvu_illusztraciok.robot
Resource   testcases/tc_20_lapjai_szamozottak.robot
Resource   testcases/tc_21_szerkesztheto_docx_formatum.robot
Resource   testcases/tc_22_cimlap_tartalom.robot
Resource   testcases/tc_23_generalt_tartalomjegyzek.robot
Resource   testcases/tc_24_cimsorozas.robot

*** Variables ***
${DOCX_DUMP_TO_FILE}    ${False}
${DOCX_DUMP_DIR}        ${EXECDIR}${/}results${/}docx_dump

*** Keywords ***

Popup Handler
    [Documentation]    Kezeli a felugró ablakokat
    Log String To Console    \nPopupHandler : Handler elindult

    TRY
        # Material dialog várakozás (helyes XPath)
        #Log String To Console    PopupHandler : Wait until visible ScormContent Start.
        #Wait Until Element Is Visible    id=ScormContent    10s
        # Log String To Console    PopupHandler : Wait until visible Done.
        #Select Frame    id=ScormContent
        # Log String To Console    PopupHandler : ScormContent Selected .
        Run Keyword And Ignore Error      Wait Until Element Is Visible   xpath=//*[self::button or self::a or self::input][@aria-label='Teszt folytatása' or @aria-label='Folytatás']   1s
        ${exists}=    Run Keyword And Return Status     Page Should Contain Element    xpath=//button[@aria-label='Teszt folytatása' or @aria-label='Folytatás'] 20s
         Log String To Console    PopupHandler : exists: ${exists}
       
       IF    ${exists}
        Click Element    xpath=//*[self::button or self::a or self::input][@aria-label='Teszt folytatása' or @aria-label='Folytatás']
        Log String To Console    PopupHandler : Van felugró ablak megjelenítve. Megnyomva.
       ELSE
           Log String To Console    PopupHandler : Nincs felugró ablak megjelenítve. Folytatás.
       END 
    EXCEPT    message
        Log String To Console    PopupHandler-exception : Nincs felugró ablak megjelenítve. Folytatás.
    END
   
    # Várakozás a ScormContent frame-re is (ha szükséges)
    #Run Keyword And Ignore Error    Wait Until Element Is Visible    id=ScormContent    10s
   
   
    #Wait Until Element Is Visible    id=ScormContent    10s
    #Select Frame    id=ScormContent

    # Ha megjelenik a folytatás javaslat ablak, kattints a "Folytatás" gombra
    #${exists}=    Run Keyword And Return Status    Page Should Contain Element    xpath=//*[self::button or self::a or self::input][contains(., 'Folytatás') or @value='Folytatás' or @aria-label='Folytatás']    5s
    #IF    ${exists}
    #    Log String To Console    Popup Handler: Van "Folytatás" gomb az oldalon.
    #    Wait Until Element Is Visible    //*[self::button or self::a or self::input][contains(., 'Folytatás') or @value='Folytatás' or @aria-label='Folytatás']    1s
    #    Click Element    xpath=//*[self::button or self::a or self::input][contains(., 'Folytatás') or @value='Folytatás' or @aria-label='Folytatás']
    #    Wait Until Element Is Not Visible    //*[self::button or self::a or self::input][contains(., 'Folytatás') or @value='Folytatás' or @aria-label='Folytatás']    1s
    #END
    #felugró teszt folytatása gomb kezelése
    #${exists}=    Run Keyword And Return Status    Page Should Contain Element    xpath=//*[self::button or self::a or self::input][contains(., 'Teszt folytatása') or @value='Teszt folytatása' or @aria-label='Teszt folytatása']    5s
    #IF    ${exists}
    #    Log String To Console    Popup Handler: Van "Teszt folytatása" gomb az oldalon.
    #    Run Keyword And Ignore Error    Wait Until Element Is Visible    xpath=//*[self::button or self::a or self::input][contains(., 'Teszt folytatása') or @value='Teszt folytatása' or @aria-label='Teszt folytatása']    1s
    #    Click Element    xpath=//*[self::button or self::a or self::input][contains(., 'Teszt folytatása') or @value='Teszt folytatása' or @aria-label='Teszt folytatása']
    #    Wait Until Element Is Not Visible    xpath=//*[self::button or self::a or self::input][contains(., 'Teszt folytatása') or @value='Teszt folytatása' or @aria-label='Teszt folytatása']    1s
    #    Log String To Console    Popup Handler: Megnyomva a  "Teszt folytatása" gomb az oldalon.
    #ELSE
    #    Log String To Console    Popup Handler: Nincs "Teszt folytatása" gomb az oldalon.
    #END
    Log String To Console    Popup Handler befejeződött



Write Tartalomjegyzék To CSV
    [Arguments]    ${CURRENT_SHEET_NAME}    ${headLevel}   ${text}  
    #Log String To Console    [DEBUG] Write Tartalomjegyzék To CSV hívva:\n ${CURRENT_SHEET_NAME} | ${headLevel} | ${text} 

     ${csv_file}=    Set Variable    ${CONFIG_OUTPUT_FOLDER}/${CURRENT_SHEET_NAME}_Tartalomjegyzék.csv 
     ${exists}=    Run Keyword And Return Status    File Should Exist    ${csv_file}    
     ${header}=    Set Variable    Level;Cím
     #ird ki a kapott adatokat a konzolra
     #Log String To Console    [TARTALOM] Tartalomjegyzék CSV fájl: ${csv_file} | Cím: ${text}

    IF    not ${exists}
         # BOM hozzáadása a fájl elejére
         ${bom}=    Evaluate    '\ufeff'  
        Create File    ${csv_file}    ${bom}${header}\n    encoding=UTF-8
    END
    Append To File    ${csv_file}    ${headLevel};${text}\n
   
Write Menu To CSV
    [Arguments]    ${CURRENT_SHEET_NAME}    ${highlighted_name}   ${level1_name}   ${level2_name}   ${level3_name}
    #Log String To Console    [DEBUG] Write Menu To CSV hívva:\n ${CURRENT_SHEET_NAME} | ${highlighted_name} | ${level1_name} | ${level2_name} | ${level3_name}    

     ${csv_file}=    Set Variable    ${CONFIG_OUTPUT_FOLDER}/${CURRENT_SHEET_NAME}_Menu.csv 
     ${exists}=    Run Keyword And Return Status    File Should Exist    ${csv_file}    
     ${header}=    Set Variable    Menü név;1. szintű téma;2. szintű téma;3. szintű téma
     #ird ki a kapott adatokat a konzolra
     #Log String To Console    [MENU] Menü CSV fájl: ${csv_file} | Menü név: ${highlighted_name}

    IF    not ${exists}
         # BOM hozzáadása a fájl elejére
         ${bom}=    Evaluate    '\ufeff'  
        Create File    ${csv_file}    ${bom}${header}\n    encoding=UTF-8
    END
    Append To File    ${csv_file}    ${highlighted_name};${level1_name};${level2_name};${level3_name}\n
   
Write SumError fájl
    [Arguments]    ${parent}    ${child}    ${testcase}    ${error}    ${filename}
    #Log String To Console    [DEBUG] CONFIG_OUTPUT_FOLDER value: ${CONFIG_OUTPUT_FOLDER}
    ${csv_file}=    Set Variable    ${CONFIG_OUTPUT_FOLDER}/_SumError.csv
    ${header}=    Set Variable    Parent;Child;TestCase;Error;Filename
    ${row}=    Set Variable    ${parent};${child};${testcase};${error};${filename}
    #Log String To Console    [DEBUG] SumError.csv path: ${csv_file}
    #Log String To Console    [DEBUG] SumError.csv row: ${row}
    ${exists}=    Run Keyword And Return Status    File Should Exist    ${csv_file}
    IF    not ${exists}
        Create File    ${csv_file}    ${header}\n    encoding=UTF-8
        # BOM hozzáadása a fájl elejére
        ${bom}=    Evaluate    '\ufeff'
        ${old_content}=    Get File    ${csv_file}
        Create File    ${csv_file}    ${bom}${old_content}    encoding=UTF-8
    END
    Append To File    ${csv_file}    ${row}\n
Initialize DOC Files List
    [Documentation]    Megkeresi a DOCUMENT_PATH-ban rekurzívan az összes .DOC vagy .doc kiterjesztésű fájlt, és ha talál, akkor _Hibás kiterjesztés.csv fájlba sorolja őket.
    ${doc_files}=    Find Doc Files Recursively    ${DOCUMENT_PATH}
    ${doc_count}=    Get Length    ${doc_files}
    Log String To Console    Talált .DOC fájlok száma: ${doc_count}
    ${doc_files_lower}=    Create List    # már minden .doc és .DOC benne van az előző listában
        ${all_doc_files}=    Create List
        FOR    ${f}    IN    @{doc_files}
            Append To List    ${all_doc_files}    ${f}
        END
        FOR    ${f}    IN    @{doc_files_lower}
            Append To List    ${all_doc_files}    ${f}
        END
        ${file_count}=    Get Length    ${all_doc_files}
        Run Keyword If    ${file_count} > 0    Write Hibás Kiterjesztés CSV    ${all_doc_files}

Write Hibás Kiterjesztés CSV
    [Arguments]    ${file_list}
    ${csv_file}=    Set Variable    ${CONFIG_OUTPUT_FOLDER}/_Hibás kiterjesztés.csv
   Log String To Console    Hibás kiterjesztésű fájlok listázása CSV-be: ${csv_file}    
   
    ${bom}=    Evaluate    '\ufeff'
    Create File    ${csv_file}    ${bom}Fájlok hibás kiterjesztéssel (DOC):\n    encoding=UTF-8
    # egy ${doc_file_list} -be ;-vel elválasztva sorolja fel a file_list elemeit
    ${doc_file_list}=    Catenate    SEPARATOR=;    @{file_list}
    FOR    ${f}    IN    @{file_list}
        Append To File    ${csv_file}    ${f}\n
    END
    #irja be a sumerror.csv fájlba is
    # parent értéke
    #${parent}=    Get Variable Value    ${DOCUMENT_PATH}    ${EMPTY}
    #${child}=    Get Variable Value    ${CURRENT_FILENAME_PART}    ${EMPTY}
    #Write SumError fájl    ${parent}    ${EMPTY}   Hibás_kiterjesztés    Talált hibás kiterjesztésű fájlokat (.DOC)    ${doc_file_list}

## (Üres Get RUN_WEB_CHECK From Config törölve, implementáció lentebb megtalálható)
Get RUN_WEB_CHECK From Config
    [Documentation]    Config fájlból web_check_enabled érték kiolvasása logikai típusként
    ${config_content}=    Get File    ${CURDIR}/../IKK.config
    @{config_lines}=    Split To Lines    ${config_content}
    FOR    ${line}    IN    @{config_lines}
        ${line_trimmed}=    Strip String    ${line}
        ${is_web_check}=    Run Keyword And Return Status    Should Start With    ${line_trimmed}    web_check_enabled=
        IF    ${is_web_check}
            ${web_check_value}=    Replace String    ${line_trimmed}    web_check_enabled=    ${EMPTY}
            ${web_check_value_lower}=    Convert To Lowercase    ${web_check_value}
            ${is_enabled}=    Run Keyword And Return Status    Evaluate    '${web_check_value_lower}' in ['1', 'true', 'yes', 'igen']
            Log String To Console    Config-ból beolvasott web_check_enabled: ${web_check_value} (${is_enabled})
            IF    '${web_check_value_lower}' in ['0', 'false', 'no', 'nem']
                RETURN    ${False}
            END
            RETURN    ${is_enabled}
        END
    END
    # Ha nem találjuk, alapértelmezett érték: False

Log String To Console
    [Arguments]    @{msgs}
    [Documentation]    Logs message both to console and to timestamped log file
    ${msg}=    Catenate    SEPARATOR=     @{msgs}
    Log To Console    ${msg}
    ${is_trace}=    Run Keyword And Return Status    Should Contain    ${msg}    [TRACE]
    IF    ${is_trace}
        Return From Keyword
    END
    ${log_filename_exists}=    Run Keyword And Return Status    Variable Should Exist    ${GLOBAL_LOG_FILENAME}
    IF    ${log_filename_exists}
        Append To File    ${GLOBAL_LOG_FILENAME}    ${msg}\n
    END


Beállítom a RUN_WEB_CHECK-et konfigból
    ${val}=    Evaluate    __import__('libraries.duplikacio_config').DuplikacioConfig().is_web_check_enabled()    modules=libraries.duplikacio_config
    Set Suite Variable    ${RUN_WEB_CHECK}    ${val}

Mark Test Status
    [Documentation]    Általános jelölő: hibánál F{row} megjegyzés, D{row} "X" és FAIL; siker esetén C{row} "X".
    [Arguments]    ${excel_file}    ${sheet_name}    ${test_row}    ${err_msg}    ${mark}=X
    
    IF    $err_msg != ''
        #Log String To Console    Mark Test Status ${test_row}-ba: ${err_msg}
        Log String To Console    Mark Test Status Failed
        Fill Excel Cell    ${excel_file}    ${sheet_name}    ${test_row}    6    ${err_msg}
         
        IF     int(${test_row}) < 10
            ${row_text}=    Set Variable    0${test_row}
        ELSE
            ${row_text}=    Set Variable    ${test_row}
        END    
        ${error_log_file}=    Replace String    ${excel_file}    .xlsx    (${sheet_name}_${row_text}) hiba.txt   
     
        #Log String To Console    !!!!!!!!!!!!!!!!!!!!${error_log_file}  -> ${err_msg}    
        #hiba fájl írása
        ${err_msg_CR}=      Replace String    ${err_msg}    ;    \n
         Create File    ${error_log_file}    ${err_msg_CR}    encoding=UTF-8
        Log String To Console    Hiba fájl létrehozva: ${error_log_file}

        #sumerror.csv írása
        ${parent}=    Get Variable Value    ${CURRENT_PATH_PART}    ${EMPTY}
        ${child}=    Get Variable Value    ${CURRENT_FILENAME_PART}    ${EMPTY}
        ${testcase}=    Set Variable    TC${row_text}
        Write SumError fájl    ${parent}    ${child}    ${testcase}    ${err_msg}    ${excel_file}
        
        Fill Excel Cell    ${excel_file}    ${sheet_name}    ${test_row}    4    ${mark}
    ELSE
        Log String To Console    Mark Test Status Passed
        Fill Excel Cell    ${excel_file}    ${sheet_name}    ${test_row}    3    ${mark}
    END

Mark WebTest Status
    [Documentation]    Általános jelölő: hibánál C{row} megjegyzés, D{row} "X" és FAIL; siker esetén B{row} "X".
    [Arguments]    ${excel_file}    ${sheet_name}    ${test_row}    ${err_msg}    ${mark}=X
    #Log String To Console    Mark WebTest Status called with err_msg: ${err_msg}
    
    IF    $err_msg != ''
        #Log String To Console    Mark Test Status ${test_row}-ba: ${err_msg}
        #Log String To Console    Mark WebTest Status Failed
        Fill Excel Cell    ${excel_file}    ${sheet_name}    ${test_row}    4    ${err_msg}
         
        IF     int(${test_row}) < 10
            ${row_text}=    Set Variable    0${test_row}
        ELSE
            ${row_text}=    Set Variable    ${test_row}
        END    
        ${error_log_file}=    Replace String    ${excel_file}    .xlsx    (${sheet_name}_${row_text}) hiba.txt    
        #Log String To Console    !!!!!!!!!!!!!!!!!!!!${error_log_file}  -> ${err_msg}    
        #hiba fájl írása
        ${err_msg_CR}=      Replace String    ${err_msg}    ;    \n
         Create File    ${error_log_file}    ${err_msg_CR}    encoding=UTF-8
       
        # Hibás X-elés: D oszlop
        Fill Excel Cell    ${excel_file}    ${sheet_name}    ${test_row}    3    ${mark}
         #felirjuk egy csv.be appendel
          Write SumError fájl    ${excel_file}    ${sheet_name}     wtc-${test_row}   ${err_msg}    ${excel_file}
 
        # Jelöld FAIL-re a tesztet, de folytasd a futást
        Run Keyword And Continue On Failure    Fail    ${err_msg}
        #Log String To Console    !!!!!!!!!!!!!!!!!!!!${error_log_file}  -> ${err_msg}
         Log String To Console    Mark WebTest Status Failed
    ELSE
        # Hibátlan X-elés: C oszlop
        Fill Excel Cell    ${excel_file}    ${sheet_name}    ${test_row}    2    ${mark}
         Write SumError fájl    ${excel_file}    ${sheet_name}    wtc-${test_row}    Passed    ${excel_file}
        Log String To Console    Mark WebTest Status Passed
        END

Initialize Global Log File
    [Documentation]    Inicializálja a globális log fájl nevét a futás elején a gyökérkönyvtárban
    ${current_datetime}=    Get Current Date    result_format=%Y%m%d_%H%M%S
    ${log_filename_only}=    Set Variable    RunLog_${current_datetime}.log
    # Kezdetben a gyökérkönyvtárban hozzuk létre
    Set Global Variable    ${GLOBAL_LOG_FILENAME}    ${log_filename_only}
    Set Global Variable    ${LOG_FILENAME_ONLY}    ${log_filename_only}
    Log String To Console    Globális log fájl inicializálva: ${log_filename_only}

Initialize Test Counters
    [Documentation]    Teszt számlálók nullázása a fő suite elején
    Set Global Variable    ${TC_TOTAL}     0
    Set Global Variable    ${TC_PASSED}    0
    Set Global Variable    ${TC_FAILED}    0

Initialize Check Counters
    [Documentation]    Formálellenőrzési számlálók nullázása a teljes futás elején
    Set Global Variable    ${CHECK_TOTAL}     0
    Set Global Variable    ${CHECK_PASSED}    0
    Set Global Variable    ${CHECK_FAILED}    0

Update Test Counters
    [Documentation]    Növeli a számlálókat az aktuális teszt státusza alapján (Test Teardown-ban hívjuk)
    ${total}=    Get Variable Value    ${TC_TOTAL}     0
    ${passed}=   Get Variable Value    ${TC_PASSED}    0
    ${failed}=   Get Variable Value    ${TC_FAILED}    0
    ${total}=    Evaluate    ${total} + 1
    IF    '${TEST_STATUS}' == 'PASS'
        ${passed}=    Evaluate    ${passed} + 1
    ELSE
        ${failed}=    Evaluate    ${failed} + 1
    END
    Set Global Variable    ${TC_TOTAL}     ${total}
    Set Global Variable    ${TC_PASSED}    ${passed}
    Set Global Variable    ${TC_FAILED}    ${failed}
    #Log String To Console    [TRACE] Teardown: ${TEST_NAME} -> ${TEST_STATUS} (total=${total}, pass=${passed}, fail=${failed})

Update Global Check Counters
    [Documentation]    Hozzáadja a dokumentumonként mért 23-as ellenőrzés számait a globális számlálókhoz
    [Arguments]    ${add_total}    ${add_passed}    ${add_failed}
    ${gt}=    Get Variable Value    ${CHECK_TOTAL}     0
    ${gp}=    Get Variable Value    ${CHECK_PASSED}    0
    ${gf}=    Get Variable Value    ${CHECK_FAILED}    0
    ${gt}=    Evaluate    ${gt} + int(${add_total})
    ${gp}=    Evaluate    ${gp} + int(${add_passed})
    ${gf}=    Evaluate    ${gf} + int(${add_failed})
    Set Global Variable    ${CHECK_TOTAL}     ${gt}
    Set Global Variable    ${CHECK_PASSED}    ${gp}
    Set Global Variable    ${CHECK_FAILED}    ${gf}
    #Log String To Console    [TRACE] Globális ellenőrzés számlálók frissítve: total=${gt}, pass=${gp}, fail=${gf}

Move Log File To Output Folder
    [Documentation]    Áthelyezi a log fájlt az output könyvtárba a konfiguráció betöltése után
    ${output_folder}=    Get Variable Value    ${CONFIG_OUTPUT_FOLDER}    .
    ${log_filename_only}=    Get Variable Value    ${LOG_FILENAME_ONLY}    RunLog_unknown.log
    ${new_log_path}=    Join Path    ${output_folder}    ${log_filename_only}
    
    # Ha létezik a régi log fájl a gyökérben, másoljuk át
    ${old_log_exists}=    Run Keyword And Return Status    File Should Exist    ${GLOBAL_LOG_FILENAME}
    IF    ${old_log_exists} and "${new_log_path}" != "${GLOBAL_LOG_FILENAME}"
        Copy File    ${GLOBAL_LOG_FILENAME}    ${new_log_path}
        Remove File    ${GLOBAL_LOG_FILENAME}
        Set Global Variable    ${GLOBAL_LOG_FILENAME}    ${new_log_path}
        Log String To Console    Log fájl áthelyezve: ${new_log_path}
    ELSE IF    "${new_log_path}" != "${GLOBAL_LOG_FILENAME}"
        Set Global Variable    ${GLOBAL_LOG_FILENAME}    ${new_log_path}
        Log String To Console    Log fájl útvonal frissítve: ${new_log_path}
    END

Format Message With Line Breaks
    [Documentation]    Formázza az üzenetet sortörésekkel: minden 100. karakter után \n, minden 1000. karakter után \n\n
    [Arguments]    ${message}
    ${length}=    Get Length    ${message}
    ${formatted}=    Set Variable    ${EMPTY}
    ${index}=    Set Variable    0
    
    WHILE    ${index} < ${length}
        ${next_index}=    Evaluate    ${index} + 1
        ${char}=    Get Substring    ${message}    ${index}    ${next_index}
        ${formatted}=    Set Variable    ${formatted}${char}
        ${index}=    Evaluate    ${index} + 1
        
        # Minden 1000. karakter után dupla sortörés
        ${is_1000th}=    Evaluate    ${index} % 1000 == 0 and ${index} > 0
        IF    ${is_1000th}
            ${newline}=    Evaluate    chr(10)
            ${formatted}=    Set Variable    ${formatted}${newline}${newline}
        # Minden 100. karakter után sortörés (de nem ha már 1000. volt)
        ELSE
            ${is_100th}=    Evaluate    ${index} % 100 == 0 and ${index} > 0
            IF    ${is_100th}
                ${newline}=    Evaluate    chr(10)
                ${formatted}=    Set Variable    ${formatted}${newline}
            END
        END
    END
    
    RETURN    ${formatted}



Process Config Line
    #Log String To Console    [TRACE] Process Config Line elindult
    [Arguments]    ${config_line}
    # Csak az utolsó sort dolgozzuk fel, ha több soros a bemenet
    ${config_line}=    Get Line    ${config_line}    -1
    @{config_parts}=    Split String    ${config_line}    |
    ${parts_len}=    Get Length    ${config_parts}
    IF    ${parts_len} < 6
        Log String To Console    [HIBA] Konfigurációs sor hibás vagy hiányos: ${config_line}
        RETURN
    END
    ${input_part}=    Get From List    ${config_parts}    0
    ${output_part}=    Get From List    ${config_parts}    1
    ${excel_prefix_part}=    Get From List    ${config_parts}    2
    ${rename_prefix_part}=    Get From List    ${config_parts}    3
    ${threshold_gyanus_part}=    Get From List    ${config_parts}    4
    ${threshold_masolt_part}=    Get From List    ${config_parts}    5
    ${config_input}=    Remove String    ${input_part}    INPUT:
    ${config_output}=    Remove String    ${output_part}    OUTPUT:
    ${config_excel_prefix}=    Remove String    ${excel_prefix_part}    EXCEL_PREFIX:
    ${config_excel_prefix}=    Strip String    ${config_excel_prefix}
    ${config_excel_prefix}=    Remove String    ${config_excel_prefix}    '
    ${config_excel_prefix}=    Remove String    ${config_excel_prefix}    "
    ${config_excel_prefix}=    Remove String    ${config_excel_prefix}    \n
    ${config_rename_prefix}=    Remove String    ${rename_prefix_part}    RENAME_PREFIX:
    ${config_rename_prefix}=    Strip String    ${config_rename_prefix}
    ${config_rename_prefix}=    Remove String    ${config_rename_prefix}    '
    ${config_rename_prefix}=    Remove String    ${config_rename_prefix}    "
    ${config_rename_prefix}=    Remove String    ${config_rename_prefix}    \n
    ${config_threshold_gyanus}=    Remove String    ${threshold_gyanus_part}    THRESHOLD_GYANUS:
    ${config_threshold_masolt}=    Remove String    ${threshold_masolt_part}    THRESHOLD_MASOLT:
    # Globalis valtozok beallitasa
    Set Global Variable    ${CONFIG_INPUT_FOLDER}  ${config_input}
    Set Global Variable    ${CONFIG_OUTPUT_FOLDER}    ${config_output}
    Set Global Variable    ${CONFIG_EXCEL_PREFIX}     ${config_excel_prefix}
    Set Global Variable    ${RENAME_PREFIX}          ${config_rename_prefix}
    Set Global Variable    ${CONFIG_THRESHOLD_GYANUS}    ${config_threshold_gyanus}
    Set Global Variable    ${CONFIG_THRESHOLD_MASOLT}    ${config_threshold_masolt}
    Set Global Variable    ${DOCUMENT_PATH}           ${config_input}
    # Sikeres konfiguráció betöltése
    Log String To Console    Konfiguracio sikeresen betoltve!
    Log String To Console    Bementi konyvtar: ${config_input}
    Log String To Console    Kimeneti konyvtar: ${config_output}
    Log String To Console    Excel prefix: ${config_excel_prefix}


Get Config Icon
    #Log String To Console    [TRACE] Get Config Icon elindult
    [Documentation]    Ikonok tiltva: mindig üres string
    [Arguments]    ${icon_name}
    RETURN    ${EMPTY}
    #Log String To Console    [TRACE] Get Config Icon kilépett

Parse Cover Table
    [Documentation]    Kinyeri az első táblázatot a ${DOCX_JSON} struktúrából és normalizálja a kulcsokat (':' vágás, trim). Visszatér: ${ok} (bool), ${clean_dict} vagy ${EMPTY}, ${err_msg}.
    ${docx_json}=    Get Variable Value    ${DOCX_JSON}    ${EMPTY}
    ${err_msg}=    Set Variable    ${EMPTY}
    ${clean}=    Set Variable    ${EMPTY}
    ${ok}=    Set Variable    ${False}
    ${is_dict}=    Evaluate    isinstance(${docx_json}, dict)
    IF    not ${is_dict}
        ${err_msg}=    Set Variable    DOCX_JSON nem elérhető vagy nem megfelelő típus (${docx_json})
    ELSE
        TRY
            ${tables}=    Get From Dictionary    ${docx_json}    tables
        EXCEPT    AS    ${e}
            ${tables}=    Set Variable    ${EMPTY}
            ${err_msg}=    Set Variable    DOCX_JSON['tables'] nem található (${e})
        END
        IF    '${err_msg}' == ''
            ${is_list}=    Evaluate    isinstance(${tables}, list)
            IF    not ${is_list}
                ${err_msg}=    Set Variable    DOCX_JSON['tables'] nem lista (${tables})
            ELSE
                TRY
                    ${first_table}=    Get From List    ${tables}    0
                    # Alap tisztítás (eredeti kulcsok megtartása)
                    ${clean}=    Evaluate    {k.rstrip(':').strip(): v.strip() for k, v in dict(${first_table}).items()}
                    # Kiterjesztett kulcs normalizáció: kisbetűs, ékezetmentes, többszörös space összevonás + space nélküli variánsok
                    ${orig_keys}=    Get Dictionary Keys    ${clean}
                    FOR    ${__k}    IN    @{orig_keys}
                        ${__v}=    Get From Dictionary    ${clean}    ${__k}
                        ${norm}=    Set Variable    ${__k}
                        ${norm}=    Convert To Lowercase    ${norm}
                        ${norm}=    Replace String    ${norm}    \xa0    ${SPACE}
                        ${norm}=    Replace String    ${norm}    á    a
                        ${norm}=    Replace String    ${norm}    é    e
                        ${norm}=    Replace String    ${norm}    í    i
                        ${norm}=    Replace String    ${norm}    ó    o
                        ${norm}=    Replace String    ${norm}    ö    o
                        ${norm}=    Replace String    ${norm}    ő    o
                        ${norm}=    Replace String    ${norm}    ú    u
                        ${norm}=    Replace String    ${norm}    ü    u
                        ${norm}=    Replace String    ${norm}    ű    u
                        ${norm}=    Replace String Using Regexp    ${norm}    \s+    ${SPACE}
                        ${norm}=    Strip String    ${norm}
                        Set To Dictionary    ${clean}    ${norm}=${__v}
                        ${no_space}=    Replace String    ${norm}    ${SPACE}    ${EMPTY}
                        IF    '${no_space}' != '${norm}'
                            Set To Dictionary    ${clean}    ${no_space}=${__v}
                        END
                    END
                    ${ok}=    Set Variable    ${True}
                EXCEPT    AS    ${e}
                    ${err_msg}=    Set Variable    Címlap táblázat nem feldolgozható (${e})
                END
            END
        END
    END
    RETURN    ${ok}    ${clean}    ${err_msg}


Konfiguráció Betöltése
    ${RUN_WEB_CHECK}=    Get RUN_WEB_CHECK From Config
    Set Suite Variable    ${RUN_WEB_CHECK}    ${RUN_WEB_CHECK}
    #Log String To Console    [TRACE] Konfiguráció Betöltése elindult
    [Documentation]    IKK.config fajl betoltese es beallitasok alkalmazasa
    #Silence Python SyntaxWarnings
    Log String To Console    \nKONFIGURACIO BETOLTESE...
    Log String To Console    ═══════════════════════════════
    # Konfiguracios fajl olvasasa Python scripttel
    ${config_result}=    Run Process    ${PYTHON_EXEC}    ${CURDIR}/../libraries/get_config.py    shell=True    cwd=${CURDIR}/..
    IF    ${config_result.rc} == 0
        ${config_line}=    Set Variable    ${config_result.stdout.strip()}
        IF    $config_line != '' and $config_line != 'None'
            Process Config Line    ${config_line}
        ELSE
            Log String To Console    [HIBA] Üres vagy None config_line, Split String kihagyva!
            Log String To Console    [FIGYELMEZTETÉS] Konfiguráció hiányos; alapértelmezett beállítások lesznek használva
        END
   
        # Input folder beolvasása a config-ból (egyszer a futás elején)
        ${input_folder}=    Get Input Folder From Config
        Set Global Variable    ${INPUT_FOLDER}    ${input_folder}
        
    ELSE
        Fail    Hiba a konfiguracio betoltesekor, alapertelmezettek hasznalata
        Log String To Console    Hiba a konfiguracio betoltesekor, alapertelmezettek hasznalata
        Log String To Console    Hibauzenet: ${config_result.stderr}
    END
    Log String To Console    Futtatja a WEB-es ellenőrzést: ${RUN_WEB_CHECK}
    
    Log String To Console    ${EMPTY}
    Log String To Console    ═══════════KONFIGURACIO BETOLTESE KÉSZ════════════════════
    #Log String To Console     \n\[TRACE] Konfiguráció Betöltése kilépett


Get File Directory
        [Documentation]    Visszaadja a fájl elérési útját (könyvtárát)
        [Arguments]    ${file_path}
        ${dir_path}=    Evaluate    __import__('os').path.dirname(r'''${file_path}''')    modules=os
        RETURN    ${dir_path}

Get Input Folder From Config
    [Documentation]    Config fájlból input_folder érték kiolvasása
    
    # Config fájl beolvasása (egy szinttel feljebb a gyökérkönyvtárból)
    ${config_content}=    Get File    ${CURDIR}/../IKK.config
    @{config_lines}=    Split To Lines    ${config_content}
    
    FOR    ${line}    IN    @{config_lines}
        ${line_trimmed}=    Strip String    ${line}
        ${is_input_folder}=    Run Keyword And Return Status    Should Start With    ${line_trimmed}    input_folder=
        IF    ${is_input_folder}
            ${input_folder_value}=    Replace String    ${line_trimmed}    input_folder=    ${EMPTY}
            ${input_folder_normalized}=    Replace String    ${input_folder_value}    \\    /
            Log String To Console    Config-ból beolvasott input folder: ${input_folder_normalized}
            RETURN    ${input_folder_normalized}
        END
    END
    
    # Ha nem találjuk, alapértelmezett érték
    Log String To Console     \n\[FIGYELEM] input_folder nem található a config-ban!
    RETURN    ${EMPTY}



DOCX Beolvasás Teszt
    [Documentation]    Teszt: DOCX fájl beolvasásának ellenőrzése (adatbázis nélkül)
    [Arguments]    ${file_path}
    
    #Log String To Console    === DOCX BEOLVASÁS TESZT ===
    #Log String To Console    Fájl: ${file_path}
    
    # A tényleges beolvasás már megtörtént a korábbi lépésekben
    ${szoveg}=    Get Variable Value    ${SZOVEG}    ${EMPTY}
    
    IF    len($szoveg) > 0
        Log String To Console    DOCX beolvasás sikeres
        #Log String To Console    Szöveg hossza: ${szoveg.__len__()}
    ELSE
        Log String To Console    FIGYELEM: DOCX szöveg üres
    END
    
    #Log String To Console    === DOCX BEOLVASÁS TESZT KÉSZ ===

    


DOCX fájlok olvasása és formálellenőrzés
    #Log String To Console    [TRACE] DOCX fájlok olvasása elindult
    [Documentation]    Batch feldolgozás összes DOCX fájlra a DOCUMENT_PATH útvonalon - minden DOCX-hez külön test case generálás
    
    # DOCX fájlok keresése a megadott útvonalon
    @{docx_files}=    Find Docx Files Recursively    ${DOCUMENT_PATH}
    
    # Ellenőrzés, hogy van-e DOCX fájl
    ${file_count}=    Get Length    ${docx_files}
    Set Global Variable    ${file_count}
    Set Global Variable    ${BATCH_FILE_COUNT}    ${file_count}
    Set Global Variable    ${BATCH_DOCX_FILES}    ${docx_files}
    Log String To Console    \n=== DOCX FÁJLOK KERESÉSE ===
    Log String To Console    Keresési útvonal: ${DOCUMENT_PATH}
    Log String To Console    Talált DOCX fájlok száma: ${file_count}

    
    IF    ${file_count} == 0
        Log String To Console    FIGYELMEZTETÉS: Nem találhatók DOCX fájlok a megadott útvonalon!
        Run Keyword And Continue On Failure    Fail    Nincsenek DOCX fájlok a feldolgozásra
        RETURN
    END
    
    # Hibalista inicializálása
    ${HIBA_LISTA}=    Create List
    Set Global Variable    ${HIBA_LISTA}

    # Minden DOCX fájlhoz külön test case futtatása a main suite-ban
    ${current_index}=    Set Variable    1
    FOR    ${docx_file}    IN    @{docx_files}
        #ha a fájl neve nem üres és van benne docx.docx akkor átnevezi .docx-re
        
        ${base_name}=    Get File Name Base    ${docx_file}
        ${test_case_name}=    Set Variable    Formálellenőrzés - ${base_name}
        
        # Dinamikus test case futtatása
        Process Single DOCX File As Test Case    ${docx_file}    ${current_index}    ${file_count}    ${test_case_name}
        ${current_index}=    Evaluate    ${current_index} + 1
    END

    # Hibalista kiírása a végén
    Run Keyword If    ${HIBA_LISTA}    Log String To Console    \n=== HIBÁS DOCX FÁJLOK ===
    ${hiba_lista}=    Get Variable Value    ${HIBA_LISTA}    []
    FOR    ${hiba}    IN    @{hiba_lista}
        Log String To Console    ${hiba}
    END

    Log String To Console    === ÖSSZESÍTÉS ===
    Log String To Console    \nFeldolgozott dokumentumok száma: ${file_count}

Process Single DOCX File As Test Case
    [Documentation]    Egyetlen DOCX fájl feldolgozása test case-ként (redundancia + 23 formálellenőrzés)
    [Arguments]    ${docx_file}    ${file_index}    ${total_files}    ${test_case_name}
    
    Log String To Console    \n>>> TEST CASE: ${test_case_name} (${file_index}/${total_files})
    Log String To Console    Fájl: ${docx_file}
    
    # PLG-01-Excel.robot meghívása (4 értéket ad vissza: excel, sheet, path, filename)
    ${activeExcelFile}    ${activeSheetName}    ${path_part}    ${filename_part}=    Create_K_ell_Excel    ${docx_file}

    # Globális változók beállítása a formálellenőrzéshez
    Set Global Variable    ${CURRENT_EXCEL_FILE}    ${activeExcelFile}
    Set Global Variable    ${CURRENT_SHEET_NAME}    ${activeSheetName}
    Set Global Variable    ${CURRENT_PATH_PART}    ${path_part}
    Set Global Variable    ${CURRENT_FILENAME_PART}    ${filename_part}
    
    # Beállítja az aktuális DOCX fájlt változóban
    Set Global Variable    ${DOCX_FILE}    ${docx_file}
    
    # DOCX beolvasás és hibastátusz lekérdezése
 
    Set Global Variable    ${SZOVEG}    ${szoveg}

    ${is_error}=    Run Keyword And Return Status    Should Start With    ${szoveg}    [HIBA]
    ${is_empty}=    Run Keyword And Return Status    Should Be Empty    ${szoveg}
    ${is_none}=    Run Keyword And Return Status    Should Be Equal    ${szoveg}    None
    # Bármelyik igaz, akkor is_error legyen igaz
    IF    ${is_error} or ${is_empty} or ${is_none}
        ${is_error}=    Set Variable    ${True}
    ELSE
        ${is_error}=    Set Variable    ${False}
    END
    Run Keyword If    ${is_error}    Log String To Console    [DEBUG] is_error: ${is_error}
    # Hibalistába fájlnév+hibaszöveg, de a feldolgozó kulcsszónak csak a file_path
    ${hiba_lista}=    Get Variable Value    ${HIBA_LISTA}    []
    Run Keyword If    ${is_error}    Append To List    ${hiba_lista}    ${docx_file}: ${szoveg}
    Set Global Variable    ${HIBA_LISTA}    ${hiba_lista}

    # Redundancia logika eltávolítva; közvetlen DOCX beolvasási teszt
    DOCX Beolvasás Teszt    ${docx_file}
    # Opcionális JSON dump fájlba
    Dump Docx Json If Enabled    ${docx_file}
    
    # 23 formálellenőrzés futtatása közvetlenül (nem subprocess-ként)
    Log String To Console    \n=== 23 FORMÁLELLENŐRZÉS INDÍTÁSA ===
    Log String To Console    Excel fájl[activeExcelFile]: ${activeExcelFile}
    Log String To Console    Sheet név[activeSheetName]: ${activeSheetName}
    Log String To Console    Fájlnév rész[filename_part]: ${filename_part}
    Log String To Console    Elérési út rész[path_part]: ${path_part}
    Log String To Console    ===========================


    
    # Mind a 23 formálellenőrzés futtatása egyenként
    Run All Format Checks Inline    ${docx_file}    ${activeExcelFile}    ${activeSheetName}
    
    Log String To Console    \n<<< TEST CASE BEFEJEZVE: ${test_case_name}

Run All Format Checks Inline
    [Documentation]    Mind a 23 formálellenőrzést futtatja közvetlenül (nem subprocess-ként)
    [Arguments]    ${docx_file}    ${excel_file}    ${sheet_name}
    
    # Globális változók beállítása
    Set Global Variable    ${CURRENT_DOCX_FILE}    ${docx_file}
    Set Global Variable    ${CURRENT_EXCEL_FILE}    ${excel_file}
    Set Global Variable    ${CURRENT_SHEET_NAME}    ${sheet_name}
    Set Global Variable    ${WAS_ERROR}    ${False}
    
    # Összesítés számlálók
    ${check_total}=    Set Variable    0
    ${check_passed}=   Set Variable    0
    ${check_failed}=   Set Variable    0
    
    ${rc}    ${msg}=    Run Keyword And Ignore Error    Test Case 01 - Arculati Elemek Ellenorzese
    ${check_total}=    Evaluate    ${check_total} + 1
    IF    '${rc}' == 'PASS'
        ${check_passed}=    Evaluate    ${check_passed} + 1
    ELSE
        ${check_failed}=    Evaluate    ${check_failed} + 1
        #Log String To Console    [HIBA] 01 - Arculati Elemek: ${msg}
    END
    
    ${rc}    ${msg}=    Run Keyword And Ignore Error    Test Case 02 - Kompetencia Teszt Ellenorzese
    ${check_total}=    Evaluate    ${check_total} + 1
    IF    '${rc}' == 'PASS'
        ${check_passed}=    Evaluate    ${check_passed} + 1
    ELSE
        ${check_failed}=    Evaluate    ${check_failed} + 1
        #Log String To Console    [HIBA] 02 - Kompetencia Teszt: ${msg}
    END
    
    ${rc}    ${msg}=    Run Keyword And Ignore Error    Test Case 03 - Fogalomtar Ellenorzese
    ${check_total}=    Evaluate    ${check_total} + 1
    IF    '${rc}' == 'PASS'
        ${check_passed}=    Evaluate    ${check_passed} + 1
    ELSE
        ${check_failed}=    Evaluate    ${check_failed} + 1
        #Log String To Console    [HIBA] 03 - Fogalomtar: ${msg}
    END
    
    ${rc}    ${msg}=    Run Keyword And Ignore Error    Test Case 04 - Szerkesztoi Instrukciok Ellenorzese
    ${check_total}=    Evaluate    ${check_total} + 1
    IF    '${rc}' == 'PASS'
        ${check_passed}=    Evaluate    ${check_passed} + 1
    ELSE
        ${check_failed}=    Evaluate    ${check_failed} + 1
        #Log String To Console    [HIBA] 04 - Szerkesztoi Instrukciok: ${msg}
    END
    
    ${rc}    ${msg}=    Run Keyword And Ignore Error    Test Case 05 - Internet Hivatkozasok Ellenorzese
    ${check_total}=    Evaluate    ${check_total} + 1
    IF    '${rc}' == 'PASS'
        ${check_passed}=    Evaluate    ${check_passed} + 1
    ELSE
        ${check_failed}=    Evaluate    ${check_failed} + 1
        #Log String To Console    [HIBA] 05 - Internet Hivatkozasok: ${msg}
    END
    
    ${rc}    ${msg}=    Run Keyword And Ignore Error    Test Case 06 - Szerzo Lektor Ellenorzese
    ${check_total}=    Evaluate    ${check_total} + 1
    IF    '${rc}' == 'PASS'
        ${check_passed}=    Evaluate    ${check_passed} + 1
    ELSE
        ${check_failed}=    Evaluate    ${check_failed} + 1
        #Log String To Console    [HIBA] 06 - Szerzo Lektor: ${msg}
    END
    
    ${rc}    ${msg}=    Run Keyword And Ignore Error    Test Case 07 - Hosszu Idezetek Ellenorzese  
    ${check_total}=    Evaluate    ${check_total} + 1
    IF    '${rc}' == 'PASS'
        ${check_passed}=    Evaluate    ${check_passed} + 1
    ELSE
        ${check_failed}=    Evaluate    ${check_failed} + 1
        #Log String To Console    [HIBA] 07 - Hosszu Idezetek: ${msg}
    END
    
    ${rc}    ${msg}=    Run Keyword And Ignore Error    Test Case 08 - Tordeles Ellenorzese
    ${check_total}=    Evaluate    ${check_total} + 1
    IF    '${rc}' == 'PASS'
        ${check_passed}=    Evaluate    ${check_passed} + 1
    ELSE
        ${check_failed}=    Evaluate    ${check_failed} + 1
        #Log String To Console    [HIBA] 08 - Tordeles: ${msg}
    END
    
    ${rc}    ${msg}=    Run Keyword And Ignore Error    Test Case 09 - Abrak Fotok Ellenorzese
    ${check_total}=    Evaluate    ${check_total} + 1
    IF    '${rc}' == 'PASS'
        ${check_passed}=    Evaluate    ${check_passed} + 1
    ELSE
        ${check_failed}=    Evaluate    ${check_failed} + 1
        #Log String To Console    [HIBA] 09 - Abrak Fotok: ${msg}
    END
    
    ${rc}    ${msg}=    Run Keyword And Ignore Error    Test Case 10 - Felsorolas Ellenorzese
    ${check_total}=    Evaluate    ${check_total} + 1
    IF    '${rc}' == 'PASS'
        ${check_passed}=    Evaluate    ${check_passed} + 1
    ELSE
        ${check_failed}=    Evaluate    ${check_failed} + 1
        #Log String To Console    [HIBA] 10 - Felsorolas: ${msg}
    END
    
    ${rc}    ${msg}=    Run Keyword And Ignore Error    Test Case 11 - Ures Negyzetek Ellenorzese
    ${check_total}=    Evaluate    ${check_total} + 1
    IF    '${rc}' == 'PASS'
        ${check_passed}=    Evaluate    ${check_passed} + 1
    ELSE
        ${check_failed}=    Evaluate    ${check_failed} + 1
        #Log String To Console    [HIBA] 11 - Ures Negyzetek: ${msg}
    END
    
    ${rc}    ${msg}=    Run Keyword And Ignore Error    Test Case 12 - Magyar Nyelven Keszult Ellenorzese
    ${check_total}=    Evaluate    ${check_total} + 1
    IF    '${rc}' == 'PASS'
        ${check_passed}=    Evaluate    ${check_passed} + 1
    ELSE
        ${check_failed}=    Evaluate    ${check_failed} + 1
        #Log String To Console    [HIBA] 12 - Magyar Nyelven Keszult: ${msg}
    END
    
    ${rc}    ${msg}=    Run Keyword And Ignore Error    Test Case 13 - Bekezdesek Elkulonulnek Ellenorzese
    ${check_total}=    Evaluate    ${check_total} + 1
    IF    '${rc}' == 'PASS'
        ${check_passed}=    Evaluate    ${check_passed} + 1
    ELSE
        ${check_failed}=    Evaluate    ${check_failed} + 1
        #Log String To Console    [HIBA] 13 - Bekezdesek Elkulonulnek: ${msg}
    END
    
    ${rc}    ${msg}=    Run Keyword And Ignore Error    tc_14_felsorolasok_egysegesek.Test Case 14 - Felsorolasok Egysegesek Ellenorzese
    ${check_total}=    Evaluate    ${check_total} + 1
    IF    '${rc}' == 'PASS'
        ${check_passed}=    Evaluate    ${check_passed} + 1
    ELSE
        ${check_failed}=    Evaluate    ${check_failed} + 1
        #Log String To Console    [HIBA] 14 - Felsorolasok Egysegesek : ${msg}
    END
    
    ${rc}    ${msg}=    Run Keyword And Ignore Error    tc_15_mozaikaszvak.Test Case 15 - Mozaikszavak Roviditesek Ellenorzese
    ${check_total}=    Evaluate    ${check_total} + 1
    IF    '${rc}' == 'PASS'
        ${check_passed}=    Evaluate    ${check_passed} + 1
    ELSE
        ${check_failed}=    Evaluate    ${check_failed} + 1
        #Log String To Console    [HIBA] 15 - Mozaikszavak Roviditesek : ${msg}
    END
    
    ${rc}    ${msg}=    Run Keyword And Ignore Error    tc_16_ldezetek.Test Case 16 - Idezetek Formailag Megfeleloek Ellenorzese
    ${check_total}=    Evaluate    ${check_total} + 1
    IF    '${rc}' == 'PASS'
        ${check_passed}=    Evaluate    ${check_passed} + 1
    ELSE
        ${check_failed}=    Evaluate    ${check_failed} + 1
        #Log String To Console    [HIBA] 16 - Idezetek Formailag Megfeleloek: ${msg}
    END
    
    ${rc}    ${msg}=    Run Keyword And Ignore Error    tc_17_idezetek_forrasmegjelolese.Test Case 17 - Idezetek Forrasmegjelolese Ellenorzese
    ${check_total}=    Evaluate    ${check_total} + 1
    IF    '${rc}' == 'PASS'
        ${check_passed}=    Evaluate    ${check_passed} + 1
    ELSE
        ${check_failed}=    Evaluate    ${check_failed} + 1
        #Log String To Console    [HIBA] 17 - Tartalomjegyzek: ${msg}
    END
    
    ${rc}    ${msg}=    Run Keyword And Ignore Error    tc_18_kompetencia_teszt_megoldokulcs.Test Case 18 - Kompetencia Teszt Megoldokulcs Ellenorzese
    ${check_total}=    Evaluate    ${check_total} + 1
    IF    '${rc}' == 'PASS'
        ${check_passed}=    Evaluate    ${check_passed} + 1
    ELSE
        ${check_failed}=    Evaluate    ${check_failed} + 1
        #Log String To Console    [HIBA] 18 - Kompetencia Teszt Megoldokulcs : ${msg}
    END
    
    ${rc}    ${msg}=    Run Keyword And Ignore Error    tc_19_idegen_nyelvu_illusztraciok.Test Case 19 - Idegen Nyelvu Illusztraciok Ellenorzese
    ${check_total}=    Evaluate    ${check_total} + 1
    IF    '${rc}' == 'PASS'
        ${check_passed}=    Evaluate    ${check_passed} + 1
    ELSE
        ${check_failed}=    Evaluate    ${check_failed} + 1
        #Log String To Console    [HIBA] 19 - Idegen Nyelvu Illusztraciok: ${msg}
    END
    
    ${rc}    ${msg}=    Run Keyword And Ignore Error    tc_20_lapjai_szamozottak.Test Case 20 - Lapjai Szamozottak Ellenorzese
    ${check_total}=    Evaluate    ${check_total} + 1
    IF    '${rc}' == 'PASS'
        ${check_passed}=    Evaluate    ${check_passed} + 1
    ELSE
        ${check_failed}=    Evaluate    ${check_failed} + 1
        #Log String To Console    [HIBA] 20 - Lapjai Szamozottak : ${msg}
    END
    
    ${rc}    ${msg}=    Run Keyword And Ignore Error    tc_21_szerkesztheto_docx_formatum.Test Case 21 - Szerkesztheto Docx Formatum Ellenorzese
    ${check_total}=    Evaluate    ${check_total} + 1
    IF    '${rc}' == 'PASS'
        ${check_passed}=    Evaluate    ${check_passed} + 1
    ELSE
        ${check_failed}=    Evaluate    ${check_failed} + 1
        #Log String To Console    [HIBA] 21 - Szerkesztheto Docx Formatum: ${msg}
    END
    
    ${rc}    ${msg}=    Run Keyword And Ignore Error    tc_22_cimlap_tartalom.Test Case 22 - Cimlap Tartalom Ellenorzese
    ${check_total}=    Evaluate    ${check_total} + 1
    IF    '${rc}' == 'PASS'
        ${check_passed}=    Evaluate    ${check_passed} + 1
    ELSE
        ${check_failed}=    Evaluate    ${check_failed} + 1
        #Log String To Console    [HIBA] 22 -  Cimlap Tartalom:  ${msg}
    END
    
    ${rc}    ${msg}=    Run Keyword And Ignore Error    Test Case 23 - Generalt Tartalomjegyzek Ellenorzese
    ${check_total}=    Evaluate    ${check_total} + 1
    IF    '${rc}' == 'PASS'
        ${check_passed}=    Evaluate    ${check_passed} + 1
    ELSE
        ${check_failed}=    Evaluate    ${check_failed} + 1
        #Log String To Console    [HIBA] 23 - Generalt Tartalomjegyzek : ${msg}
    END
    
    ${rc}    ${msg}=    Run Keyword And Ignore Error    Test Case 24 - Cimsorozassal Keszult Ellenorzese
    ${check_total}=    Evaluate    ${check_total} + 1
    IF    '${rc}' == 'PASS'
        ${check_passed}=    Evaluate    ${check_passed} + 1
    ELSE
        ${check_failed}=    Evaluate    ${check_failed} + 1
        #Log String To Console    [HIBA] 24 - Cimsorozassal Keszult Ellenorzese : ${msg}
    END


    # ha WAS_ERROR (bármelyik ellenőrzés hibás), Excel fájl átnevezése: K_ell -> _K_ell
    ${was_error}=    Evaluate    ${check_failed} > 0
    Set Global Variable    ${WAS_ERROR}    ${was_error}
    IF    ${was_error}
        Rename Excel File Mark Error    ${CURRENT_EXCEL_FILE}
    END
    Log String To Console    Feldolgozott Excel fájl: ${CURRENT_EXCEL_FILE}

    # Összegzés kiírása
    Log String To Console    \n=== FORMÁLELLENŐRZÉS ÖSSZESÍTÉS ===
    Log String To Console    Ellenőrzések száma: ${check_total}  |  Sikeres: ${check_passed}  |  Sikertelen: ${check_failed}
    # Globális számlálók frissítése
    Update Global Check Counters    ${check_total}    ${check_passed}    ${check_failed}
    
    Log String To Console    === Mind a 24 formálellenőrzés befejezve ===

Rename Excel File Mark Error
    [Documentation]    Hibás ellenőrzés esetén az Excel fájl átnevezése: K_ell -> _K_ell a fájlnévben
    [Arguments]    ${excel_file}
    ${exists}=    Run Keyword And Return Status    File Should Exist    ${excel_file}
    IF    not ${exists}
        Log String To Console     \n\[WARNING] Excel fájl nem található, átnevezés kihagyva: ${excel_file}
        RETURN
    END
    ${dirpath}=       Evaluate    __import__('os').path.dirname(r'''${excel_file}''')    modules=os
    ${basename}=      Evaluate    __import__('os').path.basename(r'''${excel_file}''')    modules=os
    ${new_basename}=  Replace String    ${basename}    K_ell    _K_ell    count=1
    IF    '${new_basename}' == '${basename}'
        Log String To Console     \n\[INFO] A fájlnév nem tartalmazza a 'K_ell' mintát, átnevezés kihagyva: ${basename}
        RETURN
    END
    ${new_path}=      Evaluate    __import__('os').path.join(r'''${dirpath}''', r'''${new_basename}''')    modules=os
    #${exists_new}=    Run Keyword And Return Status    File Should Exist    ${new_path}
    #IF    ${exists_new}
    #    ${ts}=    Get Current Date    result_format=%Y%m%d_%H%M%S
    #    ${new_basename}=    Replace String    ${new_basename}    .xlsx    _${ts}.xlsx
    #    ${new_path}=    Evaluate    __import__('os').path.join(r'''${dirpath}''', r'''${new_basename}''')    modules=os
    #END
    Log String To Console     \n\[INFO] Excel átnevezés: ${excel_file} -> ${new_path}
    TRY
        # csak másolás, mert lehet, hogy a fájl nyitva van Excelben
        # Copy File    ${excel_file}    ${new_path}
        #Move File    ${excel_file}    ${new_path}
        # Set Global Variable    ${CURRENT_EXCEL_FILE}    ${new_path}
        No Operation
    EXCEPT    AS    ${e}
        Log String To Console     \n\[HIBA] Excel átnevezés sikertelen: ${e}
    END

Initialize DOCX Files List
    [Documentation]    DOCX fájlok listájának inicializálása batch feldolgozáshoz
    
    # DOCX fájlok keresése a megadott útvonalon
    @{docx_files}=    Find Docx Files Recursively    ${DOCUMENT_PATH}
    
    # Ellenőrzés, hogy van-e DOCX fájl
    ${file_count}=    Get Length    ${docx_files}
    Set Global Variable    ${BATCH_FILE_COUNT}    ${file_count}
    Set Global Variable    ${BATCH_DOCX_FILES}    ${docx_files}
    Log String To Console    \n=== DOCX FÁJLOK KERESÉSE ===
    Log String To Console    Keresési útvonal: ${DOCUMENT_PATH}
    Log String To Console    Talált DOCX fájlok száma: ${file_count}

    
    IF    ${file_count} == 0
        Log String To Console    FIGYELMEZTETÉS: Nem találhatók DOCX fájlok a megadott útvonalon!
        Run Keyword And Continue On Failure    Fail    Nincsenek DOCX fájlok a feldolgozásra
        RETURN
    END
    
    # Hibalista inicializálása
    ${HIBA_LISTA}=    Create List
    Set Global Variable    ${HIBA_LISTA}


Prepare DOCX Files List
    [Documentation]    DOCX fájlok listájának előkészítése és globális változók beállítása
    
    # DOCX fájlok keresése a megadott útvonalon
    @{docx_files}=    Find Docx Files Recursively    ${DOCUMENT_PATH}
    
    # Ellenőrzés, hogy van-e DOCX fájl
    ${file_count}=    Get Length    ${docx_files}
    Set Global Variable    ${BATCH_FILE_COUNT}    ${file_count}
    Set Global Variable    ${BATCH_DOCX_FILES}    ${docx_files}
    Log String To Console    \n=== DOCX FÁJLOK KERESÉSE ===
    Log String To Console    Keresési útvonal: ${DOCUMENT_PATH}
    Log String To Console    Talált DOCX fájlok száma: ${file_count}

    
    IF    ${file_count} == 0
        Log String To Console    FIGYELMEZTETÉS: Nem találhatók DOCX fájlok a megadott útvonalon!
        Run Keyword And Continue On Failure    Fail    Nincsenek DOCX fájlok a feldolgozásra
        RETURN
    END
    
    # Hibalista inicializálása
    ${HIBA_LISTA}=    Create List
    Set Global Variable    ${HIBA_LISTA}

Process Single DOCX File
    [Documentation]    Egyetlen DOCX fájl feldolgozása (redundancia + formálellenőrzés)
    [Arguments]    ${docx_file}    ${file_index}    ${total_files}
    
    Log String To Console    \n>>> FELDOLGOZÁS3: (${file_index}/${total_files}) ${docx_file}
 
    # PLG-01-Excel.robot meghívása
    ${activeExcelFile}    ${activeSheetName}    ${path_part}    ${filename_part}=    Create_K_ell_Excel    ${docx_file}
   
    # Globális változók beállítása a formálellenőrzéshez
    Set Global Variable    ${CURRENT_EXCEL_FILE}    ${activeExcelFile}
    Set Global Variable    ${CURRENT_SHEET_NAME}    ${activeSheetName}
    Set Global Variable    ${CURRENT_PATH_PART}    ${path_part}
    Set Global Variable    ${CURRENT_FILENAME_PART}    ${filename_part}

    # Beállítja az aktuális DOCX fájlt változóban
    Set Global Variable    ${DOCX_FILE}    ${docx_file}

    
    
    # DOCX beolvasás és hibastátusz lekérdezése
    ${szoveg}=    Beolvasom A DOCX Fájlt
    Set Global Variable    ${SZOVEG}    ${szoveg}

    ${is_error}=    Run Keyword And Return Status    Should Start With    ${szoveg}    [HIBA]
    ${is_empty}=    Run Keyword And Return Status    Should Be Empty    ${szoveg}
    ${is_none}=    Run Keyword And Return Status    Should Be Equal    ${szoveg}    None
    # Bármelyik igaz, akkor is_error legyen igaz
    IF    ${is_error} or ${is_empty} or ${is_none}
        ${is_error}=    Set Variable    ${True}
    ELSE
        ${is_error}=    Set Variable    ${False}
    END
    Run Keyword If    ${is_error}    Log String To Console    [DEBUG] is_error: ${is_error}
    # Hibalistába fájlnév+hibaszöveg, de a feldolgozó kulcsszónak csak a file_path
    ${hiba_lista}=    Get Variable Value    ${HIBA_LISTA}    []
    Run Keyword If    ${is_error}    Append To List    ${hiba_lista}    ${docx_file}: ${szoveg}
    Set Global Variable    ${HIBA_LISTA}    ${hiba_lista}

    # Redundancia logika eltávolítva; közvetlen DOCX beolvasási teszt
    DOCX Beolvasás Teszt    ${docx_file}
    
    # 23 formálellenőrzés futtatása közvetlenül (nem subprocess-ként)
    Log String To Console    === FORMAI ELLENŐRZÉS INDÍTÁSA (inline) ===
    Log String To Console    Excel fájl: ${activeExcelFile}
    Log String To Console    Sheet név: ${activeSheetName}
    Log String To Console    Path rész: ${path_part}
    Log String To Console    Fájl név rész: ${filename_part}
    Run All Format Checks Inline    ${docx_file}    ${activeExcelFile}    ${activeSheetName}
       
    Log String To Console    \n<<< FORMAI ELLENŐRZÉS BEFEJEZVE: ${docx_file}
   

    


Get File Name Base
    [Documentation]    Visszaadja a fájlnevet kiterjesztés nélkül
    [Arguments]    ${file_path}
    # Robusztus: csak az utolsó kiterjesztést vágjuk le, akkor is ha a névben több pont van
    ${base_name}=    Evaluate    __import__('os').path.splitext(__import__('os').path.basename(r'''${file_path}'''))[0]    modules=os
    RETURN    ${base_name}


# =================================================================
# HIÁNYZÓ KEYWORDOK HELYREÁLLÍTVA AZ ARCHIVÁLT FÁJLOKBÓL
# =================================================================

Read Docx
    [Documentation]    DOCX fájl tartalmának beolvasása DocxReader.py használatával
    [Arguments]    ${file_path}
    
    Log String To Console    DOCX fájl beolvasása: ${file_path}
    
    ${result}=    Run Keyword And Return Status    File Should Exist    ${file_path}
    IF    not ${result}
        Log String To Console     \n\[HIBA] DOCX fájl nem található: ${file_path}
        RETURN    [HIBA] DOCX fájl nem található: ${file_path}
    END
    
    # DocxReader.py read_docx függvényének hívása
    TRY
        ${content}=    Read Docx File Content    ${file_path}
        ${content_length}=    Get Length    ${content}
        Log String To Console    DOCX fájl beolvasva: ${content_length} karakter
        RETURN    ${content}
    EXCEPT    AS    ${error}
        Log String To Console     \n\[HIBA-Read Docx] DOCX beolvasás sikertelen: ${error}
        RETURN    [HIBA-Read Docx] DOCX beolvasás sikertelen: ${error}
    END

Read Docx All
    [Documentation]    DocxReader.read_docx_all hívása Robotból
    [Arguments]    ${file_path}
    ${lib}=    Get Library Instance    DocxReader
    ${data}=    Call Method    ${lib}    read_docx_all    ${file_path}
    RETURN    ${data}

Read Docx All As Json
    [Documentation]    DocxReader.read_docx_all_as_json hívása Robotból
    [Arguments]    ${file_path}    ${extract_images_to}=${None}    ${debug}=${False}
    ${lib}=    Get Library Instance    DocxReader
    ${json}=    Call Method    ${lib}    read_docx_all_as_json    ${file_path}    ${extract_images_to}    ${debug}
    RETURN    ${json}

Mark Excel Cell Green
    [Documentation]    Excel cella zöld színűre festése
    [Arguments]    ${excel_file}    ${sheet_name}    ${cell_address}
    
    Log String To Console    Excel jelölés: ${excel_file} - ${sheet_name} - ${cell_address}
    
    # Excel jelölés Python script-tel (útvonal normalizálása a figyelmeztetések elkerülésére)
        ${excel_path_norm}=    Evaluate    __import__('pathlib').Path(r'''${excel_file}''').as_posix()    modules=pathlib
        ${script}=    Set Variable    import openpyxl; from openpyxl.styles import PatternFill; wb=openpyxl.load_workbook('${excel_path_norm}'); ws=wb['${sheet_name}']; ws['${cell_address}'].fill=PatternFill(start_color='00FF00', end_color='00FF00', fill_type='solid'); wb.save('${excel_path_norm}')
    ${result}=    Run Process    ${PYTHON_EXEC}    -W    ignore    -c    ${script}
    
    IF    ${result.rc} != 0
        Log String To Console     \n\[HIBA] Excel jelölés sikertelen: ${result.stderr}
    ELSE
        Log String To Console     \n\[SIKERES] Excel cella jelölve zöldre: ${cell_address}
    END

Mark Excel Cell Red
    [Documentation]    Excel cella piros színűre festése
    [Arguments]    ${excel_file}    ${sheet_name}    ${cell_address}
    
    Log String To Console    Excel jelölés: ${excel_file} - ${sheet_name} - ${cell_address}
    
    # Excel jelölés Python script-tel (útvonal normalizálása a figyelmeztetések elkerülésére)
        ${excel_path_norm}=    Evaluate    __import__('pathlib').Path(r'''${excel_file}''').as_posix()    modules=pathlib
        ${script}=    Set Variable    import openpyxl; from openpyxl.styles import PatternFill; wb=openpyxl.load_workbook('${excel_path_norm}'); ws=wb['${sheet_name}']; ws['${cell_address}'].fill=PatternFill(start_color='FF0000', end_color='FF0000', fill_type='solid'); wb.save('${excel_path_norm}')
    ${result}=    Run Process    ${PYTHON_EXEC}    -W    ignore    -c    ${script}
    
    IF    ${result.rc} != 0
        Log String To Console     \n\[HIBA] Excel jelölés sikertelen: ${result.stderr}
    ELSE
        Log String To Console     \n\[SIKERES] Excel cella jelölve pirosra: ${cell_address}
    END

Read Docx File Content
    [Documentation]    DOCX fájl tartalmának beolvasása DocxReader-rel (biztonságos, nincs -c, nincs idéző/kódolási gond)
    [Arguments]    ${file_path}

    # DocxReader.read_docx_all meghívása és a bekezdések összefűzése
    ${status}    ${data}=    Run Keyword And Ignore Error    Read Docx All    ${file_path}
    IF    '${status}' != 'PASS'
        Log String To Console     \n\[HIBA] DOCX beolvasás sikertelen: ${data}
        RETURN    [HIBA] DOCX beolvasás sikertelen: ${data}
    END

    ${paragraphs}=    Get From Dictionary    ${data}    paragraphs
    ${nonempty}=    Create List
        FOR    ${p}    IN    @{paragraphs}
            ${keep}=    Run Keyword And Return Status    Should Not Be Empty    ${p}
            Run Keyword If    ${keep}    Append To List    ${nonempty}    ${p}
    END
    ${text}=    Catenate    SEPARATOR=\n    @{nonempty}
    RETURN    ${text}

Beolvasom A DOCX Fájlt
    [Documentation]    DOCX fájl tartalmának beolvasása globális változóba

    ${current_docx}=    Get Variable Value    ${DOCX_FILE}    ${EMPTY}
    
    IF    '${current_docx}' == '${EMPTY}'
        Log String To Console     \n\[HIBA] DOCX_FILE változó nincs beállítva!
        RETURN    [HIBA] DOCX_FILE változó nincs beállítva!
    END
    
    # DOCX fájl beolvasása
    ${content}=    Read Docx    ${current_docx}
    Set Global Variable    ${DOCX_JSON}    ${content}   # Teljes JSON mentése globális változóba

    
    RETURN    ${content}


Dump Docx Json If Enabled
    [Documentation]    Ha a ${DOCX_DUMP_TO_FILE} igaz, elmenti a DOCX teljes JSON-ját fájlba.
    [Arguments]    ${docx_file}

    ${dump_enabled}=    Get Variable Value    ${DOCX_DUMP_TO_FILE}    ${False}
    Return From Keyword If    not ${dump_enabled}

    ${dump_dir}=    Get Variable Value    ${DOCX_DUMP_DIR}    ${CURDIR}${/}results${/}docx_dump
    Create Directory    ${dump_dir}

    # JSON előállítása (konzolra nem írjuk ki itt)
    ${json}=    Read Docx All As Json    ${docx_file}    debug=${False}

    # Fájlnév: a DOCX alapneve + .json
    ${base}=    Get File Name Base    ${docx_file}
    ${out_path}=    Set Variable    ${dump_dir}${/}${base}.json

    Create File    ${out_path}    ${json}    encoding=UTF-8
    Log String To Console     \n\[DOCX JSON] Mentve: ${out_path}


Create_K_ell_Excel
    [Documentation]    DOCX fájl feldolgozás - Excel fájl és sheet meghatározása
    [Arguments]    ${docx_file}
    
    Log String To Console    \n=== EXCEL FÁJLOK LÉTREHOZÁSA / ELLENŐRZÉSE ===
    Log String To Console    Kapott paraméter: ${docx_file}
    
    # Path és filename szétválasztása
    ${path_part}=    Evaluate    __import__('os').path.dirname(r'''${docx_file}''')    modules=os
    ${filename_part}=    Evaluate    __import__('os').path.basename(r'''${docx_file}''')    modules=os
    
    Log String To Console    Path rész: ${path_part}
    Log String To Console    Filename rész: ${filename_part}
    Log String To Console    Input folder (globális): ${INPUT_FOLDER}
    
    Set Global Variable    ${FILENAME}    ${filename_part}
    
    # Path szétbontása és input folder eltávolítása
    ${path_normalized}=    Replace String    ${path_part}    \\    /
    @{path_parts}=    Split String    ${path_normalized}    /
    
    # Input folder részek eltávolítása
    ${input_normalized}=    Replace String    ${INPUT_FOLDER}    \\    /
    @{input_parts}=    Split String    ${input_normalized}    /
    
    # Szűrjük ki az üres elemeket
    ${filtered_path_parts}=    Create List
    FOR    ${part}    IN    @{path_parts}
        ${is_empty}=    Run Keyword And Return Status    Should Be Empty    ${part}
        IF    not ${is_empty}
            Append To List    ${filtered_path_parts}    ${part}
        END
    END
    
    ${filtered_input_parts}=    Create List
    FOR    ${part}    IN    @{input_parts}
        ${is_empty}=    Run Keyword And Return Status    Should Be Empty    ${part}
        IF    not ${is_empty}
            Append To List    ${filtered_input_parts}    ${part}
        END
    END
    
    ${filtered_input_parts_count}=    Get Length    ${filtered_input_parts}
    ${filtered_path_parts_count}=    Get Length    ${filtered_path_parts}
    #Log String To Console    Input folder részek: ${filtered_input_parts} (${filtered_input_parts_count} db)
    #Log String To Console    Eredeti path részek: ${filtered_path_parts} (${filtered_path_parts_count} db)
    
    # Eltávolítjuk az input folder részeket a path elejéről
    ${input_parts_count}=    Get Length    ${filtered_input_parts}
    ${relative_parts}=    Get Slice From List    ${filtered_path_parts}    ${input_parts_count}
    
    ${is_success}=    Run Keyword And Return Status    Should Not Be Empty    ${relative_parts}
    IF   not ${is_success}
        Log String To Console     [ERROR] Input folder eltávolítása sikertelen!
        ${relative_parts}=    Set Variable    ${filtered_path_parts}
    END
    
    ${parts_count}=    Get Length    ${relative_parts}
    Log String To Console    Path részek száma (input folder nélkül): ${parts_count}
    Log String To Console    Relatív path részek: ${relative_parts}
    
    # Legalább 2 könyvtárra van szükség (parent és child)
    IF    ${parts_count} < 2
        Log String To Console     [HIBA] Hibás helyen van az ellenőrizendő fájl! A relatív path nem tartalmaz legalább 2 könyvtárat!
        ${parent_path}=    Set Variable    DEFAULT
        ${child_path}=     Set Variable    DEFAULT
        Fail   Feldolgozás megszakítva. Hibás helyen van az ellenőrizendő fájl! Minimum 2 könyvtár szükséges a relatív path-ban.
        RETURN
    ELSE
        ${second_last_idx}=    Evaluate    ${parts_count} - 2
        ${last_idx}=          Evaluate    ${parts_count} - 1
        ${parent_path}=    Get From List    ${relative_parts}    ${second_last_idx}
        ${child_path}=     Get From List    ${relative_parts}    ${last_idx}
    END
    
    #Log String To Console    \n=== FELDOLGOZÁS EREDMÉNYE ===
    Log String To Console    Parent Path: ${parent_path}
    Log String To Console    Child Path: ${child_path}
    Log String To Console    Filename: ${filename_part}
    Set Global Variable    ${DTEM}    ${parent_path}
    Set Global Variable    ${KURZUS}     ${child_path}    
    Log String To Console    Téma: ${DTEM}
    Log String To Console    Kurzus: ${KURZUS}
    

    #Log String To Console    \n=== FELDOLGOZÁS BEFEJEZVE ===
    
    # Excel fájl és sheet meghatározása
    ${output_folder}=    Set Variable    ${CONFIG_OUTPUT_FOLDER}

    # Dokumentum ellenőrzés adatait tartalmazó Excel fájl és sheet
    ${excel_filename}=    Set Variable    ${parent_path}_Kézirat.v1.0.xlsx
    ${activeExcelFile}=    Evaluate    __import__('os').path.join(r'''${output_folder}''', r'''${excel_filename}''')    modules=os
    Log String To Console    Aktuális DOC-${activeExcelFile} - ExcelFile}
    ${activeSheetName}=    Set Variable    ${child_path}
    Set Global Variable    ${DOCUMENT_EXCEL_FILE}    ${activeExcelFile}

    #Web ellenőrzés adatait tartalmazó Excel fájl és sheetek
    ${web_excel_filename}=    Set Variable    ${child_path}_Digitális tananyag.v1.0.xlsx
    ${web_activeExcelFile}=    Evaluate    __import__('os').path.join(r'''${output_folder}''', r'''${web_excel_filename}''')    modules=os
    Set Global Variable    ${DIGITALIS_EXCEL_FILE}    ${web_activeExcelFile}

    Log String To Console    Aktuális WEB-${web_activeExcelFile} - ExcelFile}
     ${web_activeSheetName}=    Set Variable    ${child_path}
    Set Global Variable    ${DIGITALIS_EXCEL_SHEET}    ${web_activeSheetName}

     ${web_activeMK_SheetName}=    Set Variable    ${child_path}-MK
     Set Global Variable    ${DIGITALIS_EXCEL_SHEET_MK}    ${web_activeMK_SheetName}
 
    Log String To Console     \n\[INFO] Beállított globális változók a WEB Excel fájlhoz és sheet-ekhez:
    Log String To Console     \[INFO] DIGITALIS_EXCEL_FILE: ${DIGITALIS_EXCEL_FILE}
    Log String To Console     \[INFO] DIGITALIS_EXCEL_SHEET: ${DIGITALIS_EXCEL_SHEET}
    Log String To Console     \[INFO] DIGITALIS_EXCEL_SHEET_MK: ${DIGITALIS_EXCEL_SHEET_MK}
     
     
      # Sablon fájl másolása
    ${template_path}=    Set Variable    ${CURDIR}/../sablonok/K ell sablon_sulyszam_minbizt_2024_12_v_1_0.xlsx
    ${web_template_path}=    Set Variable    ${CURDIR}/../sablonok/EM-X.Y.Z-Formaiell.xlsx
      
    # Excel fájl létrehozása/ellenőrzése
    ${file_exists}=    Run Keyword And Return Status    File Should Exist    ${activeExcelFile}
    IF    ${file_exists}
        Log String To Console     ${activeExcelFile}
        
        # Sheet ellenőrzése és létrehozása szükség esetén
        ${sheet_exists}=    Check Excel Sheet Exists    ${activeExcelFile}    ${activeSheetName}
        IF    ${sheet_exists}
            Log String To Console     \n\[INFO] Sheet '${activeSheetName}' létezik az Excel fájlban
        ELSE
            Log String To Console     \n\[INFO] Sheet '${activeSheetName}' létrehozása sablon másolással...
            Copy Excel Sheet    ${activeExcelFile}    EM X.Y    ${activeSheetName}
            # Az eredeti EM X.Y sheet elrejtése
            Hide Excel Sheet    ${activeExcelFile}    EM X.Y
            Log String To Console     \n\[INFO] Sheet sablon másolva: 'EM X.Y' -> '${activeSheetName}'

           #WEB sablon másolása
            Copy File    ${web_template_path}    ${web_activeExcelFile}
            Log String To Console     \n\[INFO] WEB Sablon fájl másolva: ${web_template_path} -> ${web_activeExcelFile}
            # todo itt is meg kell csinálni a web-excelt
            #WEB sheet-ek átnevezése
            Copy Excel Sheet    ${web_activeExcelFile}    EM-X.Y.Z    ${web_activeSheetName}
            Hide Excel Sheet    ${web_activeExcelFile}    EM-X.Y.Z    
            Log String To Console     \n\[INFO] WEB Sheet sablon másolva: 'EM-X.Y.Z' -> '${web_activeSheetName}'

            Copy Excel Sheet    ${web_activeExcelFile}    EM-X.Y.Z-MK    ${web_activeSheetName}-MK
            Hide Excel Sheet    ${web_activeExcelFile}    EM-X.Y.Z-MK
            Log String To Console     \n\[INFO] WEB Sheet sablon másolva: 'EM-X.Y.Z-MK' -> '${web_activeSheetName}-MK'


        END
    ELSE
        Log String To Console     \n\[INFO] Excel fájl létrehozása: ${activeExcelFile}
        
     
        ${template_exists}=    Run Keyword And Return Status    File Should Exist    ${template_path}
        IF    ${template_exists}
            #Doc sablon másolása
            Copy File    ${template_path}    ${activeExcelFile}
            Log String To Console     \n\[INFO]DOC Sablon fájl másolva: ${template_path} -> ${activeExcelFile}
            
            #WEB sablon másolása
            Copy File    ${web_template_path}    ${web_activeExcelFile}
            Log String To Console     \n\[INFO] WEB Sablon fájl másolva: ${web_template_path} -> ${web_activeExcelFile}
            # todo itt is meg kell csinálni a web-excelt
            #WEB sheet-ek átnevezése
            Copy Excel Sheet    ${web_activeExcelFile}    EM-X.Y.Z    ${web_activeSheetName}
            Hide Excel Sheet    ${web_activeExcelFile}    EM-X.Y.Z    
            Log String To Console     \n\[INFO] WEB Sheet sablon másolva: 'EM-X.Y.Z' -> '${web_activeSheetName}'

            Copy Excel Sheet    ${web_activeExcelFile}    EM-X.Y.Z-MK    ${web_activeSheetName}-MK
            Hide Excel Sheet    ${web_activeExcelFile}    EM-X.Y.Z-MK
            Log String To Console     \n\[INFO] WEB Sheet sablon másolva: 'EM-X.Y.Z-MK' -> '${web_activeSheetName}-MK'

            # Az új Excel fájlban is létre kell hozni a megfelelő sheet-et
            ${sheet_exists}=    Check Excel Sheet Exists    ${activeExcelFile}    ${activeSheetName}
            IF    not ${sheet_exists}
                Log String To Console     \n\[INFO] Sheet '${activeSheetName}' létrehozása az új Excel fájlban
                Copy Excel Sheet    ${activeExcelFile}    EM X.Y    ${activeSheetName}
                Hide Excel Sheet    ${activeExcelFile}    EM X.Y
                Log String To Console     \n\[INFO] Sheet sablon másolva: 'EM X.Y' -> '${activeSheetName}'
            END
        ELSE
            Log String To Console     \n\[WARNING] Sablon fájl nem található: ${template_path}
            Log String To Console     \n\[INFO] Üres Excel fájl létrehozása alapértelmezett sheet-ekkel...
            ${active_excel_path_norm}=    Evaluate    __import__('pathlib').Path(r'''${activeExcelFile}''').as_posix()    modules=pathlib
            ${create_file_script}=    Set Variable    import openpyxl; wb=openpyxl.Workbook(); wb.remove(wb.active); ws1=wb.create_sheet('EM X.Y'); ws2=wb.create_sheet('${activeSheetName}'); wb.save('${active_excel_path_norm}'); print('Excel fájl és sheet-ek létrehozva')
            ${create_result}=    Run Process    ${PYTHON_EXEC}    -W    ignore    -c    ${create_file_script}
            Log String To Console    Excel létrehozás eredménye: ${create_result.stdout}
        END
    END
    
    RETURN    ${activeExcelFile}    ${activeSheetName}    ${path_part}    ${filename_part}
Hide Excel Sheet
    [Documentation]    Elrejti a megadott sheet-et az Excel fájlban (openpyxl-lel)
    [Arguments]    ${excel_file}    ${sheet_name}
    ${python_code}=    Set Variable    import openpyxl; wb = openpyxl.load_workbook(r'${excel_file}'); ws = wb['${sheet_name}']; ws.sheet_state = 'hidden'; wb.save(r'${excel_file}')
    ${result}=    Run Process    ${PYTHON_EXEC}    -c    ${python_code}    shell=True
    # Log    [DEBUG] Hide sheet result: ${result.stdout}
    # Log    [DEBUG] Hide sheet stderr: ${result.stderr}
    # Log    [DEBUG] Hide sheet return code: ${result.rc}
    ${success}=    Run Keyword And Return Status    Should Be Equal As Integers    ${result.rc}    0
    RETURN    ${success}
Check Excel Sheet Exists
    [Documentation]    Ellenőrzi, hogy létezik-e a megadott sheet név az Excel fájlban
    [Arguments]    ${excel_file}    ${sheet_name}
    
    # Log    [DEBUG] Checking sheet '${sheet_name}' in file: ${excel_file}
    
    # Python használata az Excel sheet-ek ellenőrzéséhez (útvonal normalizálása)
    ${excel_path_norm}=    Evaluate    __import__('pathlib').Path(r'''${excel_file}''').as_posix()    modules=pathlib
    ${result}=    Evaluate    
    ...    __import__('openpyxl').load_workbook('${excel_path_norm}').sheetnames.__contains__('${sheet_name}')
    ...    modules=openpyxl
    
    # Log    [DEBUG] Sheet check result: ${result}
    
    RETURN    ${result}

Copy Excel Sheet
    [Documentation]    Másolja az egyik sheet-et a másikra az Excel fájlban, feltételes formázásokkal együtt
    [Arguments]    ${excel_file}    ${source_sheet_name}    ${target_sheet_name}
    
    # Log    [DEBUG] Copying sheet '${source_sheet_name}' to '${target_sheet_name}' in file: ${excel_file}
    
    # Direct Python evaluation for sheet copying (útvonal normalizálása)
    ${excel_path_norm}=    Evaluate    __import__('pathlib').Path(r'''${excel_file}''').as_posix()    modules=pathlib
    ${python_code}=    Set Variable    import openpyxl; from copy import deepcopy; wb = openpyxl.load_workbook('${excel_path_norm}'); source_sheet = wb['${source_sheet_name}']; target_sheet = wb.copy_worksheet(source_sheet); target_sheet.title = '${target_sheet_name}'; target_sheet.conditional_formatting = deepcopy(source_sheet.conditional_formatting); wb.save('${excel_path_norm}'); print('SUCCESS')
    ${result}=    Run Process    ${PYTHON_EXEC}    -W    ignore    -c    ${python_code}    shell=True
    
    # Log    [DEBUG] Sheet copy result: ${result.stdout}
    # Log    [DEBUG] Sheet copy stderr: ${result.stderr}
    # Log    [DEBUG] Sheet copy return code: ${result.rc}
    ${success}=    Run Keyword And Return Status    Should Be Equal As Strings    ${result.stdout.strip()}    SUCCESS
    RETURN    ${success}
    
Silence Python SyntaxWarnings
    [Documentation]    Kikapcsolja a Python SyntaxWarning figyelmeztetéseket (pl. invalid escape sequence) az Evaluate hívásokhoz
    Evaluate    __import__('warnings').filterwarnings('ignore', category=SyntaxWarning)    modules=warnings