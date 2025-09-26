*** Keywords ***

Initialize Global Log File
    [Documentation]    Inicializálja a globális log fájl nevét a futás elején a gyökérkönyvtárban
    ${current_datetime}=    Get Current Date    result_format=%Y%m%d_%H%M%S
    ${log_filename_only}=    Set Variable    TempLog_${current_datetime}.log
    # Kezdetben a gyökérkönyvtárban hozzuk létre ideiglenes névvel
    Set Global Variable    ${GLOBAL_LOG_FILENAME}    ${log_filename_only}
    Set Global Variable    ${LOG_FILENAME_ONLY}    ${log_filename_only}
    Log To Console    Globális log fájl inicializálva: ${log_filename_only}

Update Log File Name With Database
    [Documentation]    Frissíti a log fájl nevét az adatbázis neve alapján a konfiguráció betöltése után
    ${current_datetime}=    Get Current Date    result_format=%Y%m%d_%H%M%S
    # Az adatbázis fájl nevének kivonása útvonal nélkül
    ${db_file_only}=    Evaluate    __import__('os').path.basename(r'${SQLITE_DB_FILE}')    modules=os
    # .db kiterjesztés eltávolítása
    ${db_name_only}=    Replace String    ${db_file_only}    .db    ${EMPTY}
    ${log_filename_only}=    Set Variable    ${db_name_only}_${current_datetime}.log
    Set Global Variable    ${LOG_FILENAME_ONLY}    ${log_filename_only}
    Log To Console    Log fájl neve frissítve: ${log_filename_only}

Move Log File To Output Folder
    [Documentation]    Áthelyezi a log fájlt az output könyvtárba a konfiguráció betöltése után
    ${output_folder}=    Get Variable Value    ${CONFIG_OUTPUT_FOLDER}    .
    ${log_filename_only}=    Get Variable Value    ${LOG_FILENAME_ONLY}    TempLog_unknown.log
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
    [Arguments]    ${msg}    ${no_newline}=False
    [Documentation]    Logs message both to console and to timestamped log file
    # Buffered console output: no_newline=True esetén gyűjtjük és csak minden 100. üzenetnél flush-oljuk
    ${buffer_exists}=    Run Keyword And Return Status    Variable Should Exist    ${CONSOLE_BUFFER}
    IF    not ${buffer_exists}
        ${CONSOLE_BUFFER}=    Create List
        ${CONSOLE_BUFFER_COUNT}=    Set Variable    0
        Set Suite Variable    ${CONSOLE_BUFFER}
        Set Suite Variable    ${CONSOLE_BUFFER_COUNT}
    END
    IF    ${no_newline}
        Append To List    ${CONSOLE_BUFFER}    ${msg}
        ${CONSOLE_BUFFER_COUNT}=    Evaluate    ${CONSOLE_BUFFER_COUNT} + 1
        Set Suite Variable    ${CONSOLE_BUFFER_COUNT}
        ${should_flush}=    Evaluate    ${CONSOLE_BUFFER_COUNT} % 100 == 0
        IF    ${should_flush}
            ${joined}=    Catenate    SEPARATOR=    @{CONSOLE_BUFFER}
            Log To Console    ${joined}
            # File log flush handled below (treated as normal line)
            ${CONSOLE_BUFFER}=    Create List
            Set Suite Variable    ${CONSOLE_BUFFER}
            # Számláló nullázása a 100-as flush után
            ${CONSOLE_BUFFER_COUNT}=    Set Variable    0
            Set Suite Variable    ${CONSOLE_BUFFER_COUNT}
        ELSE
            # Korai visszatérés: még nem flush-olunk, de a fájlba sem írunk részleges puffert
            RETURN
        END
    ELSE
        # Normál (newline) üzenet előtt flush, ha van felgyűlt puffer
        ${has_buffer_items}=    Evaluate    len(${CONSOLE_BUFFER}) > 0 if ${buffer_exists} else False
        IF    ${has_buffer_items}
            ${joined}=    Catenate    SEPARATOR=    @{CONSOLE_BUFFER}
            Log To Console    ${joined}
            ${CONSOLE_BUFFER}=    Create List
            Set Suite Variable    ${CONSOLE_BUFFER}
            # Számláló nullázása normál flush esetén
            ${CONSOLE_BUFFER_COUNT}=    Set Variable    0
            Set Suite Variable    ${CONSOLE_BUFFER_COUNT}
        END
        Log To Console    ${msg}
    END
    
    # Skip logging TRACE messages to file
    ${is_trace}=    Run Keyword And Return Status    Should Contain    ${msg}    [TRACE]
    IF    ${is_trace}
        Return From Keyword
    END
    
    # Use the global log filename (should already be set by Initialize Global Log File)
    ${log_filename_exists}=    Run Keyword And Return Status    Variable Should Exist    ${GLOBAL_LOG_FILENAME}
    IF    ${log_filename_exists}
        # Append to log file without timestamp (with or without newline based on parameter)
        # Ha most flush történt (no_newline ciklus 100-adik eleme vagy normál sor előtt puffer flush), már Log To Console kiírta a teljes buffert.
        # Ebben az esetben az utolsó "joined" tartalom a konzolra ment. A fájl számára ugyanazt a logikát követjük.
        ${has_buffer_items_after}=    Run Keyword And Return Status    Variable Should Exist    ${CONSOLE_BUFFER}
        ${buffer_len}=    Run Keyword If    ${has_buffer_items_after}    Evaluate    len(${CONSOLE_BUFFER})    ELSE    Set Variable    0
        # Ha no_newline ágon korai RETURN történt, ide nem jutunk, tehát csak flush esetén vagy normál sor esetén érünk ide.
        IF    ${no_newline}
            # Ez flush utáni állapot: a puffer már kiürítve, a kiírt tartalom a ${joined} volt.
            # A joined változó lokális lehet, ha nem létezne (védjük):
            ${joined_exists}=    Run Keyword And Return Status    Variable Should Exist    ${joined}
            IF    ${joined_exists}
                Append To File    ${GLOBAL_LOG_FILENAME}    ${joined}\n
            ELSE
                Append To File    ${GLOBAL_LOG_FILENAME}    ${msg}\n
            END
        ELSE
            Append To File    ${GLOBAL_LOG_FILENAME}    ${msg}\n
        END
    END

