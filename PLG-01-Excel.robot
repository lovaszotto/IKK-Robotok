*** Settings ***
Library    BuiltIn
Library    OperatingSystem
Library    String
Library    Collections
Library    Process

*** Variables ***
# Globális változók a path részekhez
${PARENT_PATH}    ${EMPTY}
${CHILD_PATH}     ${EMPTY}
${FILENAME}       ${EMPTY}
${INPUT_FOLDER}   ${EMPTY}
${CONFIG_OUTPUT_FOLDER}  ${EMPTY}

*** Keywords ***

Process DOCX File Parameter
    [Documentation]    DOCX fájl paraméter feldolgozása: path és filename szétválasztása, path validálása
    [Arguments]    ${docx_file}
    
    Log To Console    \n=== DOCX FÁJL ÚTVONAL FELDOLGOZÁSA ===
    Log To Console    Kapott paraméter: ${docx_file}
    
    # 1. Path és filename szétválasztása
    ${path_part}=    Evaluate    __import__('os').path.dirname(r"${docx_file}")    modules=os
    ${filename_part}=    Evaluate    __import__('os').path.basename(r"${docx_file}")    modules=os
    
    Log To Console    Path rész: ${path_part}
    Log To Console    Filename rész: ${filename_part}
    Log To Console    Input folder (globális): ${INPUT_FOLDER}
    
    # Globális változókba mentés
    Set Global Variable    ${FILENAME}    ${filename_part}
    
    # 2. Path szétbontása / jel mentén
    ${path_normalized}=    Replace String    ${path_part}    \\    /
    @{path_parts}=    Split String    ${path_normalized}    /
    
    # Üres elemek eltávolítása (pl. ha / jellel kezdődik az útvonal)
    ${filtered_parts}=    Create List
    FOR    ${part}    IN    @{path_parts}
        ${is_empty}=    Run Keyword And Return Status    Should Be Empty    ${part}
        IF    not ${is_empty}
            Append To List    ${filtered_parts}    ${part}
        END
    END
    
    # 3. Input folder részek eltávolítása a path elejéről
    ${relative_parts}=    Remove Input Folder From Path    ${filtered_parts}    ${INPUT_FOLDER}
    
    ${parts_count}=    Get Length    ${relative_parts}
    Log To Console    Path részek száma (input folder nélkül): ${parts_count}
    Log To Console    Relatív path részek: ${relative_parts}
    
    # 4. Ellenőrzés: legalább 2 részre kell bomlania (utolsó 2 könyvtár)
    IF    ${parts_count} < 2
        Log To Console    [HIBA] A relatív path nem tartalmaz legalább 2 könyvtárat! Talált részek: ${parts_count}
        Log To Console    [HIBA] Minimum: 2 rész, kapott: ${parts_count}
        Fail    A relatív path nem megfelelő szerkezetű - kevesebb mint 2 könyvtár
    END
    
    # 5. Utolsó 2 könyvtár kinyerése (parent és child)
    IF    ${parts_count} == 2
        ${parent_path}=    Get From List    ${relative_parts}    0
        ${child_path}=     Get From List    ${relative_parts}    1
    ELSE
        # Ha több mint 2 rész van, vegyük az utolsó kettőt
        ${second_last_idx}=    Evaluate    ${parts_count} - 2
        ${last_idx}=          Evaluate    ${parts_count} - 1
        ${parent_path}=    Get From List    ${relative_parts}    ${second_last_idx}
        ${child_path}=     Get From List    ${relative_parts}    ${last_idx}
    END
    
    # 6. Eredmények kiírása
    Log To Console    \n=== FELDOLGOZÁS EREDMÉNYE ===
    Log To Console    Parent Path: ${parent_path}
    Log To Console    Child Path: ${child_path}
    Log To Console    Filename: ${filename_part}
    Log To Console    \n=== FELDOLGOZÁS BEFEJEZVE ===
    
    # Excel fájl ellenőrzése
    Check Excel File Exists    ${parent_path}    ${child_path}


