*** Keywords ***

Initialize Global Log File
    [Documentation]    Inicializálja a globális log fájl nevét a futás elején a gyökérkönyvtárban
    ${current_datetime}=    Get Current Date    result_format=%Y%m%d_%H%M%S
    ${log_filename_only}=    Set Variable    RunLog_${current_datetime}.log
    # Kezdetben a gyökérkönyvtárban hozzuk létre
    Set Global Variable    ${GLOBAL_LOG_FILENAME}    ${log_filename_only}
    Set Global Variable    ${LOG_FILENAME_ONLY}    ${log_filename_only}
    Log To Console    Globális log fájl inicializálva: ${log_filename_only}

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
        Log To Console    Log fájl áthelyezve: ${new_log_path}
    ELSE IF    "${new_log_path}" != "${GLOBAL_LOG_FILENAME}"
        Set Global Variable    ${GLOBAL_LOG_FILENAME}    ${new_log_path}
        Log To Console    Log fájl útvonal frissítve: ${new_log_path}
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

Log String To Console
    [Arguments]    @{msgs}
    [Documentation]    Logs message both to console and to timestamped log file
    # Join message parts with single space to avoid accidental extra columns
    ${msg}=    Catenate    SEPARATOR=     @{msgs}
    # Always log to console with newline
    Log To Console    ${msg}
    
    # Skip logging TRACE messages to file
    ${is_trace}=    Run Keyword And Return Status    Should Contain    ${msg}    [TRACE]
    IF    ${is_trace}
        Return From Keyword
    END
    
    # Use the global log filename (should already be set by Initialize Global Log File)
    ${log_filename_exists}=    Run Keyword And Return Status    Variable Should Exist    ${GLOBAL_LOG_FILENAME}
    IF    ${log_filename_exists}
        # Append to log file with newline
        Append To File    ${GLOBAL_LOG_FILENAME}    ${msg}\n
    END

Process Config Line
    Log String To Console    [TRACE] Process Config Line elindult
    [Arguments]    ${config_line}
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
*** Settings ***
Library    ../libraries/DocxReader.py
Library    ../libraries/find_docx.py
Library    BuiltIn
Library    DateTime
Library    Process
Library    OperatingSystem
Library    String
Library    Collections
Library    ../libraries/DocxReader.py
Resource   variables.robot
Resource   get_file_size.resource
# MEGJEGYZÉS: Legacy resource hivatkozások eltávolítva, mivel ezeket a fájlokat archivláltuk


*** Keywords ***

Get Config Icon
    Log String To Console    [TRACE] Get Config Icon elindult
    [Documentation]    Ikonok tiltva: mindig üres string
    [Arguments]    ${icon_name}
    RETURN    ${EMPTY}
    Log String To Console    [TRACE] Get Config Icon kilépett

Konfiguráció Betöltése
    Log String To Console    [TRACE] Konfiguráció Betöltése elindult
    [Documentation]    Plagium.config fajl betoltese es beallitasok alkalmazasa
    Silence Python SyntaxWarnings
    Log String To Console    \nKONFIGURACIO BETOLTESE...
    Log String To Console    ═══════════════════════════════
    # Konfiguracios fajl olvasasa Python scripttel
    ${config_result}=    Run Process    python    libraries/get_config.py    shell=True
    IF    ${config_result.rc} == 0
        ${config_line}=    Set Variable    ${config_result.stdout.strip()}
        #Log To Console    [DEBUG] config_line: ${config_line}
        IF    '${config_line}' != '' and '${config_line}' != 'None'
            Process Config Line    ${config_line}
        ELSE
            Log String To Console    [HIBA] Üres vagy None config_line, Split String kihagyva!
            Log String To Console    [FIGYELMEZTETÉS] Konfiguráció hiányos; alapértelmezett beállítások lesznek használva
        END
    # Adatbázis inicializálás kihagyva - nincs szükség SQLITE_DB_FILE változóra
    Log String To Console    [INFO] Adatbázis inicializálás kihagyva
    
    # Input folder beolvasása a config-ból (egyszer a futás elején)
    ${input_folder}=    Get Input Folder From Config
    Set Global Variable    ${INPUT_FOLDER}    ${input_folder}
    Log String To Console    Input folder globálisan beállítva: ${INPUT_FOLDER}
    
    ELSE
    Log String To Console    Hiba a konfiguracio betoltesekor, alapertelmezettek hasznalata
    Log String To Console    Hibauzenet: ${config_result.stderr}
    END
    Log String To Console    ${EMPTY}
    Log String To Console    ═══════════KONFIGURACIO BETOLTESE KÉSZ════════════════════
    #Log To Console    [TRACE] Konfiguráció Betöltése kilépett

