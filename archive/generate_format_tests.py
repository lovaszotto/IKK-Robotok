#!/usr/bin/env python3
"""
Dinamikusan generálja a formálellenőrzési test case-eket minden DOCX fájlhoz
"""

import sys
import os
from pathlib import Path

def generate_test_cases(docx_files):
    """
    Generálja a Robot Framework test case-eket minden DOCX fájlhoz
    """
    
    test_template = """
{docx_filename} - Format Check Test 01 - Arculati Elemek
    [Documentation]    Arculati elemek ellenőrzése - {docx_file}
    [Tags]    formai    arculat    {docx_tag}
    Set Test Variable    ${{CURRENT_DOCX_FILE}}    {docx_file}
    ${{eredmeny}}=    Arculati Elemek Ellenorzese    {docx_file}
    Log    ${{eredmeny}}    console=yes
    Should Contain    ${{eredmeny}}    PASS
    Mark Test Case Complete    1

{docx_filename} - Format Check Test 02 - Kompetencia Teszt
    [Documentation]    Kompetencia teszt ellenőrzése - {docx_file}
    [Tags]    formai    kompetencia    {docx_tag}
    Set Test Variable    ${{CURRENT_DOCX_FILE}}    {docx_file}
    ${{eredmeny}}=    Kompetencia Teszt Ellenorzese    {docx_file}
    Log    ${{eredmeny}}    console=yes
    Should Contain    ${{eredmeny}}    PASS
    Mark Test Case Complete    2

{docx_filename} - Format Check Test 03 - Fogalomtar
    [Documentation]    Fogalomtár ellenőrzése - {docx_file}
    [Tags]    formai    fogalomtar    {docx_tag}
    Set Test Variable    ${{CURRENT_DOCX_FILE}}    {docx_file}
    ${{eredmeny}}=    Fogalomtar Ellenorzese    {docx_file}
    Log    ${{eredmeny}}    console=yes
    Should Contain    ${{eredmeny}}    PASS
    Mark Test Case Complete    3

{docx_filename} - Format Check Test 04 - Szerkesztoi Instrukciok
    [Documentation]    Szerkesztői instrukciók ellenőrzése - {docx_file}
    [Tags]    formai    instrukciok    {docx_tag}
    Set Test Variable    ${{CURRENT_DOCX_FILE}}    {docx_file}
    ${{eredmeny}}=    Szerkesztoi Instrukciok Ellenorzese    {docx_file}
    Log    ${{eredmeny}}    console=yes
    Should Contain    ${{eredmeny}}    PASS
    Mark Test Case Complete    4

{docx_filename} - Format Check Test 05 - Internet Hivatkozasok
    [Documentation]    Internet hivatkozások ellenőrzése - {docx_file}
    [Tags]    formai    hivatkozasok    {docx_tag}
    Set Test Variable    ${{CURRENT_DOCX_FILE}}    {docx_file}
    ${{eredmeny}}=    Internet Hivatkozasok Ellenorzese    {docx_file}
    Log    ${{eredmeny}}    console=yes
    Should Contain    ${{eredmeny}}    PASS
    Mark Test Case Complete    5

{docx_filename} - Format Check Test 06 - Szerzo Lektor
    [Documentation]    Szerző-lektor ellenőrzése - {docx_file}
    [Tags]    formai    szerzo    {docx_tag}
    Set Test Variable    ${{CURRENT_DOCX_FILE}}    {docx_file}
    ${{eredmeny}}=    Szerzo Lektor Ellenorzese    {docx_file}
    Log    ${{eredmeny}}    console=yes
    Should Contain    ${{eredmeny}}    PASS
    Mark Test Case Complete    6

{docx_filename} - Format Check Test 07 - Hosszu Idezetek
    [Documentation]    Hosszú idézetek ellenőrzése - {docx_file}
    [Tags]    formai    idezetek    {docx_tag}
    Set Test Variable    ${{CURRENT_DOCX_FILE}}    {docx_file}
    ${{eredmeny}}=    Hosszu Idezetek Ellenorzese    {docx_file}
    Log    ${{eredmeny}}    console=yes
    Should Contain    ${{eredmeny}}    PASS
    Mark Test Case Complete    7

{docx_filename} - Format Check Test 08 - Tordeles
    [Documentation]    Tördelés ellenőrzése - {docx_file}
    [Tags]    formai    tordeles    {docx_tag}
    Set Test Variable    ${{CURRENT_DOCX_FILE}}    {docx_file}
    ${{eredmeny}}=    Tordeles Ellenorzese    {docx_file}
    Log    ${{eredmeny}}    console=yes
    Should Contain    ${{eredmeny}}    PASS
    Mark Test Case Complete    8

{docx_filename} - Format Check Test 09 - Abrak Fotok
    [Documentation]    Ábrák/fotók ellenőrzése - {docx_file}
    [Tags]    formai    abrak    {docx_tag}
    Set Test Variable    ${{CURRENT_DOCX_FILE}}    {docx_file}
    ${{eredmeny}}=    Abrak Fotok Ellenorzese    {docx_file}
    Log    ${{eredmeny}}    console=yes
    Should Contain    ${{eredmeny}}    PASS
    Mark Test Case Complete    9

{docx_filename} - Format Check Test 10 - Felsorolas
    [Documentation]    Felsorolások ellenőrzése - {docx_file}
    [Tags]    formai    felsorolas    {docx_tag}
    Set Test Variable    ${{CURRENT_DOCX_FILE}}    {docx_file}
    ${{eredmeny}}=    Felsorolas Ellenorzese    {docx_file}
    Log    ${{eredmeny}}    console=yes
    Should Contain    ${{eredmeny}}    PASS
    Mark Test Case Complete    10

{docx_filename} - Format Check Test 11 - Ures Negyzetek
    [Documentation]    Üres négyzetek ellenőrzése - {docx_file}
    [Tags]    formai    ures_negyzetek    {docx_tag}
    Set Test Variable    ${{CURRENT_DOCX_FILE}}    {docx_file}
    ${{eredmeny}}=    Ures Negyzetek Ellenorzese    {docx_file}
    Log    ${{eredmeny}}    console=yes
    Should Contain    ${{eredmeny}}    PASS
    Mark Test Case Complete    11

{docx_filename} - Format Check Test 12 - Cimek Formatuma
    [Documentation]    Címek formátuma ellenőrzése - {docx_file}
    [Tags]    formai    cimek    {docx_tag}
    Set Test Variable    ${{CURRENT_DOCX_FILE}}    {docx_file}
    ${{eredmeny}}=    Cimek Formatuma Ellenorzese    {docx_file}
    Log    ${{eredmeny}}    console=yes
    Should Contain    ${{eredmeny}}    PASS
    Mark Test Case Complete    12

{docx_filename} - Format Check Test 13 - Oldalhatar
    [Documentation]    Oldalhatár ellenőrzése - {docx_file}
    [Tags]    formai    oldalhatar    {docx_tag}
    Set Test Variable    ${{CURRENT_DOCX_FILE}}    {docx_file}
    ${{eredmeny}}=    Oldalhatar Ellenorzese    {docx_file}
    Log    ${{eredmeny}}    console=yes
    Should Contain    ${{eredmeny}}    PASS
    Mark Test Case Complete    13

{docx_filename} - Format Check Test 14 - Betutipus
    [Documentation]    Betűtípus ellenőrzése - {docx_file}
    [Tags]    formai    betutipus    {docx_tag}
    Set Test Variable    ${{CURRENT_DOCX_FILE}}    {docx_file}
    ${{eredmeny}}=    Betutipus Ellenorzese    {docx_file}
    Log    ${{eredmeny}}    console=yes
    Should Contain    ${{eredmeny}}    PASS
    Mark Test Case Complete    14

{docx_filename} - Format Check Test 15 - Sorkoze
    [Documentation]    Sorköze ellenőrzése - {docx_file}
    [Tags]    formai    sorkoze    {docx_tag}
    Set Test Variable    ${{CURRENT_DOCX_FILE}}    {docx_file}
    ${{eredmeny}}=    Sorkoze Ellenorzese    {docx_file}
    Log    ${{eredmeny}}    console=yes
    Should Contain    ${{eredmeny}}    PASS
    Mark Test Case Complete    15

{docx_filename} - Format Check Test 16 - Labjegyzetek
    [Documentation]    Lábjegyzetek ellenőrzése - {docx_file}
    [Tags]    formai    labjegyzetek    {docx_tag}
    Set Test Variable    ${{CURRENT_DOCX_FILE}}    {docx_file}
    ${{eredmeny}}=    Labjegyzetek Ellenorzese    {docx_file}
    Log    ${{eredmeny}}    console=yes
    Should Contain    ${{eredmeny}}    PASS
    Mark Test Case Complete    16

{docx_filename} - Format Check Test 17 - Tartalomjegyzek
    [Documentation]    Tartalomjegyzék ellenőrzése - {docx_file}
    [Tags]    formai    tartalomjegyzek    {docx_tag}
    Set Test Variable    ${{CURRENT_DOCX_FILE}}    {docx_file}
    ${{eredmeny}}=    Tartalomjegyzek Ellenorzese    {docx_file}
    Log    ${{eredmeny}}    console=yes
    Should Contain    ${{eredmeny}}    PASS
    Mark Test Case Complete    17

{docx_filename} - Format Check Test 18 - Irodalomjegyzek
    [Documentation]    Irodalomjegyzék ellenőrzése - {docx_file}
    [Tags]    formai    irodalomjegyzek    {docx_tag}
    Set Test Variable    ${{CURRENT_DOCX_FILE}}    {docx_file}
    ${{eredmeny}}=    Irodalomjegyzek Ellenorzese    {docx_file}
    Log    ${{eredmeny}}    console=yes
    Should Contain    ${{eredmeny}}    PASS
    Mark Test Case Complete    18

{docx_filename} - Format Check Test 19 - Tablazatok
    [Documentation]    Táblázatok ellenőrzése - {docx_file}
    [Tags]    formai    tablazatok    {docx_tag}
    Set Test Variable    ${{CURRENT_DOCX_FILE}}    {docx_file}
    ${{eredmeny}}=    Tablazatok Ellenorzese    {docx_file}
    Log    ${{eredmeny}}    console=yes
    Should Contain    ${{eredmeny}}    PASS
    Mark Test Case Complete    19

{docx_filename} - Format Check Test 20 - Szoveg Igazitas
    [Documentation]    Szöveg igazítás ellenőrzése - {docx_file}
    [Tags]    formai    igazitas    {docx_tag}
    Set Test Variable    ${{CURRENT_DOCX_FILE}}    {docx_file}
    ${{eredmeny}}=    Szoveg Igazitas Ellenorzese    {docx_file}
    Log    ${{eredmeny}}    console=yes
    Should Contain    ${{eredmeny}}    PASS
    Mark Test Case Complete    20

{docx_filename} - Format Check Test 21 - Oldalszamozas
    [Documentation]    Oldalszámozás ellenőrzése - {docx_file}
    [Tags]    formai    oldalszamozas    {docx_tag}
    Set Test Variable    ${{CURRENT_DOCX_FILE}}    {docx_file}
    ${{eredmeny}}=    Oldalszamozas Ellenorzese    {docx_file}
    Log    ${{eredmeny}}    console=yes
    Should Contain    ${{eredmeny}}    PASS
    Mark Test Case Complete    21

{docx_filename} - Format Check Test 22 - Fejlec Lablec
    [Documentation]    Fejléc/lábléc ellenőrzése - {docx_file}
    [Tags]    formai    fejlec_lablec    {docx_tag}
    Set Test Variable    ${{CURRENT_DOCX_FILE}}    {docx_file}
    ${{eredmeny}}=    Fejlec Lablec Ellenorzese    {docx_file}
    Log    ${{eredmeny}}    console=yes
    Should Contain    ${{eredmeny}}    PASS
    Mark Test Case Complete    22

{docx_filename} - Format Check Test 23 - Helyesiras
    [Documentation]    Helyesírás ellenőrzése - {docx_file}
    [Tags]    formai    helyesiras    {docx_tag}
    Set Test Variable    ${{CURRENT_DOCX_FILE}}    {docx_file}
    ${{eredmeny}}=    Helyesiras Ellenorzese    {docx_file}
    Log    ${{eredmeny}}    console=yes
    Should Contain    ${{eredmeny}}    PASS
    Mark Test Case Complete    23
"""

    # Generate test cases for each DOCX file
    all_test_cases = []
    
    for docx_file in docx_files:
        # Extract filename without path and extension for cleaner test names
        filename = Path(docx_file).stem
        filename_tag = filename.replace(' ', '_').replace('-', '_').lower()
        
        test_case = test_template.format(
            docx_file=docx_file,
            docx_filename=filename,
            docx_tag=filename_tag
        )
        all_test_cases.append(test_case)
    
    return '\n'.join(all_test_cases)