Flush Console Buffer
    [Documentation]    Kézi flush: kiírja a felgyűlt no_newline buffer tartalmát (ha van) és üríti a puffert.
    ${buffer_exists}=    Run Keyword And Return Status    Variable Should Exist    ${CONSOLE_BUFFER}
    IF    ${buffer_exists}
        ${has_items}=    Evaluate    len(${CONSOLE_BUFFER}) > 0
        IF    ${has_items}
            ${joined}=    Catenate    SEPARATOR=    @{CONSOLE_BUFFER}
            Log To Console    ${joined}
            ${log_filename_exists}=    Run Keyword And Return Status    Variable Should Exist    ${GLOBAL_LOG_FILENAME}
            IF    ${log_filename_exists}
                Append To File    ${GLOBAL_LOG_FILENAME}    ${joined}\n
            END
            ${CONSOLE_BUFFER}=    Create List
            Set Suite Variable    ${CONSOLE_BUFFER}
            # Számláló nullázása manuális flush után
            ${count_exists}=    Run Keyword And Return Status    Variable Should Exist    ${CONSOLE_BUFFER_COUNT}
            IF    ${count_exists}
                ${CONSOLE_BUFFER_COUNT}=    Set Variable    0
                Set Suite Variable    ${CONSOLE_BUFFER_COUNT}
            END
        END
    END

Process Config Line
    #Log String To Console    [TRACE] Process Config Line elindult
    [Arguments]    ${config_line}
    @{config_parts}=    Split String    ${config_line}    |
    ${parts_len}=    Get Length    ${config_parts}
    IF    ${parts_len} < 6
        Fail    Konfigurációs sor hibás vagy hiányos: ${config_line}
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
Library    DatabaseLibrary
Library    DateTime
Library    Process
Library    OperatingSystem
Resource   variables.robot
Resource   ../PLG-02-read_docx.robot
Resource   get_file_size.resource
Resource   ../PLG-03-rename_docx.robot


*** Keywords ***

Get Config Icon
    #Log String To Console    [TRACE] Get Config Icon elindult
    [Documentation]    Ikonok tiltva: mindig üres string
    [Arguments]    ${icon_name}
    RETURN    ${EMPTY}
    #Log String To Console    [TRACE] Get Config Icon kilépett

Konfiguráció Betöltése
    #Log String To Console    [TRACE] Konfiguráció Betöltése elindult
    [Documentation]    Plagium.config fajl betoltese es beallitasok alkalmazasa
    Log String To Console    \nKONFIGURACIO BETOLTESE...
    Log String To Console    ═══════════════════════════════
    # Konfiguracios fajl olvasasa Python scripttel
    ${config_result}=    Run Process    python    libraries/get_config.py    shell=True
    IF    ${config_result.rc} == 0
        ${config_line}=    Set Variable    ${config_result.stdout.strip()}
    #Log To Console    [DEBUG] config_line: ${config_line}
        Run Keyword If    '${config_line}' != '' and '${config_line}' != 'None'    Process Config Line    ${config_line}
    Run Keyword If    '${config_line}' == '' or '${config_line}' == 'None'    Log String To Console    [HIBA] Üres vagy None config_line, Split String kihagyva!
        Run Keyword Unless    '${config_line}' != '' and '${config_line}' != 'None'    Fail    Konfigurációs sor hibás vagy hiányos: ${config_line}
    # Az adatbázis elérési útját ténylegesen kiértékeljük Pythonból
    ${abs_lib_path}=    Evaluate    __import__('os').path.abspath('libraries')    modules=os
    ${py_cmd}=    Set Variable    import sys; sys.path.insert(0, r'${abs_lib_path}'); from duplikacio_config import DuplikacioConfig; print(DuplikacioConfig().get_database_file())
    ${db_path_result}=    Run Process    python    -c    ${py_cmd}    shell=True
    @{db_path_lines}=    Split To Lines    ${db_path_result.stdout}
    ${db_path}=    Get From List    ${db_path_lines}    -1
    Set Global Variable    ${SQLITE_DB_FILE}    ${db_path.strip()}
    # Log fájl nevének frissítése az adatbázis neve alapján
    Update Log File Name With Database
    ELSE
    Log String To Console    Hiba a konfiguracio betoltesekor, alapertelmezettek hasznalata
    Log String To Console    Hibauzenet: ${config_result.stderr}
    END
    Log String To Console    ${EMPTY}
    Log String To Console    ═══════════KONFIGURACIO BETOLTESE KÉSZ════════════════════
    #Log To Console    [TRACE] Konfiguráció Betöltése kilépett