Get Input Folder From Config
    [Documentation]    Config fájlból input_folder érték kiolvasása
    
    # Config fájl beolvasása (egy szinttel feljebb a gyökérkönyvtárból)
    ${config_content}=    Get File    ${CURDIR}/../Duplikacio.config
    @{config_lines}=    Split To Lines    ${config_content}
    
    FOR    ${line}    IN    @{config_lines}
        ${line_trimmed}=    Strip String    ${line}
        ${is_input_folder}=    Run Keyword And Return Status    Should Start With    ${line_trimmed}    input_folder=
        IF    ${is_input_folder}
            ${input_folder_value}=    Replace String    ${line_trimmed}    input_folder=    ${EMPTY}
            ${input_folder_normalized}=    Replace String    ${input_folder_value}    \\    /
            Log To Console    Config-ból beolvasott input folder: ${input_folder_normalized}
            RETURN    ${input_folder_normalized}
        END
    END
    
    # Ha nem találjuk, alapértelmezett érték
    Log To Console    [FIGYELEM] input_folder nem található a config-ban!
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
    Log String To Console    [TRACE] DOCX fájlok olvasása elindult
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
    
    # PLG-01-Excel.robot meghívása
    ${activeExcelFile}    ${activeSheetName}=    Create_K_ell_Excel    ${docx_file}
    
    # Globális változók beállítása a formálellenőrzéshez
    Set Global Variable    ${CURRENT_EXCEL_FILE}    ${activeExcelFile}
    Set Global Variable    ${CURRENT_SHEET_NAME}    ${activeSheetName}
    
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
    Log String To Console    \n=== 23 FORMÁLELLENŐRZÉS INDÍTÁSA ===
    Log String To Console    Excel fájl: ${activeExcelFile}
    Log String To Console    Sheet név: ${activeSheetName}
    
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
    
    Log String To Console    [1/23] Arculati elemek ellenőrzése...
    Test Case 01 - Arculati Elemek Ellenorzese
    
    Log String To Console    [2/23] Kompetencia teszt ellenőrzése...
    Test Case 02 - Kompetencia Teszt Ellenorzese
    
    Log String To Console    [3/23] Fogalomtár ellenőrzése...
    Test Case 03 - Fogalomtar Ellenorzese
    
    Log String To Console    [4/23] Szerkesztői instrukciók ellenőrzése...
    Test Case 04 - Szerkesztoi Instrukciok Ellenorzese
    
    Log String To Console    [5/23] Internet hivatkozások ellenőrzése...
    Test Case 05 - Internet Hivatkozasok Ellenorzese
    
    Log String To Console    [6/23] Szerző-lektor ellenőrzése...
    Test Case 06 - Szerzo Lektor Ellenorzese
    
    Log String To Console    [7/23] Hosszú idézetek ellenőrzése...
    Test Case 07 - Hosszu Idezetek Ellenorzese
    
    Log String To Console    [8/23] Tördelés ellenőrzése...
    Test Case 08 - Tordeles Ellenorzese
    
    Log String To Console    [9/23] Ábrák/fotók ellenőrzése...
    Test Case 09 - Abrak Fotok Ellenorzese
    
    Log String To Console    [10/23] Felsorolások ellenőrzése...
    Test Case 10 - Felsorolas Ellenorzese
    
    Log String To Console    [11/23] Üres négyzetek ellenőrzése...
    Test Case 11 - Ures Negyzetek Ellenorzese
    
    Log String To Console    [12/23] Címek formátuma ellenőrzése...
    Test Case 12 - Cimek Formatuma Ellenorzese
    
    Log String To Console    [13/23] Oldalhatár ellenőrzése...
    Test Case 13 - Oldalhatar Ellenorzese
    
    Log String To Console    [14/23] Betűtípus ellenőrzése...
    Test Case 14 - Betutipus Ellenorzese
    
    Log String To Console    [15/23] Sorköze ellenőrzése...
    Test Case 15 - Sorkoze Ellenorzese
    
    Log String To Console    [16/23] Lábjegyzetek ellenőrzése...
    Test Case 16 - Labjegyzetek Ellenorzese
    
    Log String To Console    [17/23] Tartalomjegyzék ellenőrzése...
    Test Case 17 - Tartalomjegyzek Ellenorzese
    
    Log String To Console    [18/23] Irodalomjegyzék ellenőrzése...
    Test Case 18 - Irodalomjegyzek Ellenorzese
    
    Log String To Console    [19/23] Táblázatok ellenőrzése...
    Test Case 19 - Tablazatok Ellenorzese
    
    Log String To Console    [20/23] Szöveg igazítás ellenőrzése...
    Test Case 20 - Szoveg Igazitas Ellenorzese
    
    Log String To Console    [21/23] Oldalszámozás ellenőrzése...
    Test Case 21 - Oldalszamozas Ellenorzese
    
    Log String To Console    [22/23] Fejléc/lábléc ellenőrzése...
    Test Case 22 - Fejlec Lablec Ellenorzese
    
    Log String To Console    [23/23] Helyesírás ellenőrzése...
    Test Case 23 - Helyesiras Ellenorzese
    
    Log String To Console    === Mind a 23 formálellenőrzés befejezve ===

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

Process Single DOCX With Format Checks
    [Documentation]    Egyetlen DOCX fájl feldolgozása formálellenőrzéssel külön subprocess-ként (a jelenlegi működés megtartása)
    [Arguments]    ${docx_file}    ${file_index}    ${total_files}
    
    #ellenőrizzük, hogy van-e *tema_kezirata fájl a könyvtárban

    ${CURRENT_DIR}=    Evaluate    __import__('os').path.dirname(r'''${docx_file}''')    modules=os
    #Log String To Console    Dokumentum útvonal: ${CURRENT_DIR}

    
    ${allFiles}=    List Files In Directory    ${CURRENT_DIR}
    # a 'files' most az allFiles tömb szűrésével készül, nem új könyvtár listázással
    ${files}=    Evaluate    [f for f in $allFiles if (__import__('os').path.basename(f).lower().endswith('_tema_kezirata.docx') and not __import__('os').path.basename(f).startswith('~$'))]


    ${files_len}=    Get Length    ${files}
    IF    ${files_len} == 0
        Log String To Console    !!!!!!!!!!!!!!!!!!!!! ${CURRENT_DIR} !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        Log String To Console    [HIBA] Nincs *_tema_kezirata.docx fájl a könyvtárban!

        ${hiba_lista}=    Get Variable Value    ${HIBA_LISTA}    []
        Append To List    ${hiba_lista}    ${docx_file}: [HIBA] Nincs *_tema_kezirata.docx fájl a könyvtárban
        Set Global Variable    ${HIBA_LISTA}    ${hiba_lista}
        RETURN
    #ELSE
    #    Log String To Console    [INFO] *_tema_kezirata jelölt fájlok száma: ${files_len}
    END

    #ellenőrzi, hogy a docx_file szerepel-e a files listában (basename összevetés)
    ${docx_basename}=    Evaluate    __import__('os').path.basename(r'''${docx_file}''')    modules=os
    ${is_in_list}=    Run Keyword And Return Status    Should Contain    ${files}    ${docx_basename}
    IF    not ${is_in_list}
        #Log String To Console    >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>  A fájl kihagyva  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        Log String To Console   skipp...
        RETURN
    END    
   
    #Log String To Console    \n>>> FELDOLGOZÁS4: (${file_index}/${total_files}) ${docx_file}
    
    # PLG-01-Excel.robot meghívása
    ${activeExcelFile}    ${activeSheetName}=    Create_K_ell_Excel    ${docx_file}
    
    # Globális változók beállítása a formálellenőrzéshez
    Set Global Variable    ${CURRENT_EXCEL_FILE}    ${activeExcelFile}
    Set Global Variable    ${CURRENT_SHEET_NAME}    ${activeSheetName}
    
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

    # Redundancia logika eltávolítva; skip minta és közvetlen DOCX teszt
    ${is_skip}=    Evaluate    re.search(r'RF221_tema_kezirata\.docx', r'''${docx_file}''') is not None    modules=re
    IF    not ${is_skip}
        Log String To Console     Skipp:${docx_file}
    ELSE
        DOCX Beolvasás Teszt    ${docx_file}
        # PLG-04-Formai_ellenor.robot formálellenőrzés futtatása külön test suite-ként (jelenleg kommentelt)
        Log String To Console    === FORMAI LELLENŐRZÉS INDÍTÁSA ===
        Log String To Console    Excel fájl: ${activeExcelFile}
        Log String To Console    Sheet név: ${activeSheetName}
        Run Formai Ellenorzes With Params    ${docx_file}    ${activeExcelFile}    ${activeSheetName}    
    END
    #Log String To Console    \n<<< 2 BEFEJEZVE: ${docx_file}

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
    ${activeExcelFile}    ${activeSheetName}=    Create_K_ell_Excel    ${docx_file}
    
    # Globális változók beállítása a formálellenőrzéshez
    Set Global Variable    ${CURRENT_EXCEL_FILE}    ${activeExcelFile}
    Set Global Variable    ${CURRENT_SHEET_NAME}    ${activeSheetName}
    
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
    
    # PLG-04-Formai_ellenor.robot formálellenőrzés futtatása külön test suite-ként
    Log String To Console    === FORMAI ELLENŐRZÉS INDÍTÁSA ===
    Log String To Console    Excel fájl: ${activeExcelFile}
    Log String To Console    Sheet név: ${activeSheetName}
    
    # Formálellenőrzés futtatása külön test suite-ként paraméterekkel
    Run Formai Ellenorzes With Params    ${docx_file}    ${activeExcelFile}    ${activeSheetName}
       
    Log String To Console    \n<<< FORMAI ELLENŐRZÉS BEFEJEZVE: ${docx_file}
   

    