if __name__ == "__main__":
    # Example usage with test files
    test_files = [
        r"c:\tmp\keziratok_teszteleshez\EM-1.1\EM-1.1.1\EM-1.1.1_RRF221_kompetencia_tesztek_kezirata.docx",
        r"c:\tmp\keziratok_teszteleshez\EM-1.1\EM-1.1.1\EM-1.1.1_RRF221_tema_kezirata.docx"
    ]
    
    # Generate test cases
    robot_content = generate_test_cases(test_files)
    
    # Create header
    header = '''*** Settings ***
Documentation    Dinamikusan generált formálellenőrzési test case-ek minden DOCX fájlhoz
Resource         resources/variables.robot
Resource         PLG-04-Formai_ellenor.robot
Resource         PLG-02-Excel-kitolto.robot

*** Variables ***
${CURRENT_DOCX_FILE}    ${EMPTY}
${CURRENT_EXCEL_FILE}    ${EMPTY}
${CURRENT_SHEET_NAME}    ${EMPTY}

*** Test Cases ***
'''
    
    # Write to file
    with open('PLG-04-Generated-FormaiEllenorzes.robot', 'w', encoding='utf-8') as f:
        f.write(header + robot_content)
    
    print("Generated PLG-04-Generated-FormaiEllenorzes.robot with test cases for all DOCX files")