Log String To Console
    [Arguments]    ${msg}
    Log To Console    ${msg}
*** Keywords ***
Log String To Console
    [Arguments]    ${msg}
    Log To Console    ${msg}

Process Config Line
    Log To Console    [TRACE] Process Config Line elindult
    [Arguments]    ${config_line}
    @{config_parts}=    Split String    ${config_line}    |
    ${parts_len}=    Get Length    ${config_parts}
    IF    ${parts_len} < 8
        Fail    Konfigurációs sor hibás vagy hiányos: ${config_line}
    END
    ${email_part}=    Get From List    ${config_parts}    0
    ${input_part}=    Get From List    ${config_parts}    1
    ${output_part}=    Get From List    ${config_parts}    2
    ${subject_part}=    Get From List    ${config_parts}    3
    ${excel_prefix_part}=    Get From List    ${config_parts}    4
    ${rename_prefix_part}=    Get From List    ${config_parts}    5
    ${threshold_gyanus_part}=    Get From List    ${config_parts}    6
    ${threshold_masolt_part}=    Get From List    ${config_parts}    7
    ${config_email}=    Remove String    ${email_part}    EMAIL:
    ${config_input}=    Remove String    ${input_part}    INPUT:
    ${config_output}=    Remove String    ${output_part}    OUTPUT:
    ${config_subject}=    Remove String    ${subject_part}    SUBJECT:
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
    Set Global Variable    ${CONFIG_EMAIL}         ${config_email}
    Set Global Variable    ${CONFIG_INPUT_FOLDER}  ${config_input}
    Set Global Variable    ${CONFIG_OUTPUT_FOLDER}    ${config_output}
    Set Global Variable    ${CONFIG_EMAIL_SUBJECT}    ${config_subject}
    Set Global Variable    ${CONFIG_EXCEL_PREFIX}     ${config_excel_prefix}
    Set Global Variable    ${RENAME_PREFIX}          ${config_rename_prefix}
    Set Global Variable    ${CONFIG_THRESHOLD_GYANUS}    ${config_threshold_gyanus}
    Set Global Variable    ${CONFIG_THRESHOLD_MASOLT}    ${config_threshold_masolt}
    Set Global Variable    ${DOCUMENT_PATH}           ${config_input}
    # Sikeres konfiguráció betöltése - ikonokkal
    Log To Console    Konfiguracio sikeresen betoltve!
    Log To Console    Email: ${config_email}
    Log To Console    Bementi konyvtar: ${config_input}
    Log To Console    Kimeneti konyvtar: ${config_output}
    Log To Console    Email targy: ${config_subject}
    Log To Console    Excel prefix: ${config_excel_prefix}
*** Settings ***
Library    ../libraries/DocxReader.py
Library    ../libraries/find_docx.py
Library    BuiltIn
Library    DatabaseLibrary
Library    DateTime
Library    Process
Resource   variables.robot
Resource   ../PLG-02-read_docx.robot
Resource   get_file_size.resource
Resource   ../PLG-03-rename_docx.robot


*** Keywords ***

Get Config Icon
    Log To Console    [TRACE] Get Config Icon elindult
    [Documentation]    Ikonok tiltva: mindig üres string
    [Arguments]    ${icon_name}
    RETURN    ${EMPTY}
    Log To Console    [TRACE] Get Config Icon kilépett

Konfiguráció Betöltése
    Log To Console    [TRACE] Konfiguráció Betöltése elindult
    [Documentation]    Plagium.config fajl betoltese es beallitasok alkalmazasa
    Log To Console    \nKONFIGURACIO BETOLTESE...
    Log To Console    ═══════════════════════════════
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
    ELSE
    Log To Console    Hiba a konfiguracio betoltesekor, alapertelmezettek hasznalata
    Log To Console    Hibauzenet: ${config_result.stderr}
    END
    Log To Console    ${EMPTY}
    Log To Console    ═══════════KONFIGURACIO BETOLTESE KÉSZ════════════════════
    #Log To Console    [TRACE] Konfiguráció Betöltése kilépett



Beolvasom A DOCX Fájlt
    Log To Console    [TRACE] Beolvasom A DOCX Fájlt elindult
    ${szoveg}=    Read Docx    ${DOCX_FILE}

    Set Global Variable    ${DOCX_TEXT}    ${szoveg}
    ${is_error}=    Run Keyword And Return Status    Should Start With    ${szoveg}    [HIBA]
    Return From Keyword    ${szoveg}
    #Log To Console    [TRACE] Beolvasom A DOCX Fájlt kilépett