Beolvasom A DOCX Fájlt
    ${szoveg}=    Read Docx    ${DOCX_FILE}

    Set Global Variable    ${DOCX_TEXT}    ${szoveg}
    ${is_error}=    Run Keyword And Return Status    Should Start With    ${szoveg}    [HIBA]
    Return From Keyword    ${szoveg}
    #Log To Console    [TRACE] Beolvasom A DOCX Fájlt kilépett

Kapcsolodas Az Adatbazishoz
    #Log String To Console    [TRACE] Kapcsolodas Az Adatbazishoz elindult
    [Documentation]    SQLite adatbázishoz kapcsolódás
    # Mindig bontsunk előző kapcsolatot, hogy ne legyen "Overwriting not closed connection" warning
    Run Keyword And Ignore Error    Disconnect From Database
    IF    '${DB_MODULE}' == 'sqlite3'
        Connect To Database    sqlite3    ${DB_NAME}
    Log String To Console    Sikeres kapcsolódás az SQLite adatbázishoz: ${DB_NAME}
    ELSE IF    '${DB_MODULE}' == 'pyodbc'
        ${connection_string}=    Set Variable    DRIVER={SQL Server};SERVER=${DB_HOST};DATABASE=${DB_NAME};UID=${DB_USERNAME};PWD=${DB_PASSWORD};
    Log String To Console    ODBC Connection string: ${connection_string}
        Connect To Database    pyodbc    ${connection_string}
    Log String To Console    Sikeres kapcsolódás az MSSQL adatbázishoz
    ELSE
        Connect To Database    ${DB_MODULE}    ${DB_NAME}    ${DB_USERNAME}    ${DB_PASSWORD}    ${DB_HOST}    ${DB_PORT}
    Log String To Console    Sikeres kapcsolódás az adatbázishoz
    END
    #Log To Console    [TRACE] Kapcsolodas Az Adatbazishoz kilépett

Adatbazis Kapcsolat Bezarasa
    #Log String To Console    [TRACE] Adatbazis Kapcsolat Bezarasa elindult
    [Documentation]    Adatbázis kapcsolat bezárása
    Run Keyword And Ignore Error    Disconnect From Database
    Log String To Console    Adatbázis kapcsolat bezárva
    #Log String To Console    [TRACE] Adatbazis Kapcsolat Bezarasa kilépett

