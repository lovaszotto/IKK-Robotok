*** Settings ***

Resource    ../resources/keywords.robot
Library     OperatingSystem

*** Test Cases ***
Should Contain File Returns False On Empty File
    [Documentation]    Teszt: üres fájlra a Should Contain File kulcsszó False-t ad vissza
    Create File    test/empty_testfile.txt    ${EMPTY}
    ${result}=    Should Contain File    test/empty_testfile.txt    valami_ami_nincs_benne
    Should Be Equal    ${result}    False