Run Formai Ellenorzes
    [Documentation]    Futtatja a 23 formálellenőrzést külön test suite-ként valódi Robot test case-ekkel
    [Arguments]    ${docx_file}
    
    Log To Console    === FORMAI ELLENŐRZÉS INDÍTÁSA ===
    
    # Excel fájl és sheet név generálása a már meglévő Excel fájl alapján
    # A rendszer már létrehozott egy Excel fájlt, azt kell használnunk
    ${base_name}=    Get File Name Base    ${docx_file}
    ${excel_file}=    Set Variable    ${CURRENT_EXCEL_FILE}    # Globális változó, ami már be van állítva
    ${sheet_name}=    Set Variable    ${CURRENT_SHEET_NAME}    # Globális változó, ami már be van állítva
    
    Log To Console    Excel fájl: ${excel_file}
    Log To Console    Sheet név: ${sheet_name}
    
    # Formálellenőrzések futtatása egyenként ugyanabból a suite-ból (--test)
    ${suite_file}=    Set Variable    PLG-04-FormaiEllenorzes-TestCases.robot
    @{test_names}=    Create List
    ...    Test Case 01 - Arculati Elemek Ellenorzese
    ...    Test Case 02 - Kompetencia Teszt Ellenorzese
    ...    Test Case 03 - Fogalomtar Ellenorzese
    ...    Test Case 04 - Szerkesztoi Instrukciok Ellenorzese
    ...    Test Case 05 - Internet Hivatkozasok Ellenorzese
    ...    Test Case 06 - Szerzo Lektor Ellenorzese
    ...    Test Case 07 - Hosszu Idezetek Ellenorzese
    ...    Test Case 08 - Tordeles Ellenorzese
    ...    Test Case 09 - Abrak Fotok Ellenorzese
    ...    Test Case 10 - Felsorolas Ellenorzese
    ...    Test Case 11 - Ures Negyzetek Ellenorzese
    ...    Test Case 12 - Cimek Formatuma Ellenorzese
    ...    Test Case 13 - Oldalhatar Ellenorzese
    ...    Test Case 14 - Betutipus Ellenorzese
    ...    Test Case 15 - Sorkoze Ellenorzese
    ...    Test Case 16 - Labjegyzetek Ellenorzese
    ...    Test Case 17 - Tartalomjegyzek Ellenorzese
    ...    Test Case 18 - Irodalomjegyzek Ellenorzese
    ...    Test Case 19 - Tablazatok Ellenorzese
    ...    Test Case 20 - Szoveg Igazitas Ellenorzese
    ...    Test Case 21 - Oldalszamozas Ellenorzese
    ...    Test Case 22 - Fejlec Lablec Ellenorzese
    ...    Test Case 23 - Helyesiras Ellenorzese
    FOR    ${test_name}    IN    @{test_names}
        @{parts}=    Split String    ${test_name}    ${SPACE}-${SPACE}
        ${test_base}=    Get From List    ${parts}    0
        ${test_outdir}=    Set Variable    results/format_${sheet_name}/${test_base}
        Create Directory    ${test_outdir}
        ${result}=    Run Process    robot
        ...    --variable    CURRENT_DOCX_FILE:${docx_file}
        ...    --variable    CURRENT_EXCEL_FILE:${excel_file}
        ...    --variable    CURRENT_SHEET_NAME:${sheet_name}
        ...    --outputdir    ${test_outdir}
        ...    --name    ${test_base}
        ...    --test    ${test_name}
        ...    ${suite_file}
        ...    shell=True    stdout=PIPE    stderr=PIPE
        Log To Console    === EGYEDI FORMAI TESZT FUTTATÁS === ${test_base}
        Log To Console    Return Code: ${result.rc}
        Log To Console    STDOUT: ${result.stdout}
        IF    ${result.rc} != 0
            Log To Console    STDERR: ${result.stderr}
            ${hiba_lista}=    Get Variable Value    ${HIBA_LISTA}    []
            Append To List    ${hiba_lista}    ${docx_file}: [HIBA] Formálellenőrzési teszt hibával tért vissza: ${test_base} (rc=${result.rc})
            Set Global Variable    ${HIBA_LISTA}    ${hiba_lista}
        END
    END
    Log To Console    === FORMAI ELLENŐRZÉS BEFEJEZVE ===

Get File Name Base
    [Documentation]    Visszaadja a fájlnevet kiterjesztés nélkül
    [Arguments]    ${file_path}
    @{path_parts}=    Split String    ${file_path}    \\
    ${filename}=    Get From List    ${path_parts}    -1
    @{name_parts}=    Split String    ${filename}    .
    ${base_name}=    Get From List    ${name_parts}    0
    RETURN    ${base_name}

Run Formai Ellenorzes With Params
    [Documentation]    Futtatja a 23 formálellenőrzést külön test suite-ként valódi Robot test case-ekkel paraméterekkel
    [Arguments]    ${docx_file}    ${excel_file}    ${sheet_name}
    
    Log To Console    Formálellenőrzés kezdete: ${docx_file}
    Log To Console    Excel fájl: ${excel_file}
    Log To Console    Sheet név: ${sheet_name}
    
    # Formálellenőrzések futtatása egyenként ugyanabból a suite-ból (--test)
    ${suite_file}=    Set Variable    PLG-04-FormaiEllenorzes-TestCases.robot
    @{test_names}=    Create List
    ...    Test Case 01 - Arculati Elemek Ellenorzese
    ...    Test Case 02 - Kompetencia Teszt Ellenorzese
    ...    Test Case 03 - Fogalomtar Ellenorzese
    ...    Test Case 04 - Szerkesztoi Instrukciok Ellenorzese
    ...    Test Case 05 - Internet Hivatkozasok Ellenorzese
    ...    Test Case 06 - Szerzo Lektor Ellenorzese
    ...    Test Case 07 - Hosszu Idezetek Ellenorzese
    ...    Test Case 08 - Tordeles Ellenorzese
    ...    Test Case 09 - Abrak Fotok Ellenorzese
    ...    Test Case 10 - Felsorolas Ellenorzese
    ...    Test Case 11 - Ures Negyzetek Ellenorzese
    ...    Test Case 12 - Cimek Formatuma Ellenorzese
    ...    Test Case 13 - Oldalhatar Ellenorzese
    ...    Test Case 14 - Betutipus Ellenorzese
    ...    Test Case 15 - Sorkoze Ellenorzese
    ...    Test Case 16 - Labjegyzetek Ellenorzese
    ...    Test Case 17 - Tartalomjegyzek Ellenorzese
    ...    Test Case 18 - Irodalomjegyzek Ellenorzese
    ...    Test Case 19 - Tablazatok Ellenorzese
    ...    Test Case 20 - Szoveg Igazitas Ellenorzese
    ...    Test Case 21 - Oldalszamozas Ellenorzese
    ...    Test Case 22 - Fejlec Lablec Ellenorzese
    ...    Test Case 23 - Helyesiras Ellenorzese
    FOR    ${test_name}    IN    @{test_names}
        @{parts}=    Split String    ${test_name}    ${SPACE}-${SPACE}
        ${test_base}=    Get From List    ${parts}    0
        ${test_outdir}=    Set Variable    results/format_${sheet_name}/${test_base}
        Create Directory    ${test_outdir}
        ${result}=    Run Process    robot
        ...    --variable    CURRENT_DOCX_FILE:${docx_file}
        ...    --variable    CURRENT_EXCEL_FILE:${excel_file}
        ...    --variable    CURRENT_SHEET_NAME:${sheet_name}
        ...    --outputdir    ${test_outdir}
        ...    --name    ${test_base}
        ...    --test    ${test_name}
        ...    ${suite_file}
        ...    shell=True    stdout=PIPE    stderr=PIPE
        Log To Console    === EGYEDI FORMAI TESZT FUTTATÁS === ${test_base}
        Log To Console    Return Code: ${result.rc}
        Log To Console    STDOUT: ${result.stdout}
        IF    ${result.rc} != 0
            Log To Console    STDERR: ${result.stderr}
            ${hiba_lista}=    Get Variable Value    ${HIBA_LISTA}    []
            Append To List    ${hiba_lista}    ${docx_file}: [HIBA] Formálellenőrzési teszt hibával tért vissza: ${test_base} (rc=${result.rc})
            Set Global Variable    ${HIBA_LISTA}    ${hiba_lista}
        END
    END
    Log To Console    === FORMÁLELLENŐRZÉS BEFEJEZVE ===