Hash táblák ellenőrzése
    #Log String To Console    [TRACE] Hash táblák ellenőrzése elindult
    [Documentation]    Egyszerű SQLite adatbázis teszt amely ténylegesen működik
    [Tags]    database    sqlite    working
    
    # Régi adatbázis törlése ha létezik
    #${file_exists}=    Run Keyword And Return Status    File Should Exist    ${SQLITE_DB_FILE}
    #Run Keyword If    ${file_exists}    Remove File    ${SQLITE_DB_FILE}
    
    # redundancia tábla létrehozása ha nem létezik (elsőként, mivel ez lesz a fő tábla)
    Log String To Console    CREATE TABLE IF NOT EXISTS redundancia
    Execute Sql String    CREATE TABLE IF NOT EXISTS redundancia (id INTEGER PRIMARY KEY AUTOINCREMENT, status TEXT DEFAULT 'Rendben', file_path TEXT, file_name TEXT NOT NULL, file_size INTEGER NOT NULL, line_number INTEGER DEFAULT 0, repeat_block_nbr INTEGER DEFAULT 0, max_ismetlesek_szama INTEGER DEFAULT 0, max_ismetelt_karakterszam INTEGER DEFAULT 0, repeated_percent REAL DEFAULT 0, overview TEXT DEFAULT '', record_date TEXT NOT NULL, record_time TEXT NOT NULL)
    Execute Sql String    CREATE INDEX IF NOT EXISTS idx_redundancia_id ON redundancia(id)
    Execute Sql String    CREATE INDEX IF NOT EXISTS idx_redundancia_file ON redundancia(file_name, file_path)
    
    # hashCodes tábla létrehozása ha nem létezik foreign key kapcsolattal és külön file_name, file_path oszlopokkal (document_name nélkül)
    Log String To Console    CREATE TABLE IF NOT EXISTS hashCodes
    Execute Sql String    CREATE TABLE IF NOT EXISTS hashCodes (hash_value TEXT(100) PRIMARY KEY, file_path TEXT NOT NULL, file_name TEXT NOT NULL, created_date TEXT NOT NULL, created_time TEXT NOT NULL, used_by_nbr INTEGER DEFAULT 1, skipp BOOLEAN DEFAULT FALSE, line_content TEXT, redundancia_id INTEGER, FOREIGN KEY (redundancia_id) REFERENCES redundancia(id))
    Execute Sql String    CREATE INDEX IF NOT EXISTS idx_hashCodes_file ON hashCodes(file_name, file_path)
    
    # repeat tábla létrehozása ha nem létezik - az ismételt sorok tárolására
    Log String To Console    CREATE TABLE IF NOT EXISTS repeat
    Execute Sql String    CREATE TABLE IF NOT EXISTS repeat (id INTEGER PRIMARY KEY AUTOINCREMENT, file_name TEXT NOT NULL, file_path TEXT NOT NULL, source_file_path TEXT, source_file_name TEXT NOT NULL, redundancia_id INTEGER, repeat_block_nbr INTEGER DEFAULT 0, block_id INTEGER NOT NULL, line_length INTEGER NOT NULL, repeated_line TEXT NOT NULL, token TEXT, created_date TEXT NOT NULL, created_time TEXT NOT NULL, FOREIGN KEY (redundancia_id) REFERENCES redundancia(id))
    Execute Sql String    CREATE INDEX IF NOT EXISTS idx_repeat_file ON repeat(file_name, file_path)
    Execute Sql String    CREATE INDEX IF NOT EXISTS idx_repeat_redundancia_id ON repeat(redundancia_id)
    Execute Sql String    CREATE INDEX IF NOT EXISTS idx_repeat_block_id ON repeat(block_id)
    Execute Sql String    CREATE INDEX IF NOT EXISTS idx_repeat_id ON repeat(id)
    
    # DuplikacioSkip.config fájl beolvasása és hashCodes táblába töltése skipp=TRUE értékkel
    ${skip_config_file}=    Set Variable    DuplikacioSkip.config
    ${skip_file_exists}=    Run Keyword And Return Status    File Should Exist    ${skip_config_file}
    IF    ${skip_file_exists}
        Log String To Console    DuplikacioSkip.config betöltése...
        ${skip_content}=    Get File    ${skip_config_file}
        @{skip_lines}=    Split To Lines    ${skip_content}
        FOR    ${skip_line}    IN    @{skip_lines}
            ${skip_line_trimmed}=    Strip String    ${skip_line}
            # Üres sorok kihagyása
            IF    '${skip_line_trimmed}' != ''
                #Log String To Console    Átlépés: ${skip_line_trimmed}
                # átlépendő sorok beírása a hashCodes táblába
                ${escaped_sor}=    Replace String    ${skip_line_trimmed}    '    ''
                ${escaped_sor}=    Replace String    ${escaped_sor}    "    ""  # dupla idézőjel escape
                ${escaped_sor}=    Replace String    ${escaped_sor}    \n    ${EMPTY}
                ${escaped_sor}=    Replace String    ${escaped_sor}    \r    ${EMPTY}
                ${escaped_sor}=    Replace String    ${escaped_sor}    \t    ${EMPTY}
            
                ${tomoritett}=    Replace String Using Regexp    ${escaped_sor}    [^a-zA-Z0-9áéíóöőúüűÁÉÍÓÖŐÚÜŰ]    ${EMPTY}
              
                # Escape all problematic characters before Evaluate (replace with empty string)
                ${tomoritett_safe}=    Replace String    ${tomoritett}    '    ${EMPTY}
                ${tomoritett_safe}=    Replace String    ${tomoritett_safe}    "    ${EMPTY}
                ${tomoritett_safe}=    Replace String    ${tomoritett_safe}    \n    ${EMPTY}
                ${tomoritett_safe}=    Replace String    ${tomoritett_safe}    \r    ${EMPTY}
                ${tomoritett_safe}=    Replace String    ${tomoritett_safe}    \t    ${EMPTY}
        
                #MD5 érték számolása
                ${md5}=    Evaluate    hashlib.md5(r'${tomoritett_safe}'.encode('utf-8')).hexdigest()    modules=hashlib
            
               #Beírjuk a hash táblába
               ${file_name}=    Evaluate    os.path.basename(r'${skip_config_file}')    modules=os
               ${file_path}=    Evaluate    os.path.dirname(r'${skip_config_file}')    modules=os
                ${created_date}=    Evaluate    __import__('datetime').datetime.now().strftime('%Y-%m-%d')
                ${created_time}=    Evaluate    __import__('datetime').datetime.now().strftime('%H:%M:%S')
                ${REDUNDANCIA_ID}=    Set Variable    0
                #Run Keyword And Ignore Error    Execute Sql String    INSERT INTO hashCodes (hash_value, file_name, file_path, created_date, created_time, used_by_nbr, skipp, line_content, redundancia_id) VALUES ('${md5}', '${file_name_esc}', '${file_path_esc}', '${created_date}', '${created_time}', 0, TRUE, '${escaped_sor}', ${REDUNDANCIA_ID})
                Run Keyword And Ignore Error    Execute Sql String    INSERT OR IGNORE INTO hashCodes (hash_value, file_name, file_path, created_date, created_time, used_by_nbr, skipp, line_content, redundancia_id) VALUES ('${md5}', '${file_name}', '${file_path}', '${created_date}', '${created_time}', 0, TRUE, '${escaped_sor}', ${REDUNDANCIA_ID})
                #Log String To Console      ${file_path}/${file_name} - ${md5} - ${escaped_sor}    
            END
        END
        ${skip_count}=    Get Length    ${skip_lines}
        Log String To Console    DuplikacioSkip.config betöltve: ${skip_count} sor feldolgozva
    ELSE
        Log String To Console    DuplikacioSkip.config fájl nem található, skip táblát üresen hagyva
    END
    
    # A táblák és oszlopok meglétét nem ellenőrizzük, ha hiányzik valamelyik, a folyamat hibára fut.
    
    # Új felhasználó hozzáadása
    #Execute Sql String    INSERT INTO users (username, email) VALUES ('newuser', 'newuser@example.com')
    
    # Ellenőrzés az új felhasználó után
    #${all_users}=    Query    SELECT * FROM users
    #${final_count}=    Get Length    ${all_users}
    #Should Be Equal As Integers    ${final_count}    4
    #Log To Console    \nVégső felhasználók száma: ${final_count}
    
    #Log String To Console    [TRACE] Hash táblák ellenőrzése kilépett
   