Remove Input Folder From Path
    [Documentation]    Input folder részek eltávolítása a path elejéről
    [Arguments]    ${path_parts}    ${input_folder}
    
    # Ha nincs input folder megadva, visszaadjuk az eredeti listát
    IF    '${input_folder}' == '${EMPTY}' or '${input_folder}' == ''
        Log To Console    [INFO] Nincs input folder megadva, eredeti path használata
        RETURN    ${path_parts}
    END
    
    # Input folder szétbontása
    @{input_parts}=    Split String    ${input_folder}    /
    ${input_filtered}=    Create List
    FOR    ${part}    IN    @{input_parts}
        ${is_empty}=    Run Keyword And Return Status    Should Be Empty    ${part}
        IF    not ${is_empty}
            Append To List    ${input_filtered}    ${part}
        END
    END
    
    ${input_count}=    Get Length    ${input_filtered}
    ${path_count}=     Get Length    ${path_parts}
    
    Log To Console    Input folder részek: ${input_filtered} (${input_count} db)
    Log To Console    Eredeti path részek: ${path_parts} (${path_count} db)
    
    # Ellenőrizzük, hogy a path elejei megegyeznek-e az input folder-rel
    ${matches}=    Set Variable    True
    IF    ${path_count} < ${input_count}
        Log To Console    [FIGYELEM] Path rövidebb mint az input folder!
        RETURN    ${path_parts}
    END
    
    FOR    ${i}    IN RANGE    ${input_count}
        ${path_part}=     Get From List    ${path_parts}    ${i}
        ${input_part}=    Get From List    ${input_filtered}    ${i}
        ${are_equal}=     Run Keyword And Return Status    Should Be Equal    ${path_part}    ${input_part}
        IF    not ${are_equal}
            ${matches}=    Set Variable    False
            Log To Console    [INFO] Eltérés a ${i}. pozícióban: '${path_part}' != '${input_part}'
            BREAK
        END
    END
    
    # Ha egyeznek, távolítsuk el az input folder részeket
    IF    ${matches}
        ${relative_parts}=    Create List
        FOR    ${i}    IN RANGE    ${input_count}    ${path_count}
            ${part}=    Get From List    ${path_parts}    ${i}
            Append To List    ${relative_parts}    ${part}
        END
        Log To Console    [SUCCESS] Input folder eltávolítva. Relatív path: ${relative_parts}
        RETURN    ${relative_parts}
    ELSE
        Log To Console    [INFO] Path nem kezdődik az input folder-rel, eredeti használata
        RETURN    ${path_parts}
    END

Validate Path Structure
    [Documentation]    Path struktúra validálása külön kulcsszóként
    [Arguments]    ${docx_file}
    
    ${path_part}=    Evaluate    __import__('os').path.dirname(r"${docx_file}")    modules=os
    ${path_normalized}=    Replace String    ${path_part}    \\    /
    @{path_parts}=    Split String    ${path_normalized}    /
    
    # Üres elemek szűrése
    ${valid_parts}=    Create List
    FOR    ${part}    IN    @{path_parts}
        ${is_not_empty}=    Run Keyword And Return Status    Should Not Be Empty    ${part}
        IF    ${is_not_empty}
            Append To List    ${valid_parts}    ${part}
        END
    END
    
    ${parts_count}=    Get Length    ${valid_parts}
    ${is_valid}=    Run Keyword And Return Status    Should Be Equal As Integers    ${parts_count}    2
    
    RETURN    ${is_valid}    ${valid_parts}