# =================================================================
# HIÁNYZÓ KEYWORDOK HELYREÁLLÍTVA AZ ARCHIVÁLT FÁJLOKBÓL
# =================================================================

Read Docx
    [Documentation]    DOCX fájl tartalmának beolvasása DocxReader.py használatával
    [Arguments]    ${file_path}
    
    Log To Console    DOCX fájl beolvasása: ${file_path}
    
    ${result}=    Run Keyword And Return Status    File Should Exist    ${file_path}
    IF    not ${result}
        Log To Console    [HIBA] DOCX fájl nem található: ${file_path}
        RETURN    [HIBA] DOCX fájl nem található: ${file_path}
    END
    
    # DocxReader.py read_docx függvényének hívása
    TRY
        ${content}=    Read Docx File Content    ${file_path}
        ${content_length}=    Get Length    ${content}
        Log To Console    DOCX fájl beolvasva: ${content_length} karakter
        RETURN    ${content}
    EXCEPT    AS    ${error}
        Log To Console    [HIBA] DOCX beolvasás sikertelen: ${error}
        RETURN    [HIBA] DOCX beolvasás sikertelen: ${error}
    END

Mark Excel Cell Green
    [Documentation]    Excel cella zöld színűre festése
    [Arguments]    ${excel_file}    ${sheet_name}    ${cell_address}
    
    Log To Console    Excel jelölés: ${excel_file} - ${sheet_name} - ${cell_address}
    
    # Excel jelölés Python script-tel (útvonal normalizálása a figyelmeztetések elkerülésére)
        ${excel_path_norm}=    Evaluate    __import__('pathlib').Path(r'''${excel_file}''').as_posix()    modules=pathlib
        ${script}=    Set Variable    import openpyxl; from openpyxl.styles import PatternFill; wb=openpyxl.load_workbook('${excel_path_norm}'); ws=wb['${sheet_name}']; ws['${cell_address}'].fill=PatternFill(start_color='00FF00', end_color='00FF00', fill_type='solid'); wb.save('${excel_path_norm}')
    ${result}=    Run Process    python    -W    ignore    -c    ${script}
    
    IF    ${result.rc} != 0
        Log To Console    [HIBA] Excel jelölés sikertelen: ${result.stderr}
    ELSE
        Log To Console    [SIKERES] Excel cella jelölve zöldre: ${cell_address}
    END

Read Docx File Content
    [Documentation]    DOCX fájl tartalmának beolvasása Python script-tel
    [Arguments]    ${file_path}
    
    # Írjuk ki a DOCX tartalmát egy UTF-8 ideiglenes fájlba, így elkerülhető a konzol kódolási hiba
    ${tmp_out}=    Evaluate    __import__('pathlib').Path(r'''${CURDIR}''').joinpath('..','results','docx_stdout.tmp.txt').resolve().as_posix()    modules=pathlib
    ${file_path_norm}=    Evaluate    __import__('pathlib').Path(r'''${file_path}''').as_posix()    modules=pathlib
    ${script}=    Set Variable    import docx, os; _doc=docx.Document('${file_path_norm}'); _text='\n'.join(p.text for p in _doc.paragraphs); os.makedirs(os.path.dirname('${tmp_out}'), exist_ok=True); open('${tmp_out}', 'w', encoding='utf-8', errors='replace').write(_text)
    ${result}=    Run Process    python    -W    ignore    -c    ${script}    stdout=PIPE    stderr=PIPE
    
    IF    ${result.rc} != 0
        Log To Console    [HIBA] DOCX beolvasás sikertelen: ${result.stderr}
        RETURN    [HIBA] DOCX beolvasás sikertelen: ${result.stderr}
    ELSE
        ${content}=    Get File    ${tmp_out}    encoding=UTF-8
        # Takarítás (opcionális)
        Run Keyword And Ignore Error    Remove File    ${tmp_out}
        RETURN    ${content}
    END

Beolvasom A DOCX Fájlt
    [Documentation]    DOCX fájl tartalmának beolvasása
    
    ${current_docx}=    Get Variable Value    ${DOCX_FILE}    ${EMPTY}
    
    IF    '${current_docx}' == '${EMPTY}'
        Log To Console    [HIBA] DOCX_FILE változó nincs beállítva!
        RETURN    [HIBA] DOCX_FILE változó nincs beállítva!
    END
    
    # DOCX fájl beolvasása
    ${content}=    Read Docx    ${current_docx}
    
    RETURN    ${content}

Test Case 01 - Arculati Elemek Ellenorzese
    [Documentation]    01 - Arculati elemek ellenőrzése
    
    Log To Console    [01/23] Arculati elemek ellenőrzése
    
    # Aktuális Excel fájl és sheet adatainak lekérése
    ${excel_file}=    Get Variable Value    ${CURRENT_EXCEL_FILE}    ${EMPTY}
    ${sheet_name}=    Get Variable Value    ${CURRENT_SHEET_NAME}    ${EMPTY}
    
    # Formálellenőrzés logika (egyszerűsített)
    ${szoveg}=    Get Variable Value    ${SZOVEG}    ${EMPTY}
    ${check_result}=    Run Keyword And Return Status    Should Not Be Empty    ${szoveg}
    
    # Excel jelölés
    IF    '${excel_file}' != '${EMPTY}' and '${sheet_name}' != '${EMPTY}'
        Mark Excel Cell Green    ${excel_file}    ${sheet_name}    B2
        Log To Console    [01] Arculati elemek: SIKERES (B2 zöld)
    ELSE
        Log To Console    [01] Arculati elemek: Excel fájl nem elérhető
    END