Lekerem A Felhasznalokat
    #Log String To Console    [TRACE] Lekerem A Felhasznalokat elindult
    [Documentation]    Összes felhasználó lekérése a users táblából
    ${result}=    Query    SELECT id, username, email, created_date FROM users ORDER BY id
    Log String To Console    Lekért felhasználók száma: ${result.__len__()}
    FOR    ${row}    IN    @{result}
    ${id}=    Get From List    ${row}    0
    ${username}=    Get From List    ${row}    1
    ${email}=    Get From List    ${row}    2
    ${created}=    Get From List    ${row}    3
    Log String To Console    ID: ${id}, Felhasználónév: ${username}, Email: ${email}, Létrehozva: ${created}
    END
    RETURN    ${result}
    #Log String To Console    [TRACE] Lekerem A Felhasznalokat kilépett

Lekerem A Felhasznalot ID Alapjan
    #Log String To Console    [TRACE] Lekerem A Felhasznalot ID Alapjan elindult
    [Documentation]    Egy felhasználó lekérése ID alapján
    [Arguments]    ${user_id}
    ${result}=    Query    SELECT id, username, email, created_date FROM users WHERE id = ${user_id}
    Log String To Console    Lekért felhasználó adatai:
    FOR    ${row}    IN    @{result}
    ${id}=    Get From List    ${row}    0
    ${felhasznalonev}=    Get From List    ${row}    1
    ${email}=    Get From List    ${row}    2
    ${letrehozva}=    Get From List    ${row}    3
    Log String To Console    ID: ${id}, Felhasználónév: ${felhasznalonev}, Email: ${email}, Létrehozva: ${letrehozva}
    END
    RETURN    ${result}
    #Log String To Console    [TRACE] Lekerem A Felhasznalot ID Alapjan kilépett

Ellenorzom Az Adatbazist
    #Log String To Console    [TRACE] Ellenorzom Az Adatbazist elindult
    [Documentation]    Adatbázis állapot ellenőrzése
    ${row_count}=    Row Count    SELECT COUNT(*) FROM users
    Log String To Console    Felhasználók száma az adatbázisban: ${row_count}
    Should Be True    ${row_count} >= 0
    RETURN    ${row_count}
    #Log String To Console    [TRACE] Ellenorzom Az Adatbazist kilépett

Adatbazis Inicializalasa
    #Log String To Console    [TRACE] Adatbazis Inicializalasa elindult
    [Documentation]    SQLite adatbázis inicializálása táblákkal és teszt adatokkal
    # Users tábla létrehozása ha nem létezik
    Execute Sql String     IF NOT EXISTS users (id INTEGER PRIMARY KEY AUTOINCREMENT, username TEXT NOT NULL, email TEXT NOT NULL, created_date TEXT DEFAULT CURRENT_TIMESTAMP)
    
    # Ellenőrizzük, hogy vannak-e már adatok
    ${count}=    Row Count    SELECT COUNT(*) FROM users
    IF    ${count} == 0
        # Teszt adatok beszúrása
        Execute Sql String    INSERT INTO users (username, email) VALUES ('admin', 'admin@example.com')
        Execute Sql String    INSERT INTO users (username, email) VALUES ('testuser1', 'testuser1@example.com')
        Execute Sql String    INSERT INTO users (username, email) VALUES ('developer', 'developer@example.com')
        Execute Sql String    INSERT INTO users (username, email) VALUES ('analyst', 'analyst@example.com')
        Execute Sql String    INSERT INTO users (username, email) VALUES ('manager', 'manager@example.com')
    Log String To Console    SQLite adatbázis inicializálva 5 teszt felhasználóval
    ELSE
    Log String To Console    SQLite adatbázisban már vannak adatok (${count} felhasználó)
    END
    #Log String To Console    [TRACE] Adatbazis Inicializalasa kilépett

