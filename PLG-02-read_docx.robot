*** Settings ***
Resource    resources/keywords.robot
Resource    resources/variables.robot
Library     String
Library     BuiltIn
Library     Collections

*** Keywords ***
DOCX Beolvasás Teszt
    #Log To Console    [TRACE] DOCX Beolvasás Teszt elindult
    [Arguments]    ${file_path}    ${redundancia_id}
    # Redundancia ID beállítása globális változóként
    Set Global Variable    ${REDUNDANCIA_ID}    ${redundancia_id}
    Set Global Variable    ${DOCX_FILE}    ${file_path}
    [Documentation]    DOCX fájl feldolgozása hash-eléssel és plagiarízmus ellenőrzéssel.
    ...                10 karakternél rövidebb sorokat kihagyja a feldolgozásból.
    #Log To Console    <<< BEOLVASÁS INDUL >>>
    #${szoveg}=    Beolvasom A DOCX Fájlt
    ${szoveg}=    Set Variable    ${SZOVEG}
    ${overview_string}=    Set Variable    ${EMPTY}    # Progress karakterek gyűjtése            
    ${current_status}=    Set Variable    Üres
    
    #Log To Console     ${szoveg}
   
    # Ha tuple vagy lista, alakítsuk sztringgé
    # Egyszerű sztringgé alakítás tuple/list esetén
    # Robusztus sztringgé alakítás tuple vagy lista esetén
    Run Keyword If    ${szoveg.__class__.__name__} == "tuple" or ${szoveg.__class__.__name__} == "list"    Set Variable    ${szoveg}    ${Catenate    SEPARATOR=\n    @{szoveg}}
    # Most már biztosan sztring
    # Ha üres a szöveg vagy tartalmazza a [HIBA] szöveget, azonnal visszatérés
  
    ${not_empty}=    Run Keyword And Return Status    Should Not Be Empty    ${szoveg}
    ${contains_hiba}=    Run Keyword And Return Status    Should Contain    ${szoveg}    [HIBA]
    #Log To Console    &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
    #Log To Console    ${szoveg}
    #Log To Console    &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
    IF    ${not_empty} and ${contains_hiba}
        Log String To Console    HIBA BEJEGYZES ADATBÁZISBA ÍRÁSA...
        Execute Sql String    UPDATE redundancia SET status = 'Hibás', overview = '${szoveg}' WHERE id = ${REDUNDANCIA_ID}
        # Max értékek, status és overview mező update-je egyetlen SQL-ben, a végleges értékekkel
        Set Global Variable    ${max_duplikacio_szamlalo}    0
        Set Global Variable    ${max_ismetelt_karakterszam}    0
        Set Global Variable    ${overview_string}    ${EMPTY}
        Set Global Variable    ${aktualis_block_id}   0

        ${overview_string_trimmed}=    Strip String    ${szoveg}
        ${overview_string_esc}=    Replace String    ${overview_string_trimmed}    '    ''
        ${overview_string_esc}=    Replace String    ${overview_string_esc}    "    ""
        ${overview_string_esc}=    Replace String    ${overview_string_esc}    \n    ${EMPTY}
        ${overview_string_esc}=    Replace String    ${overview_string_esc}    \r    ${EMPTY}
        ${overview_string_esc}=    Replace String    ${overview_string_esc}    \t    ${EMPTY}
        Execute Sql String    UPDATE redundancia SET repeat_block_nbr = ${aktualis_block_id}, max_ismetlesek_szama = ${max_duplikacio_szamlalo}, max_ismetelt_karakterszam = ${max_ismetelt_karakterszam}, status = CASE WHEN ${max_ismetelt_karakterszam} < ${CONFIG_THRESHOLD_GYANUS} THEN 'Rendben' WHEN ${max_ismetelt_karakterszam} >= ${CONFIG_THRESHOLD_GYANUS} AND ${max_ismetelt_karakterszam} < ${CONFIG_THRESHOLD_MASOLT} THEN 'Gyanús' ELSE 'Másolt' END, overview = '${overview_string_esc}' WHERE id = ${REDUNDANCIA_ID} and "status<>'Hibás'"
        #Execute Sql String    UPDATE redundancia SET repeat_block_nbr = ${aktualis_block_id} WHERE id = ${REDUNDANCIA_ID}
        #Log To Console    [TRACE] DOCX Beolvasás Teszt kilépett
        ${current_status}=    Set Variable    Hibás

        Return From Keyword
    END
    #Log String To Console    &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
     # Mindig legyen definiálva ${ossz_sor}
    ${ossz_sor}=    Set Variable    0
    ${kisbetus}=    Set Variable    ''
    ${not_empty}=    Run Keyword And Return Status    Should Not Be Empty    ${szoveg}
    ${contains_hiba}=    Run Keyword And Return Status    Should Contain    ${szoveg}    [HIBA]
    IF    ${not_empty} and ${contains_hiba}
        Log String To Console    '[HIBA] Szöveg tartalmazza a [HIBA] szót!'
        Log String To Console    '[HIBA] Üres vagy None szöveg, Split String kihagyva!'
        # Itt lehet hibakezelést vagy visszatérést tenni
    ELSE IF    ${not_empty}
        ${kisbetus}=    Convert To Lowercase    ${szoveg}
        @{sorok}=    Split String    ${kisbetus}    \n
        ${ossz_sor}=    Get Length    ${sorok}
        
    END
    #Log String To Console    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   

    ${ossz_str}=    Convert To String    ${ossz_sor}
    Log String To Console    Feldolgozandó sorok száma: ${ossz_str}
    # line_number mező frissítése a redundancia táblában
    Execute Sql String    UPDATE redundancia SET line_number = ${ossz_sor} WHERE id = ${REDUNDANCIA_ID}
    
    ${ismetelt_karakterszam}=    Set Variable    0
    ${in_group_ismetelt_karakterszam}=    Set Variable    0
    ${max_ismetelt_karakterszam}=    Set Variable    0
    
    ${max_total_ismetelt_karakterszam}=    Set Variable    0
    ${total_karakterszam}=    Set Variable    0

    ${total_karakterszam}=    Set Variable    0
    ${total_ismetelt_karakterszam}=    Set Variable    0


    ${elozo_duplikalt}=    Set Variable    False
    ${aktualis_block_id}=    Set Variable    0
    ${blokkon_beluli_sor_szam}=    Set Variable    0  # Blokkon belüli sor számláló
    
    ${aktualis_duplikacio_szamlaló}=    Set Variable    0
    ${max_duplikacio_szamlalo}=    Set Variable    0
        
    ${marker}=    Set Variable    .
    # Marker számlálók (kibővített rendszer)
    ${cnt_new_block}=    Set Variable    0    # [ új blokk
    ${cnt_dup_cont}=    Set Variable    0    # *
    ${cnt_suspect}=    Set Variable    0    # ?
    ${cnt_copied}=    Set Variable    0    # !
    ${cnt_normal}=    Set Variable    0    # .
    ${cnt_skip_db}=    Set Variable    0    # - adatbázis skip
    ${cnt_skip_len}=    Set Variable    0    # _ hossz miatti skip
  
    #
    # Fájl név és file_path kivonása (közös használatra)
    #
    ${file_name}=    Evaluate    os.path.basename(r"${DOCX_FILE}")    modules=os
    ${full_path}=    Evaluate    os.path.abspath(r"${DOCX_FILE}")    modules=os
    ${file_path}=    Evaluate    os.path.dirname(r"${full_path}")    modules=os
    IF     $True     #Escapelés
        # SQL escape-elés: apostrofok duplikálása
        ${file_name_esc}=    Replace String    ${file_name}    '    ''
        ${file_name_esc}=    Replace String    ${file_name_esc}    "    ""
        ${file_name_esc}=    Replace String    ${file_name_esc}    \n    ${EMPTY}
        ${file_name_esc}=    Replace String    ${file_name_esc}    \r    ${EMPTY}
        ${file_name_esc}=    Replace String    ${file_name_esc}    \t    ${EMPTY}
        ${file_path_esc}=    Replace String    ${file_path}    '    ''
        ${file_path_esc}=    Replace String    ${file_path_esc}    "    ""
        ${file_path_esc}=    Replace String    ${file_path_esc}    \n    ${EMPTY}
        ${file_path_esc}=    Replace String    ${file_path_esc}    \r    ${EMPTY}
        ${file_path_esc}=    Replace String    ${file_path_esc}    \t    ${EMPTY}
    END  

    # Korábbi rekordok törlése csak akkor, ha a file_name ÉS a file_path is megegyezik
    Execute Sql String    DELETE FROM hashCodes WHERE file_name = '${file_name}' AND file_path = '${file_path}'
    Execute Sql String    DELETE FROM repeat WHERE file_name = '${file_name}' AND file_path = '${file_path}'
    
    ${sor_index}=    Set Variable    0
    # REDUNDANCIA_ID globálissá tétele, ha más kulcsszóból is kellene
    Set Global Variable    ${REDUNDANCIA_ID}
    ${TOKEN_MIN}=    Evaluate    __import__('sys').path.append('libraries') or int(__import__('duplikacio_config').DuplikacioConfig().get('token_min', 10))
    # ${tul_rovid_szamlalo}=    Set Variable    0
    ${progress_counter}=    Set Variable    0

 # Aktuális dátum és idő megszerzése csak egyszer
    ${current_date}=    Evaluate    __import__('datetime').datetime.now().strftime(r'%Y-%m-%d')
    ${current_time}=    Evaluate    __import__('datetime').datetime.now().strftime(r'%H:%M:%S')
     FOR    ${sor}    IN    @{sorok}

       # Szerepel-e legalább 4 szóköz karakter a sor-ban?
        @{spaces}=    Split String    ${sor}    ${SPACE}
        ${space_count}=    Get Length    ${spaces}
        IF    ${space_count} < 4    
            # HIDDEN len-skip marker (nem írjuk ki a konzolra, csak a belső statisztikába számít)
            ${overview_string}=    Set Variable    ${overview_string}_
            ${cnt_skip_len}=    Evaluate    ${cnt_skip_len} + 1
            CONTINUE
        END
        #Tartalomjegyzék és ábrajegyzék átlépése
         #Log To Console    :${sor}
        # Ha a sor számmal kezdődik és számmal végződik, ugorjuk át
        ${starts_with_digit}=    Run Keyword And Return Status    Should Match Regexp    ${sor}    ^\[0-9].*\[0-9]$    flags=MULTILINE
        IF    ${starts_with_digit}         #and ${ends_with_digit}
            #Log String To Console    Skipp:${sor}
            CONTINUE
        END
        #Ha táblázattal kezdődik, ugorjuk át
        ${starts_with_tablazat}=    Run Keyword And Return Status    Should Match Regexp    ${sor}    ^\s*táblázat.*\[0-9]$    flags=MULTILINE
        IF    ${starts_with_tablazat}         #and ${ends_with_digit}
            #Log String To Console    Táblázat:${sor}
            CONTINUE
        END
        #Ha Ábrával kezdődik, ugorjuk át    
        ${starts_with_abra}=    Run Keyword And Return Status    Should Match Regexp    ${sor}    ^\s*ábra.*\[0-9]$    flags=MULTILINE
        IF    ${starts_with_abra}         #and ${ends_with_digit}
            #Log String To Console    Ábra:${sor}
            CONTINUE
        END
         #Ha Forrás:-sal kezdődik, ugorjuk át    
        ${starts_with_abra}=    Run Keyword And Return Status    Should Match Regexp    ${sor}    ^\s*forrás:.*$    flags=MULTILINE
        IF    ${starts_with_abra}         #and ${ends_with_digit}
            #Log String To Console    Ábra:${sor}
            CONTINUE
        END
        ${sor_hossz}=    Get Length    ${sor}
        #${tomoritett}=    Replace String Using Regexp    ${sor}    [^a-zA-ZáéíóöőúüűÁÉÍÓÖŐÚÜŰ]    ${EMPTY}
       
       # tömöritet számos otto was here
       ${tomoritett}=    Replace String Using Regexp    ${sor}    [^a-zA-Z0-9áéíóöőúüűÁÉÍÓÖŐÚÜŰ]    ${EMPTY}
       
       
        # Escape all problematic characters before Evaluate (replace with empty string)
        ${tomoritett_safe}=    Replace String    ${tomoritett}    '    ${EMPTY}
        ${tomoritett_safe}=    Replace String    ${tomoritett_safe}    "    ${EMPTY}
        ${tomoritett_safe}=    Replace String    ${tomoritett_safe}    \n    ${EMPTY}
        ${tomoritett_safe}=    Replace String    ${tomoritett_safe}    \r    ${EMPTY}
        ${tomoritett_safe}=    Replace String    ${tomoritett_safe}    \t    ${EMPTY}
        #Ha a tömörített sor hossza kisebb, mint a minimum, ugorjuk át
        IF    ${sor_hossz} < ${TOKEN_MIN}
            # HIDDEN len-skip marker (nem írjuk ki a konzolra, csak a belső statisztikába számít)
            ${overview_string}=    Set Variable    ${overview_string}_
            ${cnt_skip_len}=    Evaluate    ${cnt_skip_len} + 1
            CONTINUE
        END
        ${sor_index}=    Evaluate    ${sor_index} + 1
        #Log To Console    \n${sor_index}--> ${sor}}\n
        ${total_karakterszam}=    Evaluate    ${total_karakterszam} + ${sor_hossz}

        IF    True    # SQL escape-elés: apostrofok duplikálása
            ${escaped_sor}=    Replace String    ${sor}    '    ''
            ${escaped_sor}=    Replace String    ${escaped_sor}    "    ""  # dupla idézőjel escape
            ${escaped_sor}=    Replace String    ${escaped_sor}    \n    ${EMPTY}
            ${escaped_sor}=    Replace String    ${escaped_sor}    \r    ${EMPTY}
            ${escaped_sor}=    Replace String    ${escaped_sor}    \t    ${EMPTY}
        END
        
        #MD5 érték számolása
        ${md5}=    Evaluate    hashlib.md5(r'${tomoritett_safe}'.encode('utf-8')).hexdigest()    modules=hashlib
              
        # Ellenőrizzük, hogy létezik-e már ez a hash az adatbázisban
        @{results}=    Query    SELECT COUNT(*) FROM hashCodes WHERE hash_value = '${md5}'
        ${exists}=    Set Variable    0
        ${row}=    Get From List    ${results}    0
        ${row_value}=    Get From List    ${row}    0
        ${exists}=    Set Variable If    len(${results}) > 0    ${row_value}    0
        #Log To Console    ===== ${exists} / ${results}=====
        IF    $exists > 0     #már létezik
            #Log To Console  ${exists} - ${sor_index} ${sor} -->>>LÉTEZŐ  HASH<<<
            #lekérjük a benne lévő file_name és file_path értékét és escapeljük
            #ellenőrizzük, hogy a skipp értéke Igaz-e
            #Ha igen, akkor skippeljük a további feldolgozást
            @{source_result}=    Query    SELECT file_name, file_path, skipp FROM hashCodes WHERE hash_value = '${md5}'  LIMIT 1
            ${skipp_value}=    Set Variable    False
            IF    ${source_result.__len__()} > 0
                ${source_record}=    Get From List    ${source_result}    0
                ${skipp_value}=    Get From List    ${source_record}    2
            END
            IF    '${skipp_value}' == 'True' or ${skipp_value} == ${True}
                # Adatbázis által skippelt sor
                Log String To Console    -    no_newline=True
                ${overview_string}=    Set Variable    ${overview_string}-
                ${cnt_skip_db}=    Evaluate    ${cnt_skip_db} + 1
                CONTINUE
            END
            ${total_ismetelt_karakterszam}=    Evaluate    ${total_ismetelt_karakterszam} + ${sor_hossz}
            #@{source_result}=    Query    SELECT file_name, file_path FROM hashCodes WHERE hash_value = '${md5}'  LIMIT 1
            IF     True    #source_file kezelése
                ${source_file_name}=    Set Variable    unknown
                ${source_file_path}=    Set Variable    unknown
                IF    ${source_result.__len__()} > 0
                    ${source_record}=    Get From List    ${source_result}    0
                    ${source_file_name}=    Get From List    ${source_record}    0
                    ${source_file_path}=    Get From List    ${source_record}    1
                END
                ${_source_file_name_esc1}=    Replace String    ${source_file_name}    '    ''
                ${_source_file_name_esc2}=    Replace String    ${_source_file_name_esc1}    "    ""
                ${_source_file_name_esc3}=    Replace String    ${_source_file_name_esc2}    \n    ${EMPTY}
                ${_source_file_name_esc4}=    Replace String    ${_source_file_name_esc3}    \r    ${EMPTY}
                ${_source_file_name_esc5}=    Replace String    ${_source_file_name_esc4}    \t    ${EMPTY}
                ${source_file_name_esc}=    Replace String    ${_source_file_name_esc5}    \v    ${EMPTY}
                ${_source_file_path_esc1}=    Replace String    ${source_file_path}    '    ''
                ${_source_file_path_esc2}=    Replace String    ${_source_file_path_esc1}    "    ""
                ${_source_file_path_esc3}=    Replace String    ${_source_file_path_esc2}    \n    ${EMPTY}
                ${_source_file_path_esc4}=    Replace String    ${_source_file_path_esc3}    \r    ${EMPTY}
                ${source_file_path_esc}=    Replace String    ${_source_file_path_esc4}    \t    ${EMPTY}
                ${_tomoritett_esc1}=    Replace String    ${tomoritett}    '    ''
                ${_tomoritett_esc2}=    Replace String    ${_tomoritett_esc1}    "    ""
                ${_tomoritett_esc3}=    Replace String    ${_tomoritett_esc2}    \n    ${EMPTY}
                ${_tomoritett_esc4}=    Replace String    ${_tomoritett_esc3}    \r    ${EMPTY}
                ${tomoritett_esc}=    Replace String    ${_tomoritett_esc4}    \t    ${EMPTY}
        END            
     
            IF     ${elozo_duplikalt} == False
                #új ismétlési blokk kezdődik
                ${ismetelt_karakterszam}=    Set Variable    0
                ${in_group_ismetelt_karakterszam}=    Set Variable    0
                ${aktualis_block_id}=    Evaluate    ${aktualis_block_id} + 1
                ${marker}=    Set Variable    [
                ${cnt_new_block}=    Evaluate    ${cnt_new_block} + 1

            ELSE
                #folytatódik az ismétlési blokk
                 ${ismetelt_karakterszam}=    Evaluate    ${ismetelt_karakterszam} + ${sor_hossz}
                 ${max_ismetelt_karakterszam}=    Evaluate    max(${ismetelt_karakterszam}, ${max_ismetelt_karakterszam})
           
                 ${aktualis_duplikacio_szamlaló}=    Evaluate    ${aktualis_duplikacio_szamlaló} + 1
                ${marker}=    Set Variable    *
                ${cnt_dup_cont}=    Evaluate    ${cnt_dup_cont} + 1
            END
             ${elozo_duplikalt}=    Set Variable    True
            # Duplikált tartalom esetén számlálók növelése
            # Blokkon belüli sor szám növelése
            ${blokkon_beluli_sor_szam}=    Evaluate    ${blokkon_beluli_sor_szam} + 1
            ${total_ismetelt_karakterszam}=     Evaluate    ${sor_hossz} + ${total_ismetelt_karakterszam}
            ${in_group_ismetelt_karakterszam}=     Evaluate    ${sor_hossz} + ${in_group_ismetelt_karakterszam}
            
            ${max_total_ismetelt_karakterszam}=    Evaluate    max(${total_ismetelt_karakterszam}, ${max_total_ismetelt_karakterszam})
            ${max_duplikacio_szamlalo}=    Evaluate    max(${max_duplikacio_szamlalo}, ${aktualis_block_id})
           
           #Log To Console   ISMETELT_KARAKTERSZAM: ${ismetelt_karakterszam}        
              # Duplikált tartalom - ellenőrizzük a státuszt a jelenleg ismételt karakterszám alapján
                                 IF    ${ismetelt_karakterszam} < ${CONFIG_THRESHOLD_GYANUS}
                                     # Marad a blokk marker ([ vagy *) - no-op
                            No Operation
                        END
            IF        ${ismetelt_karakterszam} >= ${CONFIG_THRESHOLD_MASOLT}
                IF     '${current_status}' == 'Gyanús' or '${current_status}' == 'Üres'
                    ${current_status}=    Set Variable    Másolt
                END
                ${marker}=    Set Variable    !
                ${cnt_copied}=    Evaluate    ${cnt_copied} + 1
            END 
            IF    ${ismetelt_karakterszam} >= ${CONFIG_THRESHOLD_GYANUS} and ${ismetelt_karakterszam} < ${CONFIG_THRESHOLD_MASOLT}
                   IF     '${current_status}' == 'Rendben' or '${current_status}' == 'Üres'
                        ${current_status}=    Set Variable    Gyanús
                    END
                ${marker}=    Set Variable    ?
                ${cnt_suspect}=    Evaluate    ${cnt_suspect} + 1
                #Log To Console    ${marker} ${ismetelt_karakterszam}
            END
            #beírás repeat táblába
            Execute Sql String    INSERT INTO repeat (file_name, file_path, source_file_path, source_file_name, redundancia_id, repeat_block_nbr, block_id, line_length, repeated_line, token, created_date, created_time) VALUES ('${file_name_esc}', '${file_path}', '${source_file_path_esc}', '${source_file_name_esc}', ${REDUNDANCIA_ID}, ${blokkon_beluli_sor_szam}, ${aktualis_block_id}, ${sor_hossz}, '${escaped_sor}', '${tomoritett_esc}', '${current_date}', '${current_time}')
        ELSE
            #
            # Nem létezik a sor még a hash táblában F    '$exists = 0'
            #
            IF     '${current_status}' == 'Üres'
                ${current_status}=    Set Variable    Rendben
            END
            ${marker}=    Set Variable    .
            ${cnt_normal}=    Evaluate    ${cnt_normal} + 1
            #Log To Console    ${sor_index} ${sor} --<<<HIÁNYZÓ HASH>>>
            ${elozo_duplikalt}=    Set Variable    False
            ${blokkon_beluli_sor_szam}=    Set Variable    0  # Új blokk indítása esetén nullázás
            ${ismetelt_karakterszam}=    Set Variable    0       
            
        END
        # overview sor kiirása
        #Log To Console    ${marker} [${sor}]   no_newline=True    # duplikált tartalom
        Log String To Console    ${marker}    no_newline=True    # duplikált tartalom
        ${overview_string}=    Set Variable    ${overview_string}${marker}
        ${progress_counter}=    Evaluate    ${progress_counter} + 1
        # Manuális sortörések minden 100. és 1000. karakternél
        #Run Keyword If    ${progress_counter} % 1000 == 0    Log String To Console    \n\n    no_newline=True
        #Run Keyword If    ${progress_counter} % 100 == 0 and ${progress_counter} % 1000 != 0    Log String To Console    \n    no_newline=True
        
        #az első előfordulás hosszát is beszámítjuk
    ${sor_hossz}=    Get Length    ${sor}
    ${total_karakterszam}=    Evaluate    ${total_karakterszam} + ${sor_hossz}
        ${ismetelt_karakterszam}=    Evaluate    ${ismetelt_karakterszam} + ${sor_hossz}
        #Beírjuk a hash táblába
        Run Keyword And Ignore Error    Execute Sql String    INSERT INTO hashCodes (hash_value, file_name, file_path, created_date, created_time, used_by_nbr, skipp, line_content, redundancia_id) VALUES ('${md5}', '${file_name_esc}', '${file_path_esc}', '${current_date}', '${current_time}', 0, FALSE, '${escaped_sor}', ${REDUNDANCIA_ID})
        #Növeljük a használtság számlálót
        Execute Sql String    UPDATE hashCodes SET used_by_nbr = used_by_nbr + 1 WHERE hash_value = '${md5}'   

    END
 
    # Max értékek, status és overview mező update-je egyetlen SQL-ben, a végleges értékekkel (NORMÁL ÁG)
    #Set Global Variable    ${max_duplikacio_szamlaló}
    Set Global Variable    ${max_ismetelt_karakterszam}
    Set Global Variable    ${overview_string}
    Set Global Variable    ${aktualis_block_id}
    ${overview_string_trimmed}=    Strip String    ${overview_string}
    ${overview_string_esc}=    Replace String    ${overview_string_trimmed}    '    ''
    ${overview_string_esc}=    Replace String    ${overview_string_esc}    "    ""
    ${overview_string_esc}=    Replace String    ${overview_string_esc}    \n    ${EMPTY}
    ${overview_string_esc}=    Replace String    ${overview_string_esc}    \r    ${EMPTY}
    ${overview_string_esc}=    Replace String    ${overview_string_esc}    \t    ${EMPTY}

    ${repeated_percent}=    Evaluate    round(${max_total_ismetelt_karakterszam} / ${total_karakterszam} * 100, 2) if ${total_karakterszam} > 0 else 0



    Log String To Console    [>>> ${current_status} <<<]\n
    Execute Sql String    UPDATE redundancia SET repeat_block_nbr = ${aktualis_block_id}, max_ismetlesek_szama = ${max_duplikacio_szamlalo}, max_ismetelt_karakterszam = ${max_ismetelt_karakterszam}, repeated_percent = ${repeated_percent}, status = '${current_status}', overview = '${overview_string_esc}' WHERE id = ${REDUNDANCIA_ID}

    # Marker / sor statisztika debug célra
    ${marker_count}=    Get Length    ${overview_string}
    ${processed_line_count}=    Set Variable    ${sor_index}
    Log String To Console    MARKER_STATS markers=${marker_count} processed_lines=${processed_line_count}\n
    ${dup_total}=    Evaluate    ${cnt_new_block} + ${cnt_dup_cont} + ${cnt_suspect} + ${cnt_copied}
    ${skip_total}=    Evaluate    ${cnt_skip_db} + ${cnt_skip_len}
    Log String To Console    MARKER_BREAKDOWN [(new)=${cnt_new_block} *(cont)=${cnt_dup_cont} ?(suspect)=${cnt_suspect} !(copied)=${cnt_copied} .(normal)=${cnt_normal} - (db-skip)=${cnt_skip_db} _ (len-skip)=${cnt_skip_len} skip_total=${skip_total} dup_total=${dup_total}\n
    # Effektíven feldolgozott sorok és skip százalék (A pont)
    ${effective_processed}=    Evaluate    ${marker_count} - ${skip_total}
    ${skip_percent}=    Evaluate    round(${skip_total} / ${marker_count} * 100, 2) if ${marker_count} > 0 else 0
    Log String To Console    MARKER_EFFECTIVE effective_processed=${effective_processed} total=${marker_count} skip_total=${skip_total} skip_percent=${skip_percent}%\n
    Run Keyword If    ${cnt_skip_len} > 0    Log String To Console    MARKER_NOTE len-skip '_' karakterek elrejtve a konzolon (belsőleg számolva)\n
    Log String To Console    MARKER_LEGEND [=új duplikációs blokk kezdete, *=blokk folytatás, ?=gyanús küszöb, !=másolt küszöb, .=egyedi sor, -=adatbázis alapján skippelt, _=hossz / szóköz / minimális feltétel miatti skippelt\n

    #Execute Sql String    UPDATE redundancia SET repeat_block_nbr = ${aktualis_block_id} ,max_ismetlesek_szama = ${max_duplikacio_szamlalo}, max_ismetelt_karakterszam = ${max_total_ismetelt_karakterszam}, status = '${current_status}', overview = '${overview_string_esc}' WHERE id = ${REDUNDANCIA_ID}

    #Log To Console    [TRACE] DOCX Beolvasás Teszt kilépett