Kapcsolodas Az Adatbazishoz
    Log To Console    [TRACE] Kapcsolodas Az Adatbazishoz elindult
    [Documentation]    SQLite adatbázishoz kapcsolódás
    # Mindig bontsunk előző kapcsolatot, hogy ne legyen "Overwriting not closed connection" warning
    Run Keyword And Ignore Error    Disconnect From Database
    IF    '${DB_MODULE}' == 'sqlite3'
        Connect To Database    sqlite3    ${DB_NAME}
    Log To Console    Sikeres kapcsolódás az SQLite adatbázishoz: ${DB_NAME}
    ELSE IF    '${DB_MODULE}' == 'pyodbc'
        ${connection_string}=    Set Variable    DRIVER={SQL Server};SERVER=${DB_HOST};DATABASE=${DB_NAME};UID=${DB_USERNAME};PWD=${DB_PASSWORD};
    Log To Console    ODBC Connection string: ${connection_string}
        Connect To Database    pyodbc    ${connection_string}
    Log To Console    Sikeres kapcsolódás az MSSQL adatbázishoz
    ELSE
        Connect To Database    ${DB_MODULE}    ${DB_NAME}    ${DB_USERNAME}    ${DB_PASSWORD}    ${DB_HOST}    ${DB_PORT}
    Log To Console    Sikeres kapcsolódás az adatbázishoz
    END
    #Log To Console    [TRACE] Kapcsolodas Az Adatbazishoz kilépett

Adatbazis Kapcsolat Bezarasa
    Log To Console    [TRACE] Adatbazis Kapcsolat Bezarasa elindult
    [Documentation]    Adatbázis kapcsolat bezárása
    Run Keyword And Ignore Error    Disconnect From Database
    Log To Console    Adatbázis kapcsolat bezárva
    Log To Console    [TRACE] Adatbazis Kapcsolat Bezarasa kilépett

Hash táblák ellenőrzése
    Log To Console    [TRACE] Hash táblák ellenőrzése elindult
    [Documentation]    Egyszerű SQLite adatbázis teszt amely ténylegesen működik
    [Tags]    database    sqlite    working
    
    # Régi adatbázis törlése ha létezik
    #${file_exists}=    Run Keyword And Return Status    File Should Exist    ${SQLITE_DB_FILE}
    #Run Keyword If    ${file_exists}    Remove File    ${SQLITE_DB_FILE}
    
    # redundancia tábla létrehozása ha nem létezik (elsőként, mivel ez lesz a fő tábla)
    Log To Console    CREATE TABLE IF NOT EXISTS redundancia
    Execute Sql String    CREATE TABLE IF NOT EXISTS redundancia (id INTEGER PRIMARY KEY AUTOINCREMENT, status TEXT DEFAULT 'Rendben', file_path TEXT, file_name TEXT NOT NULL, file_size INTEGER NOT NULL, line_number INTEGER DEFAULT 0, repeat_block_nbr INTEGER DEFAULT 0, max_ismetlesek_szama INTEGER DEFAULT 0, max_ismetelt_karakterszam INTEGER DEFAULT 0, repeated_percent REAL DEFAULT 0, overview TEXT DEFAULT '', record_date TEXT NOT NULL, record_time TEXT NOT NULL)
    Execute Sql String    CREATE INDEX IF NOT EXISTS idx_redundancia_id ON redundancia(id)
    Execute Sql String    CREATE INDEX IF NOT EXISTS idx_redundancia_file ON redundancia(file_name, file_path)
    
    # hashCodes tábla létrehozása ha nem létezik foreign key kapcsolattal és külön file_name, file_path oszlopokkal (document_name nélkül)
    Log To Console    CREATE TABLE IF NOT EXISTS hashCodes
    Execute Sql String    CREATE TABLE IF NOT EXISTS hashCodes (hash_value TEXT(100) PRIMARY KEY, file_path TEXT NOT NULL, file_name TEXT NOT NULL, created_date TEXT NOT NULL, created_time TEXT NOT NULL, used_by_nbr INTEGER DEFAULT 1, line_content TEXT, redundancia_id INTEGER, FOREIGN KEY (redundancia_id) REFERENCES redundancia(id))
    Execute Sql String    CREATE INDEX IF NOT EXISTS idx_hashCodes_file ON hashCodes(file_name, file_path)
    
    # repeat tábla létrehozása ha nem létezik - az ismételt sorok tárolására
    Log To Console    CREATE TABLE IF NOT EXISTS repeat
    Execute Sql String    CREATE TABLE IF NOT EXISTS repeat (id INTEGER PRIMARY KEY AUTOINCREMENT, file_name TEXT NOT NULL, file_path TEXT NOT NULL, source_file_path TEXT, source_file_name TEXT NOT NULL, redundancia_id INTEGER, repeat_block_nbr INTEGER DEFAULT 0, block_id INTEGER NOT NULL, line_length INTEGER NOT NULL, repeated_line TEXT NOT NULL, token TEXT, created_date TEXT NOT NULL, created_time TEXT NOT NULL, FOREIGN KEY (redundancia_id) REFERENCES redundancia(id))
    Execute Sql String    CREATE INDEX IF NOT EXISTS idx_repeat_file ON repeat(file_name, file_path)
    Execute Sql String    CREATE INDEX IF NOT EXISTS idx_repeat_redundancia_id ON repeat(redundancia_id)
    Execute Sql String    CREATE INDEX IF NOT EXISTS idx_repeat_block_id ON repeat(block_id)
    Execute Sql String    CREATE INDEX IF NOT EXISTS idx_repeat_id ON repeat(id)
    # A táblák és oszlopok meglétét nem ellenőrizzük, ha hiányzik valamelyik, a folyamat hibára fut.
    
    # Új felhasználó hozzáadása
    #Execute Sql String    INSERT INTO users (username, email) VALUES ('newuser', 'newuser@example.com')
    
    # Ellenőrzés az új felhasználó után
    #${all_users}=    Query    SELECT * FROM users
    #${final_count}=    Get Length    ${all_users}
    #Should Be Equal As Integers    ${final_count}    4
    #Log To Console    \nVégső felhasználók száma: ${final_count}
    
    Log To Console    [TRACE] Hash táblák ellenőrzése kilépett
   