Fájladatok Feldolgozása Redundancia Táblába
    #Log To Console    [TRACE] Fájladatok Feldolgozása Redundancia Táblába elindult
    [Documentation]    Aktuális DOCX fájl adatainak feldolgozása a redundancia táblába
    [Arguments]    ${file_path}    ${is_error}    ${hibaszoveg}
    
    # Fájl méret lekérése
    ${file_size}=    Get File Size    ${file_path}
    
    # Előző rekord törlése a redundancia táblából az aktuális fájlhoz
    ${file_name}=    Evaluate    os.path.basename(r"${file_path}")    modules=os
    ${file_path_only}=    Evaluate    os.path.dirname(r"${file_path}")    modules=os
    Execute Sql String    DELETE FROM redundancia WHERE file_name = '${file_name}' AND file_path = '${file_path_only}'
    # Fájl név kivonása a teljes útvonalból (Windows útvonal escape karakterek kezelése)
    
    # Aktuális dátum és idő lekérése
    ${current_date}=    Get Current Date    result_format=%Y-%m-%d
    ${current_time}=    Get Current Date    result_format=%H:%M:%S
    
    # Ha hibás a DOCX, akkor a status legyen 'Hibás', különben 'Rendben'
    ${status}=    Set Variable If    ${is_error}    Hibás    Rendben
    ${status_str}=    Convert To String    ${status}
    # Az overview kiszámítása
    # Ha hibás, overview a hibaszöveg, különben a progress string (overview_string)
    ${overview_string}=    Get Variable Value    ${overview_string}    ''
    ${overview}=    Set Variable    ''

    # SQL beszúrás redundancia táblába
    Execute Sql String    INSERT INTO redundancia (status, file_path, file_name, file_size, record_date, record_time, overview) VALUES ('${status_str}', '${file_path_only}', '${file_name}', ${file_size}, '${current_date}', '${current_time}', '${overview}')
    ${redundancia_id_result}=    Query    SELECT last_insert_rowid()
    ${redundancia_id_row}=    Get From List    ${redundancia_id_result}    0
    ${redundancia_id}=    Get From List    ${redundancia_id_row}    0
    Set Global Variable    ${REDUNDANCIA_ID}    ${redundancia_id}
    
    Log String To Console    Redundancia ID: ${redundancia_id}
    Log String To Console    Fájl neve: ${file_name}
    Log String To Console    Fájl méret: ${file_size} byte
    Log String To Console    Feldolgozás ideje: ${current_time}
    # Sorok számának kiírása
    ${szoveg}=    Beolvasom A DOCX Fájlt
    Set Global Variable    ${SZOVEG}    ${szoveg}

    #Log To Console    ----------- Elmentve Globál-SZOVEG ba ---------------------
    #Log To Console    ${szoveg}

    #Log To Console    DOCX fájl beolvasás KÉSZ a Fájladatok Feldolgozása Redundancia Táblába eljárásból
    
    #Log To Console    Szöveg beolvasva ${szoveg}        #otto was here
    ${ossz_sor}=    Set Variable    0
    ${is_empty}=    Run Keyword And Return Status    Should Be Empty    ${szoveg}
    ${is_none}=    Run Keyword And Return Status    Should Be Equal    ${szoveg}    None

    IF    ${is_empty} or ${is_none}    
         Log String To Console    [HIBA] Üres vagy None szöveg, Split String kihagyva!
         ${hiba_msg}=    Set Variable    [HIBA] Üres vagy None szöveg, Split String kihagyva!
    ELSE   
        @{sorok}=    Split String    ${szoveg}    \n
        ${ossz_sor}=    Get Length    ${sorok}
        Set Global Variable    ${SORON}    ${sorok}
    END
   
    #Log String To Console    Sorok száma: ${ossz_sor}
    
   
    #Log To Console    [TRACE] Fájladatok Feldolgozása Redundancia Táblába kilépett
   
    RETURN    ${redundancia_id}
   



Batch DOCX ellenőrzés
    #Log String To Console    [TRACE] Batch DOCX ellenőrzés elindult
    [Documentation]    Batch feldolgozás összes DOCX fájlra a DOCUMENT_PATH útvonalon
    
    # DOCX fájlok keresése a megadott útvonalon
    @{docx_files}=    Find Docx Files Recursively    ${DOCUMENT_PATH}
    
    # Ellenőrzés, hogy van-e DOCX fájl
    ${file_count}=    Get Length    ${docx_files}
    Set Global Variable    ${file_count}
    Log String To Console    \n=== DOCX FÁJLOK KERESÉSE ===
    Log String To Console    Keresési útvonal: ${DOCUMENT_PATH}
    Log String To Console    Talált DOCX fájlok száma: ${file_count}

    
    IF    ${file_count} == 0
    Log String To Console    FIGYELMEZTETÉS: Nem találhatók DOCX fájlok a megadott útvonalon!
        RETURN
    END
    
    # Hibalista inicializálása
    ${HIBA_LISTA}=    Create List
    Set Global Variable    ${HIBA_LISTA}

    # Végigmegy az összes talált DOCX fájlon
    ${current_index}=    Set Variable    1
    FOR    ${docx_file}    IN    @{docx_files}
    Log String To Console    \n>>> FELDOLGOZÁS: (${current_index}/${file_count}) ${docx_file}
    # Resume logika: ha a redundancia táblában már végleges (nem Üres) státusz van ehhez a fájlhoz, kihagyjuk
    ${base_name}=    Evaluate    os.path.basename(r"${docx_file}")    modules=os
    ${dir_name}=    Evaluate    os.path.dirname(r"${docx_file}")    modules=os
    @{status_rows}=    Query    SELECT status FROM redundancia WHERE file_name='${base_name}' AND file_path='${dir_name}' ORDER BY id DESC LIMIT 1
    ${skip_already}=    Set Variable    False
    IF    ${status_rows.__len__()} > 0
        ${st_row}=    Get From List    ${status_rows}    0
        ${existing_status}=    Get From List    ${st_row}    0
        # Üresnek tekintjük ha NULL, 'Üres' vagy üres string
    # existing_status Robot változó -> mindig stringként kezeljük az Evaluate-ben
    ${is_empty_status}=    Evaluate    ('''${existing_status}''' is None) or (str('''${existing_status}''').strip() in ['Üres',''])
        # Ha nem üres státusz (Rendben/Gyanús/Másolt/Hibás), akkor skip
        IF    not ${is_empty_status}
            Log String To Console    [RESUME] Kihagyva (már feldolgozott státusz='${existing_status}')
            ${current_index}=    Evaluate    ${current_index} + 1
            CONTINUE
        END
    END
    ${current_index}=    Evaluate    ${current_index} + 1
    # Beállítja az aktuális DOCX fájlt változóban
    #itt hívd meg az átnevezést
    ${docx_file}=    Rename Docx With Prefix    ${docx_file}
    Set Global Variable    ${DOCX_FILE}    ${docx_file}
    # DOCX beolvasás és hibastátusz lekérdezése
    ${szoveg}=    Read Docx    ${DOCX_FILE}
    Set Global Variable    ${SZOVEG}    ${szoveg}
     #Log To Console    "===============================Beolvasom A DOCX Fájlt VÉGE==============================="
     #Log To Console    Szöveg beolvasva a Batchből: ${szoveg}        #otto was here

    ${is_error}=    Run Keyword And Return Status    Should Start With    ${szoveg}    [HIBA]
    ${is_empty}=    Run Keyword And Return Status    Should Be Empty    ${szoveg}
    ${is_none}=    Run Keyword And Return Status    Should Be Equal    ${szoveg}    None
    # Bármelyik igaz, akkor is_error legyen igaz
    IF    ${is_error} or ${is_empty} or ${is_none}
        ${is_error}=    Set Variable    ${True}
    ELSE
        ${is_error}=    Set Variable    ${False}
    END
    #Run Keyword If    ${is_error}    Log To Console    [DEBUG] szoveg: ${szoveg}
    Run Keyword If    ${is_error}    Log String To Console    [DEBUG] is_error: ${is_error}
    # Hibalistába fájlnév+hibaszöveg, de a feldolgozó kulcsszónak csak a file_path
    Run Keyword If    ${is_error}    Append To List    ${HIBA_LISTA}    ${docx_file}: ${szoveg}
   
    # Először redundancia rekordot beszúrjuk, majd átadjuk az ID-t a DOCX feldolgozásnak
    ${redundancia_id}=    Fájladatok Feldolgozása Redundancia Táblába    ${docx_file}    ${is_error}    ${szoveg}
    Run Keyword If    '${redundancia_id}' != ''    DOCX Beolvasás Teszt    ${docx_file}    ${redundancia_id}
   
    ${overview_string}=    Get Variable Value    ${overview_string}    ''
    Log String To Console    \n<<< BEFEJEZVE: ${docx_file}
    # Log To Console    Túl rövid mondatok: ${tul_rovid_szamlalo}
    END

    # Hibalista kiírása a végén
    Run Keyword If    ${HIBA_LISTA}    Log String To Console    \n=== HIBÁS DOCX FÁJLOK ===
    FOR    ${hiba}    IN    @{HIBA_LISTA}
    Log String To Console    ${hiba}
    END

    Log String To Console    === ÖSSZESÍTÉS ===
    Log String To Console    \nFeldolgozott dokumentumok száma: ${file_count}
    #Log String To Console    [TRACE] Batch DOCX ellenőrzés kilépett