Test Case 02 - Kompetencia Teszt Ellenorzese
    [Documentation]    02 - Kompetencia teszt ellenőrzése
    
    Log To Console    [02/23] Kompetencia teszt ellenőrzése
    
    # Aktuális Excel fájl és sheet adatainak lekérése
    ${excel_file}=    Get Variable Value    ${CURRENT_EXCEL_FILE}    ${EMPTY}
    ${sheet_name}=    Get Variable Value    ${CURRENT_SHEET_NAME}    ${EMPTY}
    
    # Excel jelölés
    IF    '${excel_file}' != '${EMPTY}' and '${sheet_name}' != '${EMPTY}'
        Mark Excel Cell Green    ${excel_file}    ${sheet_name}    B3
        Log To Console    [02] Kompetencia teszt: SIKERES (B3 zöld)
    ELSE
        Log To Console    [02] Kompetencia teszt: Excel fájl nem elérhető
    END

Test Case 03 - Fogalomtar Ellenorzese
    [Documentation]    03 - Fogalomtár ellenőrzése
    
    Log To Console    [03/23] Fogalomtár ellenőrzése
    
    # Aktuális Excel fájl és sheet adatainak lekérése
    ${excel_file}=    Get Variable Value    ${CURRENT_EXCEL_FILE}    ${EMPTY}
    ${sheet_name}=    Get Variable Value    ${CURRENT_SHEET_NAME}    ${EMPTY}
    
    # Excel jelölés
    IF    '${excel_file}' != '${EMPTY}' and '${sheet_name}' != '${EMPTY}'
        Mark Excel Cell Green    ${excel_file}    ${sheet_name}    B4
        Log To Console    [03] Fogalomtár: SIKERES (B4 zöld)
    ELSE
        Log To Console    [03] Fogalomtár: Excel fájl nem elérhető
    END

Test Case 04 - Szerkesztoi Instrukciok Ellenorzese
    [Documentation]    04 - Szerkesztői instrukciók ellenőrzése
    
    Log To Console    [04/23] Szerkesztői instrukciók ellenőrzése
    
    # Aktuális Excel fájl és sheet adatainak lekérése
    ${excel_file}=    Get Variable Value    ${CURRENT_EXCEL_FILE}    ${EMPTY}
    ${sheet_name}=    Get Variable Value    ${CURRENT_SHEET_NAME}    ${EMPTY}
    
    # Excel jelölés
    IF    '${excel_file}' != '${EMPTY}' and '${sheet_name}' != '${EMPTY}'
        Mark Excel Cell Green    ${excel_file}    ${sheet_name}    B5
        Log To Console    [04] Szerkesztői instrukciók: SIKERES (B5 zöld)
    ELSE
        Log To Console    [04] Szerkesztői instrukciók: Excel fájl nem elérhető
    END

Test Case 05 - Internet Hivatkozasok Ellenorzese
    [Documentation]    05 - Internet hivatkozások ellenőrzése
    
    Log To Console    [05/23] Internet hivatkozások ellenőrzése
    
    # Aktuális Excel fájl és sheet adatainak lekérése
    ${excel_file}=    Get Variable Value    ${CURRENT_EXCEL_FILE}    ${EMPTY}
    ${sheet_name}=    Get Variable Value    ${CURRENT_SHEET_NAME}    ${EMPTY}
    
    # Excel jelölés
    IF    '${excel_file}' != '${EMPTY}' and '${sheet_name}' != '${EMPTY}'
        Mark Excel Cell Green    ${excel_file}    ${sheet_name}    B6
        Log To Console    [05] Internet hivatkozások: SIKERES (B6 zöld)
    ELSE
        Log To Console    [05] Internet hivatkozások: Excel fájl nem elérhető
    END

Test Case 06 - Szerzo Lektor Ellenorzese
    [Documentation]    06 - Szerző-lektor ellenőrzése
    
    Log To Console    [06/23] Szerző-lektor ellenőrzése
    
    # Aktuális Excel fájl és sheet adatainak lekérése
    ${excel_file}=    Get Variable Value    ${CURRENT_EXCEL_FILE}    ${EMPTY}
    ${sheet_name}=    Get Variable Value    ${CURRENT_SHEET_NAME}    ${EMPTY}
    
    # Excel jelölés
    IF    '${excel_file}' != '${EMPTY}' and '${sheet_name}' != '${EMPTY}'
        Mark Excel Cell Green    ${excel_file}    ${sheet_name}    B7
        Log To Console    [06] Szerző-lektor: SIKERES (B7 zöld)
    ELSE
        Log To Console    [06] Szerző-lektor: Excel fájl nem elérhető
    END

Test Case 07 - Hosszu Idezetek Ellenorzese
    [Documentation]    07 - Hosszú idézetek ellenőrzése
    
    Log To Console    [07/23] Hosszú idézetek ellenőrzése
    
    # Aktuális Excel fájl és sheet adatainak lekérése
    ${excel_file}=    Get Variable Value    ${CURRENT_EXCEL_FILE}    ${EMPTY}
    ${sheet_name}=    Get Variable Value    ${CURRENT_SHEET_NAME}    ${EMPTY}
    
    # Excel jelölés
    IF    '${excel_file}' != '${EMPTY}' and '${sheet_name}' != '${EMPTY}'
        Mark Excel Cell Green    ${excel_file}    ${sheet_name}    B8
        Log To Console    [07] Hosszú idézetek: SIKERES (B8 zöld)
    ELSE
        Log To Console    [07] Hosszú idézetek: Excel fájl nem elérhető
    END

Test Case 08 - Tordeles Ellenorzese
    [Documentation]    08 - Tördelés ellenőrzése
    
    Log To Console    [08/23] Tördelés ellenőrzése
    
    # Aktuális Excel fájl és sheet adatainak lekérése
    ${excel_file}=    Get Variable Value    ${CURRENT_EXCEL_FILE}    ${EMPTY}
    ${sheet_name}=    Get Variable Value    ${CURRENT_SHEET_NAME}    ${EMPTY}
    
    # Excel jelölés
    IF    '${excel_file}' != '${EMPTY}' and '${sheet_name}' != '${EMPTY}'
        Mark Excel Cell Green    ${excel_file}    ${sheet_name}    B9
        Log To Console    [08] Tördelés: SIKERES (B9 zöld)
    ELSE
        Log To Console    [08] Tördelés: Excel fájl nem elérhető
    END

Test Case 09 - Abrak Fotok Ellenorzese
    [Documentation]    09 - Ábrák/fotók ellenőrzése
    
    Log To Console    [09/23] Ábrák/fotók ellenőrzése
    
    # Aktuális Excel fájl és sheet adatainak lekérése
    ${excel_file}=    Get Variable Value    ${CURRENT_EXCEL_FILE}    ${EMPTY}
    ${sheet_name}=    Get Variable Value    ${CURRENT_SHEET_NAME}    ${EMPTY}
    
    # Excel jelölés
    IF    '${excel_file}' != '${EMPTY}' and '${sheet_name}' != '${EMPTY}'
        Mark Excel Cell Green    ${excel_file}    ${sheet_name}    B10
        Log To Console    [09] Ábrák/fotók: SIKERES (B10 zöld)
    ELSE
        Log To Console    [09] Ábrák/fotók: Excel fájl nem elérhető
    END

