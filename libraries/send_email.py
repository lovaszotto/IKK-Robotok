#!/usr/bin/env python3
"""
Email küldő script - LEGACY FÁJL
FIGYELEM: Ez a fájl már nem része a fő batch feldolgozásnak.
Az adatbázis kezelést eltávolítottuk a rendszerből.
Ez a fájl csak archív célokra marad meg.
"""
import os
import sys
import glob
from datetime import datetime

# A libraries könyvtár hozzáadása a path-hoz
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

def legacy_email_functionality_disabled():
    """
    LEGACY FUNKCIONALITÁS - LETILTVA
    Az email küldés funkcionalitás jelenleg nem aktív.
    Az adatbázis kezelést eltávolítottuk a rendszerből.
    """
    print("[INFO] Email küldés funkció jelenleg nem aktív")
    print("[INFO] Az adatbázis kezelést eltávolítottuk a rendszerből")
    return False
if __name__ == "__main__":
    """
    LEGACY MAIN - LETILTVA
    Az email küldés funkcionalitás jelenleg nem aktív.
    """
    print("[INFO] Email küldés script indítása...")
    print("[INFO] FIGYELEM: Ez egy legacy fájl, már nem aktív")
    print("[INFO] Az adatbázis kezelést eltávolítottuk a rendszerből")
    print("[INFO] A formálellenőrzés most közvetlenül Excel-be ír")
    
    success = legacy_email_functionality_disabled()
    
    if not success:
        print("[INFO] Email küldés nem történt meg (funkció letiltva)")
        print("[INFO] A formálellenőrzés eredményeit az Excel fájlban találja")
        exit(0)