Redundancia Eredmények Ellenőrzése
    #Log String To Console    [TRACE] Redundancia Eredmények Ellenőrzése elindult
    [Documentation]    Redundancia tábla status oszlopának részletes ellenőrzése
    
    # Minden futás előtt a redundancia tábla biztosítása
    Hash táblák ellenőrzése
    Log String To Console    REDUNDANCIA EREDMÉNYEK ELEMZÉSE
    Log String To Console    \n══════════════════════════════════════
    Log String To Console    Használt adatbázisfájl: ${SQLITE_DB_FILE}
    
    # Kapcsolódás előtt mindig bontsuk az előző kapcsolatot, hogy ne legyen warning
    Run Keyword And Ignore Error    Disconnect From Database
    Run Keyword And Ignore Error    Connect To Database    sqlite3    ${SQLITE_DB_FILE}
    
    # Redundancia tábla struktúrájának ellenőrzése
    #@{schema}=    Query    PRAGMA table_info(redundancia)
    #Log To Console    \n📊 REDUNDANCIA TÁBLA STRUKTÚRÁJA:
    #FOR    ${column}    IN    @{schema}
    #    ${col_name}=    Get From List    ${column}    1
    #    ${col_type}=    Get From List    ${column}    2
    #    ${default_val}=    Get From List    ${column}    4
    #    Log To Console    • ${col_name} - ${col_type} (alapértelmezett: ${default_val})
    #END
    
    # Jelenlegi redundancia adatok megjelenítése
    #@{redundancia_data}=    Query    SELECT id, file_name, file_size, max_ismetlesek_szama, max_ismetelt_karakterszam, status FROM redundancia ORDER BY max_ismetelt_karakterszam DESC
    
    #Log To Console    \n📋 REDUNDANCIA REKORDOK STATUSSZAL:
    #FOR    ${record}    IN    @{redundancia_data}
    #    ${id}=    Get From List    ${record}    0
    #    ${file_name}=    Get From List    ${record}    1
    #    ${file_size}=    Get From List    ${record}    2
    #    ${max_ismetlesek}=    Get From List    ${record}    3
    #    ${max_karakterszam}=    Get From List    ${record}    4
    #    ${status}=    Get From List    ${record}    5
        
    #    Log To Console    ID: ${id} | Fájl: ${file_name} | Méret: ${file_size} bytes
    #    Log To Console    Max ismétlések: ${max_ismetlesek} | Max karakterszám: ${max_karakterszam}
    #    Log To Console    ➤ STATUS: ${status}
    #    Log To Console    ---
    #END
    
    # Status kategóriák statisztikája részletesen
    @{status_stats}=    Query    SELECT status, COUNT(*) as count, MIN(max_ismetelt_karakterszam) as min_chars, MAX(max_ismetelt_karakterszam) as max_chars FROM redundancia GROUP BY status ORDER BY min_chars
    
    Log String To Console    \nSTATUS KATEGÓRIÁK RÉSZLETES STATISZTIKÁJA:
    FOR    ${stat}    IN    @{status_stats}
        ${status}=    Get From List    ${stat}    0
        ${count}=    Get From List    ${stat}    1
        ${min_chars}=    Get From List    ${stat}    2
        ${max_chars}=    Get From List    ${stat}    3
    Log String To Console    ${status}: ${count} dokumentum (${min_chars}-${max_chars} karakter)
    END
    
    # Status kategóriák szabályainak ellenőrzése
    
    Log String To Console    \nSTATUS KATEGÓRIÁK SZABÁLYAI:
    Log String To Console    Rendben: max_ismetelt_karakterszam < 300
    Log String To Console    Gyanús: ${CONFIG_THRESHOLD_GYANUS} ≤ max_ismetelt_karakterszam < ${CONFIG_THRESHOLD_MASOLT}
    Log String To Console    Másolt: max_ismetelt_karakterszam ≥ ${CONFIG_THRESHOLD_MASOLT}
    
    # Összesítő statisztikák
    @{total_stats}=    Query    SELECT COUNT(*) as total_docs, SUM(CASE WHEN status = 'Rendben' THEN 1 ELSE 0 END) as clean_docs, SUM(CASE WHEN status = 'Gyanús' THEN 1 ELSE 0 END) as suspicious_docs, SUM(CASE WHEN status = 'Másolt' THEN 1 ELSE 0 END) as copied_docs FROM redundancia
    ${total_row}=    Get From List    ${total_stats}    0
    ${total}=    Get From List    ${total_row}    0
    ${clean}=    Get From List    ${total_row}    1
    ${suspicious}=    Get From List    ${total_row}    2
    ${copied}=    Get From List    ${total_row}    3
    
    Log String To Console    \nVÉGSŐ ÖSSZESÍTÉS:
    Log String To Console    ═══════════════════════
    Log String To Console    Összes dokumentum: ${total}
    Log String To Console    Rendben: ${clean} dokumentum
    Log String To Console    Gyanús: ${suspicious} dokumentum
    Log String To Console    Másolt: ${copied} dokumentum
    
    # Százalékos arányok
    IF    ${total} > 0
        ${clean_percent}=    Evaluate    round((${clean} / ${total}) * 100, 1)
        ${suspicious_percent}=    Evaluate    round((${suspicious} / ${total}) * 100, 1)
        ${copied_percent}=    Evaluate    round((${copied} / ${total}) * 100, 1)
        
    Log String To Console    \nSZÁZALÉKOS MEGOSZLÁS:
    Log String To Console    Rendben: ${clean_percent}%
    Log String To Console    Gyanús: ${suspicious_percent}%
    Log String To Console    Másolt: ${copied_percent}%
    END
    
    
    Log String To Console    \nEREDMÉNYEK ELLENŐRZÉSE BEFEJEZVE!
    Log String To Console    \n═══════════════════════════════════════