Lekerem A Felhasznalokat
    Log To Console    [TRACE] Lekerem A Felhasznalokat elindult
    [Documentation]    Összes felhasználó lekérése a users táblából
    ${result}=    Query    SELECT id, username, email, created_date FROM users ORDER BY id
    Log To Console    Lekért felhasználók száma: ${result.__len__()}
    FOR    ${row}    IN    @{result}
    ${id}=    Get From List    ${row}    0
    ${username}=    Get From List    ${row}    1
    ${email}=    Get From List    ${row}    2
    ${created}=    Get From List    ${row}    3
    Log To Console    ID: ${id}, Felhasználónév: ${username}, Email: ${email}, Létrehozva: ${created}
    END
    RETURN    ${result}
    Log To Console    [TRACE] Lekerem A Felhasznalokat kilépett

Lekerem A Felhasznalot ID Alapjan
    Log To Console    [TRACE] Lekerem A Felhasznalot ID Alapjan elindult
    [Documentation]    Egy felhasználó lekérése ID alapján
    [Arguments]    ${user_id}
    ${result}=    Query    SELECT id, username, email, created_date FROM users WHERE id = ${user_id}
    Log To Console    Lekért felhasználó adatai:
    FOR    ${row}    IN    @{result}
    ${id}=    Get From List    ${row}    0
    ${felhasznalonev}=    Get From List    ${row}    1
    ${email}=    Get From List    ${row}    2
    ${letrehozva}=    Get From List    ${row}    3
    Log To Console    ID: ${id}, Felhasználónév: ${felhasznalonev}, Email: ${email}, Létrehozva: ${letrehozva}
    END
    RETURN    ${result}
    Log To Console    [TRACE] Lekerem A Felhasznalot ID Alapjan kilépett

Ellenorzom Az Adatbazist
    Log To Console    [TRACE] Ellenorzom Az Adatbazist elindult
    [Documentation]    Adatbázis állapot ellenőrzése
    ${row_count}=    Row Count    SELECT COUNT(*) FROM users
    Log To Console    Felhasználók száma az adatbázisban: ${row_count}
    Should Be True    ${row_count} >= 0
    RETURN    ${row_count}
    Log To Console    [TRACE] Ellenorzom Az Adatbazist kilépett

Adatbazis Inicializalasa
    Log To Console    [TRACE] Adatbazis Inicializalasa elindult
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
    Log To Console    SQLite adatbázis inicializálva 5 teszt felhasználóval
    ELSE
    Log To Console    SQLite adatbázisban már vannak adatok (${count} felhasználó)
    END
    Log To Console    [TRACE] Adatbazis Inicializalasa kilépett

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
    
    Log To Console    Redundancia ID: ${redundancia_id}
    Log To Console    Fájl neve: ${file_name}
    Log To Console    Fájl méret: ${file_size} byte
    Log To Console    Feldolgozás ideje: ${current_time}
    # Sorok számának kiírása
    Log To Console    DOCX fájl beolvasás indul a Fájladatok Feldolgozása Redundancia Táblába eljárásból
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
   
    Log To Console    Sorok száma: ${ossz_sor}
    
   
    #Log To Console    [TRACE] Fájladatok Feldolgozása Redundancia Táblába kilépett
   
    RETURN    ${redundancia_id}
   