Check Excel File Exists
    [Documentation]    Ellenőrzi, hogy létezik-e a megadott parent_path alapján az Excel fájl az output_folder-ben
    [Arguments]    ${parent_path}    ${child_path}
    
    # Output folder használata a globális változóból
    ${output_folder}=    Set Variable    ${CONFIG_OUTPUT_FOLDER}
    
    # Excel fájl név összeállítása: {parent_path} + _v1.0.xlsx
    ${excel_filename}=    Set Variable   K_ell_${parent_path}_v1.0.xlsx
    ${excel_full_path}=    Join Path    ${output_folder}    ${excel_filename}
    
    # Fájl létezésének ellenőrzése
    ${file_exists}=    Run Keyword And Return Status    File Should Exist    ${excel_full_path}
    
    IF    ${file_exists}
        Log To Console    [INFO] Excel fájl létezik: ${excel_full_path}
        # Ellenőrizzük, hogy van-e megfelelő sheet az Excel-ben
        ${sheet_name}=    Set Variable    ${child_path}
        ${sheet_exists}=    Check Excel Sheet Exists    ${excel_full_path}    ${sheet_name}
        IF    ${sheet_exists}
            Log To Console    [INFO] Sheet '${sheet_name}' létezik az Excel fájlban
        ELSE
            Log To Console    [WARNING] Sheet '${sheet_name}' NEM létezik az Excel fájlban
            # EM X.Y sablont másoljuk át EM + child_path névre
            Copy Excel Sheet    ${excel_full_path}    EM X.Y    ${sheet_name}
            Log To Console    [INFO] Sheet sablon másolva: 'EM X.Y' -> '${sheet_name}'
        END
    ELSE
        Log To Console    [WARNING] Excel fájl NEM létezik: ${excel_full_path}
        # Sablon fájl másolása
        ${template_path}=    Set Variable    ${CURDIR}/sablonok/K ell sablon_sulyszam_minbizt_2024_12_v_1_0.xlsx
        Copy File    ${template_path}    ${excel_full_path}
        Log To Console    [INFO] Sablon fájl másolva: ${template_path} -> ${excel_full_path}
    END
    
    RETURN    ${file_exists}

Check Excel Sheet Exists
    [Documentation]    Ellenőrzi, hogy létezik-e a megadott sheet név az Excel fájlban
    [Arguments]    ${excel_file}    ${sheet_name}
    
    Log    [DEBUG] Checking sheet '${sheet_name}' in file: ${excel_file}
    
    # Python használata az Excel sheet-ek ellenőrzéséhez
    ${result}=    Evaluate    
    ...    __import__('openpyxl').load_workbook(r'${excel_file}').sheetnames.__contains__('${sheet_name}')
    ...    modules=openpyxl
    
    Log    [DEBUG] Sheet check result: ${result}
    
    RETURN    ${result}

Copy Excel Sheet
    [Documentation]    Másolja az egyik sheet-et a másikra az Excel fájlban
    [Arguments]    ${excel_file}    ${source_sheet_name}    ${target_sheet_name}
    
    Log    [DEBUG] Copying sheet '${source_sheet_name}' to '${target_sheet_name}' in file: ${excel_file}
    
    # Python script létrehozása egyszerű sheet másolással
    ${script_content}=    Catenate    SEPARATOR=\n
    ...    import openpyxl
    ...    try:
    ...    ${SPACE}${SPACE}${SPACE}${SPACE}wb = openpyxl.load_workbook(r'${excel_file}')
    ...    ${SPACE}${SPACE}${SPACE}${SPACE}if '${source_sheet_name}' in wb.sheetnames:
    ...    ${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}source_sheet = wb['${source_sheet_name}']
    ...    ${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}target_sheet = wb.copy_worksheet(source_sheet)
    ...    ${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}target_sheet.title = '${target_sheet_name}'
    ...    ${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}wb.save(r'${excel_file}')
    ...    ${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}print('SUCCESS')
    ...    ${SPACE}${SPACE}${SPACE}${SPACE}else:
    ...    ${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}print('SOURCE_NOT_FOUND')
    ...    ${SPACE}${SPACE}${SPACE}${SPACE}wb.close()
    ...    except Exception as e:
    ...    ${SPACE}${SPACE}${SPACE}${SPACE}print(f'ERROR: {e}')
    
    Create File    ${TEMPDIR}/copy_sheet.py    ${script_content}
    ${result}=    Run Process    python    ${TEMPDIR}/copy_sheet.py    shell=True
    
    Log    [DEBUG] Sheet copy result: ${result.stdout}
    
    ${success}=    Run Keyword And Return Status    Should Be Equal As Strings    ${result.stdout.strip()}    SUCCESS
    
    RETURN    ${success}