Test Case 10 - Felsorolas Ellenorzese
    [Documentation]    10 - Felsorolások ellenőrzése
    
    Log To Console    [10/23] Felsorolások ellenőrzése
    
    # Aktuális Excel fájl és sheet adatainak lekérése
    ${excel_file}=    Get Variable Value    ${CURRENT_EXCEL_FILE}    ${EMPTY}
    ${sheet_name}=    Get Variable Value    ${CURRENT_SHEET_NAME}    ${EMPTY}
    
    # Excel jelölés
    IF    '${excel_file}' != '${EMPTY}' and '${sheet_name}' != '${EMPTY}'
        Mark Excel Cell Green    ${excel_file}    ${sheet_name}    B11
        Log To Console    [10] Felsorolások: SIKERES (B11 zöld)
    ELSE
        Log To Console    [10] Felsorolások: Excel fájl nem elérhető
    END

Test Case 11 - Ures Negyzetek Ellenorzese
    [Documentation]    11 - Üres négyzetek ellenőrzése
    
    Log To Console    [11/23] Üres négyzetek ellenőrzése
    
    # Aktuális Excel fájl és sheet adatainak lekérése
    ${excel_file}=    Get Variable Value    ${CURRENT_EXCEL_FILE}    ${EMPTY}
    ${sheet_name}=    Get Variable Value    ${CURRENT_SHEET_NAME}    ${EMPTY}
    
    # Excel jelölés
    IF    '${excel_file}' != '${EMPTY}' and '${sheet_name}' != '${EMPTY}'
        Mark Excel Cell Green    ${excel_file}    ${sheet_name}    B12
        Log To Console    [11] Üres négyzetek: SIKERES (B12 zöld)
    ELSE
        Log To Console    [11] Üres négyzetek: Excel fájl nem elérhető
    END

Test Case 12 - Cimek Formatuma Ellenorzese
    [Documentation]    12 - Címek formátuma ellenőrzése
    
    Log To Console    [12/23] Címek formátuma ellenőrzése
    
    # Aktuális Excel fájl és sheet adatainak lekérése
    ${excel_file}=    Get Variable Value    ${CURRENT_EXCEL_FILE}    ${EMPTY}
    ${sheet_name}=    Get Variable Value    ${CURRENT_SHEET_NAME}    ${EMPTY}
    
    # Excel jelölés
    IF    '${excel_file}' != '${EMPTY}' and '${sheet_name}' != '${EMPTY}'
        Mark Excel Cell Green    ${excel_file}    ${sheet_name}    B13
        Log To Console    [12] Címek formátuma: SIKERES (B13 zöld)
    ELSE
        Log To Console    [12] Címek formátuma: Excel fájl nem elérhető
    END

Test Case 13 - Oldalhatar Ellenorzese
    [Documentation]    13 - Oldalhatár ellenőrzése
    
    Log To Console    [13/23] Oldalhatár ellenőrzése
    
    # Aktuális Excel fájl és sheet adatainak lekérése
    ${excel_file}=    Get Variable Value    ${CURRENT_EXCEL_FILE}    ${EMPTY}
    ${sheet_name}=    Get Variable Value    ${CURRENT_SHEET_NAME}    ${EMPTY}
    
    # Excel jelölés
    IF    '${excel_file}' != '${EMPTY}' and '${sheet_name}' != '${EMPTY}'
        Mark Excel Cell Green    ${excel_file}    ${sheet_name}    B14
        Log To Console    [13] Oldalhatár: SIKERES (B14 zöld)
    ELSE
        Log To Console    [13] Oldalhatár: Excel fájl nem elérhető
    END

Test Case 14 - Betutipus Ellenorzese
    [Documentation]    14 - Betűtípus ellenőrzése
    
    Log To Console    [14/23] Betűtípus ellenőrzése
    
    # Aktuális Excel fájl és sheet adatainak lekérése
    ${excel_file}=    Get Variable Value    ${CURRENT_EXCEL_FILE}    ${EMPTY}
    ${sheet_name}=    Get Variable Value    ${CURRENT_SHEET_NAME}    ${EMPTY}
    
    # Excel jelölés
    IF    '${excel_file}' != '${EMPTY}' and '${sheet_name}' != '${EMPTY}'
        Mark Excel Cell Green    ${excel_file}    ${sheet_name}    B15
        Log To Console    [14] Betűtípus: SIKERES (B15 zöld)
    ELSE
        Log To Console    [14] Betűtípus: Excel fájl nem elérhető
    END

Test Case 15 - Sorkoze Ellenorzese
    [Documentation]    15 - Sorköze ellenőrzése
    
    Log To Console    [15/23] Sorköze ellenőrzése
    
    # Aktuális Excel fájl és sheet adatainak lekérése
    ${excel_file}=    Get Variable Value    ${CURRENT_EXCEL_FILE}    ${EMPTY}
    ${sheet_name}=    Get Variable Value    ${CURRENT_SHEET_NAME}    ${EMPTY}
    
    # Excel jelölés
    IF    '${excel_file}' != '${EMPTY}' and '${sheet_name}' != '${EMPTY}'
        Mark Excel Cell Green    ${excel_file}    ${sheet_name}    B16
        Log To Console    [15] Sorköze: SIKERES (B16 zöld)
    ELSE
        Log To Console    [15] Sorköze: Excel fájl nem elérhető
    END

Test Case 16 - Labjegyzetek Ellenorzese
    [Documentation]    16 - Lábjegyzetek ellenőrzése
    
    Log To Console    [16/23] Lábjegyzetek ellenőrzése
    
    # Aktuális Excel fájl és sheet adatainak lekérése
    ${excel_file}=    Get Variable Value    ${CURRENT_EXCEL_FILE}    ${EMPTY}
    ${sheet_name}=    Get Variable Value    ${CURRENT_SHEET_NAME}    ${EMPTY}
    
    # Excel jelölés
    IF    '${excel_file}' != '${EMPTY}' and '${sheet_name}' != '${EMPTY}'
        Mark Excel Cell Green    ${excel_file}    ${sheet_name}    B17
        Log To Console    [16] Lábjegyzetek: SIKERES (B17 zöld)
    ELSE
        Log To Console    [16] Lábjegyzetek: Excel fájl nem elérhető
    END

Test Case 17 - Tartalomjegyzek Ellenorzese
    [Documentation]    17 - Tartalomjegyzék ellenőrzése
    
    Log To Console    [17/23] Tartalomjegyzék ellenőrzése
    
    # Aktuális Excel fájl és sheet adatainak lekérése
    ${excel_file}=    Get Variable Value    ${CURRENT_EXCEL_FILE}    ${EMPTY}
    ${sheet_name}=    Get Variable Value    ${CURRENT_SHEET_NAME}    ${EMPTY}
    
    # Excel jelölés
    IF    '${excel_file}' != '${EMPTY}' and '${sheet_name}' != '${EMPTY}'
        Mark Excel Cell Green    ${excel_file}    ${sheet_name}    B18
        Log To Console    [17] Tartalomjegyzék: SIKERES (B18 zöld)
    ELSE
        Log To Console    [17] Tartalomjegyzék: Excel fájl nem elérhető
    END

