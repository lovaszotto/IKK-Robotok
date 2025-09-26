*** Settings ***
Documentation    Test script for single DOCX file processing with format checks
Resource         resources/keywords.robot
Resource         resources/variables.robot
Library          Process

*** Test Cases ***

Test Single DOCX Processing
    [Documentation]    Tests the complete processing of a single DOCX file including format checks
    
    # Initialize global log file
    Initialize Global Log File
    
    # Load configuration 
    Konfiguráció Betöltése
    
    # Move log file to output folder after config is loaded
    Move Log File To Output Folder
    
    # Connect to database
    Kapcsolodas Az Adatbazishoz
    
    # Initialize database tables
    Hash táblák ellenőrzése
    
    # Set test DOCX file
    ${test_docx_path}=    Evaluate    os.path.abspath("test/Kézirat.docx")    modules=os
    Set Global Variable    ${DOCX_FILE}    ${test_docx_path}
    
    # Test the Create Excel and format check process
    ${activeExcelFile}    ${activeSheetName}=    Create_K_ell_Excel    ${DOCX_FILE}
    
    # Set global variables for format checking
    Set Global Variable    ${CURRENT_EXCEL_FILE}    ${activeExcelFile}
    Set Global Variable    ${CURRENT_SHEET_NAME}    ${activeSheetName}
    Set Global Variable    ${CURRENT_DOCX_FILE}    ${DOCX_FILE}
    
    # Read DOCX file
    ${szoveg}=    Beolvasom A DOCX Fájlt
    Set Global Variable    ${SZOVEG}    ${szoveg}
    
    # Process file data into redundancia table
    ${is_error}=    Run Keyword And Return Status    Should Start With    ${szoveg}    [HIBA]
    ${redundancia_id}=    Fájladatok Feldolgozása Redundancia Táblába    ${DOCX_FILE}    ${is_error}    ${szoveg}
    
    # Run format checks
    Log    === STARTING FORMAT CHECKS ===    console=yes
    Run Formai Ellenorzes    ${DOCX_FILE}
    Log    === FORMAT CHECKS COMPLETED ===    console=yes
    
    # Clean up
    Adatbazis Kapcsolat Bezarasa
    
    Log    === SINGLE DOCX PROCESSING COMPLETED ===    console=yes