Excel Export Redundancia Tábla
    #Log String To Console    [TRACE] Excel Export Redundancia Tábla elindult
    [Documentation]    Redundancia tábla tartalmának exportálása Excel fájlba a PLG-03-write-excel.robot használatával
    
    # Export előtt minden nyitott kapcsolatot lezárunk
    # Export előtt minden nyitott kapcsolatot lezárunk
    Disconnect From Database
    # Export előtt újra kapcsolódunk az adatbázishoz, hogy legyen aktív kapcsolat
    Connect To Database    sqlite3    ${SQLITE_DB_FILE}
    Log String To Console    \nEXCEL EXPORT KEZDÉSE
    Log String To Console    ═══════════════════════════════
    # Adatbázis táblák inicializálása, ha hiányoznak
    Hash táblák ellenőrzése
    
    # Excel export Python script futtatása a virtuális környezetből
    ${python_path}=    Set Variable    ${PYTHON_EXEC}
    ${result}=    Run Process    ${python_path}    libraries/excel_export_simple.py    shell=False    cwd=${EXECDIR}    stdout=STDOUT    stderr=STDERR
    IF    ${result.rc} == 0
    Log String To Console    Excel export sikeres!
    Log String To Console    ${result.stdout}
    ELSE
    Log String To Console    Excel export hiba!
    Log String To Console    ${result.stderr}
    Log String To Console    Excel export sikertelen, de a folyamat folytatódik...
    END
    #Log String To Console    [TRACE] Excel Export Redundancia Tábla kilépett



Check Redundancia Table Exists
    #Log String To Console    [TRACE] Check Redundancia Table Exists elindult
    [Documentation]    Ellenőrzi, hogy a redundancia tábla létezik-e az SQLite adatbázisban
    Run Keyword And Ignore Error    Connect To Database    sqlite3    ${SQLITE_DB_FILE}
    ${result}=    Query    SELECT name FROM sqlite_master WHERE type='table' AND name='redundancia'
    ${table_count}=    Get Length    ${result}
    Run Keyword If    ${table_count} == 0    Log String To Console    FIGYELMEZTETÉS: A 'redundancia' tábla nem létezik az adatbázisban!
    Run Keyword If    ${table_count} == 0    Fail    A 'redundancia' tábla nem jött létre!
    Disconnect From Database
    #Log String To Console    [TRACE] Check Redundancia Table Exists kilépett