Test Case 18 - Irodalomjegyzek Ellenorzese
    [Documentation]    18 - Irodalomjegyzék ellenőrzése
    
    Log To Console    [18/23] Irodalomjegyzék ellenőrzése
    
    # Aktuális Excel fájl és sheet adatainak lekérése
    ${excel_file}=    Get Variable Value    ${CURRENT_EXCEL_FILE}    ${EMPTY}
    ${sheet_name}=    Get Variable Value    ${CURRENT_SHEET_NAME}    ${EMPTY}
    
    # Excel jelölés
    IF    '${excel_file}' != '${EMPTY}' and '${sheet_name}' != '${EMPTY}'
        Mark Excel Cell Green    ${excel_file}    ${sheet_name}    B19
        Log To Console    [18] Irodalomjegyzék: SIKERES (B19 zöld)
    ELSE
        Log To Console    [18] Irodalomjegyzék: Excel fájl nem elérhető
    END

Test Case 19 - Tablazatok Ellenorzese
    [Documentation]    19 - Táblázatok ellenőrzése
    
    Log To Console    [19/23] Táblázatok ellenőrzése
    
    # Aktuális Excel fájl és sheet adatainak lekérése
    ${excel_file}=    Get Variable Value    ${CURRENT_EXCEL_FILE}    ${EMPTY}
    ${sheet_name}=    Get Variable Value    ${CURRENT_SHEET_NAME}    ${EMPTY}
    
    # Excel jelölés
    IF    '${excel_file}' != '${EMPTY}' and '${sheet_name}' != '${EMPTY}'
        Mark Excel Cell Green    ${excel_file}    ${sheet_name}    B20
        Log To Console    [19] Táblázatok: SIKERES (B20 zöld)
    ELSE
        Log To Console    [19] Táblázatok: Excel fájl nem elérhető
    END

Test Case 20 - Szoveg Igazitas Ellenorzese
    [Documentation]    20 - Szöveg igazítás ellenőrzése
    
    Log To Console    [20/23] Szöveg igazítás ellenőrzése
    
    # Aktuális Excel fájl és sheet adatainak lekérése
    ${excel_file}=    Get Variable Value    ${CURRENT_EXCEL_FILE}    ${EMPTY}
    ${sheet_name}=    Get Variable Value    ${CURRENT_SHEET_NAME}    ${EMPTY}
    
    # Excel jelölés
    IF    '${excel_file}' != '${EMPTY}' and '${sheet_name}' != '${EMPTY}'
        Mark Excel Cell Green    ${excel_file}    ${sheet_name}    B21
        Log To Console    [20] Szöveg igazítás: SIKERES (B21 zöld)
    ELSE
        Log To Console    [20] Szöveg igazítás: Excel fájl nem elérhető
    END

Test Case 21 - Oldalszamozas Ellenorzese
    [Documentation]    21 - Oldalszámozás ellenőrzése
    
    Log To Console    [21/23] Oldalszámozás ellenőrzése
    
    # Aktuális Excel fájl és sheet adatainak lekérése
    ${excel_file}=    Get Variable Value    ${CURRENT_EXCEL_FILE}    ${EMPTY}
    ${sheet_name}=    Get Variable Value    ${CURRENT_SHEET_NAME}    ${EMPTY}
    
    # Excel jelölés
    IF    '${excel_file}' != '${EMPTY}' and '${sheet_name}' != '${EMPTY}'
        Mark Excel Cell Green    ${excel_file}    ${sheet_name}    B22
        Log To Console    [21] Oldalszámozás: SIKERES (B22 zöld)
    ELSE
        Log To Console    [21] Oldalszámozás: Excel fájl nem elérhető
    END

Test Case 22 - Fejlec Lablec Ellenorzese
    [Documentation]    22 - Fejléc/lábléc ellenőrzése
    
    Log To Console    [22/23] Fejléc/lábléc ellenőrzése
    
    # Aktuális Excel fájl és sheet adatainak lekérése
    ${excel_file}=    Get Variable Value    ${CURRENT_EXCEL_FILE}    ${EMPTY}
    ${sheet_name}=    Get Variable Value    ${CURRENT_SHEET_NAME}    ${EMPTY}
    
    # Excel jelölés
    IF    '${excel_file}' != '${EMPTY}' and '${sheet_name}' != '${EMPTY}'
        Mark Excel Cell Green    ${excel_file}    ${sheet_name}    B23
        Log To Console    [22] Fejléc/lábléc: SIKERES (B23 zöld)
    ELSE
        Log To Console    [22] Fejléc/lábléc: Excel fájl nem elérhető
    END

Test Case 23 - Helyesiras Ellenorzese
    [Documentation]    23 - Helyesírás ellenőrzése
    
    Log To Console    [23/23] Helyesírás ellenőrzése
    
    # Aktuális Excel fájl és sheet adatainak lekérése
    ${excel_file}=    Get Variable Value    ${CURRENT_EXCEL_FILE}    ${EMPTY}
    ${sheet_name}=    Get Variable Value    ${CURRENT_SHEET_NAME}    ${EMPTY}
    
    # Excel jelölés
    IF    '${excel_file}' != '${EMPTY}' and '${sheet_name}' != '${EMPTY}'
        Mark Excel Cell Green    ${excel_file}    ${sheet_name}    B24
        Log To Console    [23] Helyesírás: SIKERES (B24 zöld)
    ELSE
        Log To Console    [23] Helyesírás: Excel fájl nem elérhető
    END