Batch DOCX ellenőrzés
    Log To Console    [TRACE] Batch DOCX ellenőrzés elindult
    [Documentation]    Batch feldolgozás összes DOCX fájlra a DOCUMENT_PATH útvonalon
    
    # DOCX fájlok keresése a megadott útvonalon
    @{docx_files}=    Find Docx Files Recursively    ${DOCUMENT_PATH}
    
    # Ellenőrzés, hogy van-e DOCX fájl
    ${file_count}=    Get Length    ${docx_files}
    Set Global Variable    ${file_count}
    Log To Console    \n=== DOCX FÁJLOK KERESÉSE ===
    Log To Console    Keresési útvonal: ${DOCUMENT_PATH}
    Log To Console    Talált DOCX fájlok száma: ${file_count}

    
    IF    ${file_count} == 0
    Log To Console    FIGYELMEZTETÉS: Nem találhatók DOCX fájlok a megadott útvonalon!
        RETURN
    END
    
    # Hibalista inicializálása
    ${HIBA_LISTA}=    Create List
    Set Global Variable    ${HIBA_LISTA}

    # Végigmegy az összes talált DOCX fájlon
    ${current_index}=    Set Variable    1
    FOR    ${docx_file}    IN    @{docx_files}
    Log To Console    \n>>> FELDOLGOZÁS: (${current_index}/${file_count}) ${docx_file}
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
    Run Keyword If    ${is_error}    Log To Console    [DEBUG] is_error: ${is_error}
    # Hibalistába fájlnév+hibaszöveg, de a feldolgozó kulcsszónak csak a file_path
    Run Keyword If    ${is_error}    Append To List    ${HIBA_LISTA}    ${docx_file}: ${szoveg}
   
    # Először redundancia rekordot beszúrjuk, majd átadjuk az ID-t a DOCX feldolgozásnak
    ${redundancia_id}=    Fájladatok Feldolgozása Redundancia Táblába    ${docx_file}    ${is_error}    ${szoveg}
    Run Keyword If    '${redundancia_id}' != ''    DOCX Beolvasás Teszt    ${docx_file}    ${redundancia_id}
   
    ${overview_string}=    Get Variable Value    ${overview_string}    ''
    Log To Console    \n<<< BEFEJEZVE: ${docx_file}
    # Log To Console    Túl rövid mondatok: ${tul_rovid_szamlalo}
    END

    # Hibalista kiírása a végén
    Run Keyword If    ${HIBA_LISTA}    Log To Console    \n=== HIBÁS DOCX FÁJLOK ===
    FOR    ${hiba}    IN    @{HIBA_LISTA}
    Log To Console    ${hiba}
    END

    Log To Console    === ÖSSZESÍTÉS ===
    Log To Console    \nFeldolgozott dokumentumok száma: ${file_count}
    Log To Console    [TRACE] Batch DOCX ellenőrzés kilépett