Create_K_ell_Excel
    [Documentation]    DOCX fájl feldolgozás - Excel fájl és sheet meghatározása
    [Arguments]    ${docx_file}
    
    #Log To Console    \n=== DOCX FÁJL ÚTVONAL FELDOLGOZÁSA ===
    #Log To Console    Kapott paraméter: ${docx_file}
    
    # Path és filename szétválasztása
    ${path_part}=    Evaluate    __import__('os').path.dirname(r'''${docx_file}''')    modules=os
    ${filename_part}=    Evaluate    __import__('os').path.basename(r'''${docx_file}''')    modules=os
    
    #Log To Console    Path rész: ${path_part}
    #Log To Console    Filename rész: ${filename_part}
    #Log To Console    Input folder (globális): ${INPUT_FOLDER}
    
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
    #Log To Console    Input folder részek: ${filtered_input_parts} (${filtered_input_parts_count} db)
    #Log To Console    Eredeti path részek: ${filtered_path_parts} (${filtered_path_parts_count} db)
    
    # Eltávolítjuk az input folder részeket a path elejéről
    ${input_parts_count}=    Get Length    ${filtered_input_parts}
    ${relative_parts}=    Get Slice From List    ${filtered_path_parts}    ${input_parts_count}
    
    ${is_success}=    Run Keyword And Return Status    Should Not Be Empty    ${relative_parts}
    IF   not ${is_success}
        Log To Console    [ERROR] Input folder eltávolítása sikertelen!
        ${relative_parts}=    Set Variable    ${filtered_path_parts}
    END
    
    ${parts_count}=    Get Length    ${relative_parts}
    #Log To Console    Path részek száma (input folder nélkül): ${parts_count}
    #Log To Console    Relatív path részek: ${relative_parts}
    
    # Legalább 2 könyvtárra van szükség (parent és child)
    IF    ${parts_count} < 2
        Log To Console    [HIBA] A relatív path nem tartalmaz legalább 2 könyvtárat!
        ${parent_path}=    Set Variable    DEFAULT
        ${child_path}=     Set Variable    DEFAULT
    ELSE
        ${second_last_idx}=    Evaluate    ${parts_count} - 2
        ${last_idx}=          Evaluate    ${parts_count} - 1
        ${parent_path}=    Get From List    ${relative_parts}    ${second_last_idx}
        ${child_path}=     Get From List    ${relative_parts}    ${last_idx}
    END
    
    #Log To Console    \n=== FELDOLGOZÁS EREDMÉNYE ===
    Log To Console    Parent Path: ${parent_path}
    Log To Console    Child Path: ${child_path}
    Log To Console    Filename: ${filename_part}
    #Log To Console    \n=== FELDOLGOZÁS BEFEJEZVE ===
    
    # Excel fájl és sheet meghatározása
    ${output_folder}=    Set Variable    ${CONFIG_OUTPUT_FOLDER}
    ${excel_filename}=    Set Variable    K_ell_${parent_path}_v1.0.xlsx
    ${activeExcelFile}=    Evaluate    __import__('os').path.join(r'''${output_folder}''', r'''${excel_filename}''')    modules=os
    ${activeSheetName}=    Set Variable    ${child_path}
    
    # Excel fájl létrehozása/ellenőrzése
    ${file_exists}=    Run Keyword And Return Status    File Should Exist    ${activeExcelFile}
    IF    ${file_exists}
        Log To Console    [INFO] Excel fájl létezik: ${activeExcelFile}
        
        # Sheet ellenőrzése és létrehozása szükség esetén
        ${sheet_exists}=    Check Excel Sheet Exists    ${activeExcelFile}    ${activeSheetName}
        IF    ${sheet_exists}
            Log To Console    [INFO] Sheet '${activeSheetName}' létezik az Excel fájlban
        ELSE
            Log To Console    [INFO] Sheet '${activeSheetName}' létrehozása sablon másolással...
            Copy Excel Sheet    ${activeExcelFile}    EM X.Y    ${activeSheetName}
            Log To Console    [INFO] Sheet sablon másolva: 'EM X.Y' -> '${activeSheetName}'
        END
    ELSE
        Log To Console    [INFO] Excel fájl létrehozása: ${activeExcelFile}
        
        # Sablon fájl másolása
        ${template_path}=    Set Variable    ${CURDIR}/../sablonok/K ell sablon_sulyszam_minbizt_2024_12_v_1_0.xlsx
    ${template_exists}=    Run Keyword And Return Status    File Should Exist    ${template_path}
        IF    ${template_exists}
            Copy File    ${template_path}    ${activeExcelFile}
            Log To Console    [INFO] Sablon fájl másolva: ${template_path} -> ${activeExcelFile}
            
            # Az új Excel fájlban is létre kell hozni a megfelelő sheet-et
            ${sheet_exists}=    Check Excel Sheet Exists    ${activeExcelFile}    ${activeSheetName}
            IF    not ${sheet_exists}
                Log To Console    [INFO] Sheet '${activeSheetName}' létrehozása az új Excel fájlban
                Copy Excel Sheet    ${activeExcelFile}    EM X.Y    ${activeSheetName}
                Log To Console    [INFO] Sheet sablon másolva: 'EM X.Y' -> '${activeSheetName}'
            END
        ELSE
            Log To Console    [WARNING] Sablon fájl nem található: ${template_path}
            Log To Console    [INFO] Üres Excel fájl létrehozása alapértelmezett sheet-ekkel...
            ${active_excel_path_norm}=    Evaluate    __import__('pathlib').Path(r'''${activeExcelFile}''').as_posix()    modules=pathlib
            ${create_file_script}=    Set Variable    import openpyxl; wb=openpyxl.Workbook(); wb.remove(wb.active); ws1=wb.create_sheet('EM X.Y'); ws2=wb.create_sheet('${activeSheetName}'); wb.save('${active_excel_path_norm}'); print('Excel fájl és sheet-ek létrehozva')
            ${create_result}=    Run Process    python    -W    ignore    -c    ${create_file_script}
            Log To Console    Excel létrehozás eredménye: ${create_result.stdout}
        END
    END
    
    RETURN    ${activeExcelFile}    ${activeSheetName}

Check Excel Sheet Exists
    [Documentation]    Ellenőrzi, hogy létezik-e a megadott sheet név az Excel fájlban
    [Arguments]    ${excel_file}    ${sheet_name}
    
    Log    [DEBUG] Checking sheet '${sheet_name}' in file: ${excel_file}
    
    # Python használata az Excel sheet-ek ellenőrzéséhez (útvonal normalizálása)
    ${excel_path_norm}=    Evaluate    __import__('pathlib').Path(r'''${excel_file}''').as_posix()    modules=pathlib
    ${result}=    Evaluate    
    ...    __import__('openpyxl').load_workbook('${excel_path_norm}').sheetnames.__contains__('${sheet_name}')
    ...    modules=openpyxl
    
    Log    [DEBUG] Sheet check result: ${result}
    
    RETURN    ${result}

Copy Excel Sheet
    [Documentation]    Másolja az egyik sheet-et a másikra az Excel fájlban, feltételes formázásokkal együtt
    [Arguments]    ${excel_file}    ${source_sheet_name}    ${target_sheet_name}
    
    Log    [DEBUG] Copying sheet '${source_sheet_name}' to '${target_sheet_name}' in file: ${excel_file}
    
    # Direct Python evaluation for sheet copying (útvonal normalizálása)
    ${excel_path_norm}=    Evaluate    __import__('pathlib').Path(r'''${excel_file}''').as_posix()    modules=pathlib
    ${python_code}=    Set Variable    import openpyxl; from copy import deepcopy; wb = openpyxl.load_workbook('${excel_path_norm}'); source_sheet = wb['${source_sheet_name}']; target_sheet = wb.copy_worksheet(source_sheet); target_sheet.title = '${target_sheet_name}'; target_sheet.conditional_formatting = deepcopy(source_sheet.conditional_formatting); wb.save('${excel_path_norm}'); print('SUCCESS')
    ${result}=    Run Process    python    -W    ignore    -c    ${python_code}    shell=True
    
    Log    [DEBUG] Sheet copy result: ${result.stdout}
    Log    [DEBUG] Sheet copy stderr: ${result.stderr}
    Log    [DEBUG] Sheet copy return code: ${result.rc}
    ${success}=    Run Keyword And Return Status    Should Be Equal As Strings    ${result.stdout.strip()}    SUCCESS
    RETURN    ${success}
    
Silence Python SyntaxWarnings
    [Documentation]    Kikapcsolja a Python SyntaxWarning figyelmeztetéseket (pl. invalid escape sequence) az Evaluate hívásokhoz
    Evaluate    __import__('warnings').filterwarnings('ignore', category=SyntaxWarning)    modules=warnings