Redundancia Eredmények Ellenőrzése
    Log To Console    [TRACE] Redundancia Eredmények Ellenőrzése elindult
    [Documentation]    Redundancia tábla status oszlopának részletes ellenőrzése
    
    # Minden futás előtt a redundancia tábla biztosítása
    Hash táblák ellenőrzése
    Log To Console    REDUNDANCIA EREDMÉNYEK ELEMZÉSE
    Log To Console    \n══════════════════════════════════════
    Log To Console    Használt adatbázisfájl: ${SQLITE_DB_FILE}
    
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
    
    Log To Console    \nSTATUS KATEGÓRIÁK RÉSZLETES STATISZTIKÁJA:
    FOR    ${stat}    IN    @{status_stats}
        ${status}=    Get From List    ${stat}    0
        ${count}=    Get From List    ${stat}    1
        ${min_chars}=    Get From List    ${stat}    2
        ${max_chars}=    Get From List    ${stat}    3
    Log To Console    ${status}: ${count} dokumentum (${min_chars}-${max_chars} karakter)
    END
    
    # Status kategóriák szabályainak ellenőrzése
    
    Log To Console    \nSTATUS KATEGÓRIÁK SZABÁLYAI:
    Log To Console    Rendben: max_ismetelt_karakterszam < 300
    Log To Console    Gyanús: ${CONFIG_THRESHOLD_GYANUS} ≤ max_ismetelt_karakterszam < ${CONFIG_THRESHOLD_MASOLT}
    Log To Console    Másolt: max_ismetelt_karakterszam ≥ ${CONFIG_THRESHOLD_MASOLT}
    
    # Összesítő statisztikák
    @{total_stats}=    Query    SELECT COUNT(*) as total_docs, SUM(CASE WHEN status = 'Rendben' THEN 1 ELSE 0 END) as clean_docs, SUM(CASE WHEN status = 'Gyanús' THEN 1 ELSE 0 END) as suspicious_docs, SUM(CASE WHEN status = 'Másolt' THEN 1 ELSE 0 END) as copied_docs FROM redundancia
    ${total_row}=    Get From List    ${total_stats}    0
    ${total}=    Get From List    ${total_row}    0
    ${clean}=    Get From List    ${total_row}    1
    ${suspicious}=    Get From List    ${total_row}    2
    ${copied}=    Get From List    ${total_row}    3
    
    Log To Console    \nVÉGSŐ ÖSSZESÍTÉS:
    Log To Console    ═══════════════════════
    Log To Console    Összes dokumentum: ${total}
    Log To Console    Rendben: ${clean} dokumentum
    Log To Console    Gyanús: ${suspicious} dokumentum
    Log To Console    Másolt: ${copied} dokumentum
    
    # Százalékos arányok
    IF    ${total} > 0
        ${clean_percent}=    Evaluate    round((${clean} / ${total}) * 100, 1)
        ${suspicious_percent}=    Evaluate    round((${suspicious} / ${total}) * 100, 1)
        ${copied_percent}=    Evaluate    round((${copied} / ${total}) * 100, 1)
        
    Log To Console    \nSZÁZALÉKOS MEGOSZLÁS:
    Log To Console    Rendben: ${clean_percent}%
    Log To Console    Gyanús: ${suspicious_percent}%
    Log To Console    Másolt: ${copied_percent}%
    END
    
    
    Log To Console    \nEREDMÉNYEK ELLENŐRZÉSE BEFEJEZVE!
    Log To Console    \n═══════════════════════════════════════

Excel Export Redundancia Tábla
    Log To Console    [TRACE] Excel Export Redundancia Tábla elindult
    [Documentation]    Redundancia tábla tartalmának exportálása Excel fájlba a PLG-03-write-excel.robot használatával
    
    # Export előtt minden nyitott kapcsolatot lezárunk
    # Export előtt minden nyitott kapcsolatot lezárunk
    Disconnect From Database
    # Export előtt újra kapcsolódunk az adatbázishoz, hogy legyen aktív kapcsolat
    Connect To Database    sqlite3    ${SQLITE_DB_FILE}
    Log To Console    \nEXCEL EXPORT KEZDÉSE
    Log To Console    ═══════════════════════════════
    # Adatbázis táblák inicializálása, ha hiányoznak
    Hash táblák ellenőrzése
    
    # Excel export Python script futtatása a virtuális környezetből
    ${python_path}=    Set Variable    ${PYTHON_EXEC}
    ${result}=    Run Process    ${python_path}    libraries/excel_export_simple.py    shell=False    cwd=${EXECDIR}    stdout=STDOUT    stderr=STDERR
    IF    ${result.rc} == 0
    Log To Console    Excel export sikeres!
    Log To Console    ${result.stdout}
    ELSE
    Log To Console    Excel export hiba!
    Log To Console    ${result.stderr}
    Log To Console    Excel export sikertelen, de a folyamat folytatódik...
    END
    Log To Console    [TRACE] Excel Export Redundancia Tábla kilépett



Check Redundancia Table Exists
    Log To Console    [TRACE] Check Redundancia Table Exists elindult
    [Documentation]    Ellenőrzi, hogy a redundancia tábla létezik-e az SQLite adatbázisban
    Run Keyword And Ignore Error    Connect To Database    sqlite3    ${SQLITE_DB_FILE}
    ${result}=    Query    SELECT name FROM sqlite_master WHERE type='table' AND name='redundancia'
    ${table_count}=    Get Length    ${result}
    Run Keyword If    ${table_count} == 0    Log To Console    FIGYELMEZTETÉS: A 'redundancia' tábla nem létezik az adatbázisban!
    Run Keyword If    ${table_count} == 0    Fail    A 'redundancia' tábla nem jött létre!
    Disconnect From Database
    Log To Console    [TRACE] Check Redundancia Table Exists kilépett

