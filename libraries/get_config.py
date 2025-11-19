
#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Konfiguráció Robot Framework számára
"""
import os
import sys
print(f"DEBUG: Working directory: {os.getcwd()}", file=sys.stderr)

import os

def load_simple_config():
    """Egyszerű konfiguráció betöltés debug üzenetek nélkül"""
    config = {
        'input_folder': './test',
        'output_folder': './test',
        'database_file': 'test_database.db',
        'excel_prefix': 'duplikacio_export',
        'status_threshold_gyanus': '300',
        'status_threshold_masolt': '1200'
    }
    # Log alapértelmezett értékek
    msg1 = f"DEBUG (alap config): input_folder = {config['input_folder']}"
    msg2 = f"DEBUG (alap config): output_folder = {config['output_folder']}"
    print(msg1)
    print(msg2)
    print(msg1, file=sys.stderr)
    print(msg2, file=sys.stderr)
    try:
        with open("debug_output.txt", "a", encoding="utf-8") as dbg:
            dbg.write(msg1 + "\n")
            dbg.write(msg2 + "\n")
    except Exception as file_err:
        print(f"DEBUG fájlírás hiba (alap config): {file_err}")
    
    config_file = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "IKK.config"))
    msg_path = f"DEBUG: keresett config_file = {config_file}"
    print(msg_path)
    print(msg_path, file=sys.stderr)
    try:
        with open("debug_output.txt", "a", encoding="utf-8") as dbg:
            dbg.write(msg_path + "\n")
    except Exception as file_err:
        print(f"DEBUG fájlírás hiba (config path): {file_err}")
   
    if os.path.exists(config_file):
        try:
            with open(config_file, 'r', encoding='utf-8') as f:
                lines = f.readlines()
            for line in lines:
                line = line.strip()
                if not line or line.startswith('#'):
                    continue
                if '=' in line:
                    key, value = line.split('=', 1)
                    key = key.strip()
                    value = value.strip()
                    config[key] = value
            # Log config fájl beolvasás után
            msg3 = f"DEBUG (configból): input_folder = {config.get('input_folder')}"
            msg4 = f"DEBUG (configból): output_folder = {config.get('output_folder')}"
            print(msg3)
            print(msg4)
            print(msg3, file=sys.stderr)
            print(msg4, file=sys.stderr)
            try:
                with open("debug_output.txt", "a", encoding="utf-8") as dbg:
                    dbg.write(msg3 + "\n")
                    dbg.write(msg4 + "\n")
            except Exception as file_err:
                print(f"DEBUG fájlírás hiba (configból): {file_err}")
        except Exception as e:
            print(f"ERROR: Konfigurációs fájl olvasási hiba: {e}", end='')
            raise
    else:
        print(f"ERROR: Konfigurációs fájl nem található: {config_file}", end='')
        raise FileNotFoundError(f"Konfigurációs fájl nem található: {config_file}")
    
    # Útvonalak normalizálása
    input_folder = os.path.normpath(config.get('input_folder', './tmp'))
    output_folder = os.path.normpath(config.get('output_folder', './tmp'))

    # Hibakereső logolás: input/output mappa létezik-e
    msg_input_exists = f"DEBUG: input_folder létezik: {input_folder} -> {os.path.exists(input_folder)}"
    msg_output_exists = f"DEBUG: output_folder létezik: {output_folder} -> {os.path.exists(output_folder)}"
    print(msg_input_exists)
    print(msg_output_exists)
    print(msg_input_exists, file=sys.stderr)
    print(msg_output_exists, file=sys.stderr)
    try:
        with open("debug_output.txt", "a", encoding="utf-8") as dbg:
            dbg.write(msg_input_exists + "\n")
            dbg.write(msg_output_exists + "\n")
    except Exception as file_err:
        print(f"DEBUG fájlírás hiba (input/output exists): {file_err}")

    return {
        'input_folder': input_folder,
        'output_folder': output_folder,
        'excel_prefix': config.get('excel_prefix', 'duplikacio_export'),
        'rename_prefix': config.get('rename_prefix', ''),
        'status_threshold_gyanus': int(config.get('status_threshold_gyanus', '300')),
        'status_threshold_masolt': int(config.get('status_threshold_masolt', '1200'))
    }

def main():
    try:
        config = load_simple_config()
        msg5 = f"DEBUG: input_folder = {config['input_folder']}"
        msg6 = f"DEBUG: output_folder = {config['output_folder']}"
        print(msg5)
        print(msg6)
        print(msg5, file=sys.stderr)
        print(msg6, file=sys.stderr)
        try:
            with open("debug_output.txt", "a", encoding="utf-8") as dbg:
                dbg.write(msg5 + "\n")
                dbg.write(msg6 + "\n")
        except Exception as file_err:
            print(f"DEBUG fájlírás hiba (main): {file_err}")
        print(f"INPUT:{config['input_folder']}|OUTPUT:{config['output_folder']}|EXCEL_PREFIX:{config['excel_prefix']}|RENAME_PREFIX:{config['rename_prefix']}|THRESHOLD_GYANUS:{config['status_threshold_gyanus']}|THRESHOLD_MASOLT:{config['status_threshold_masolt']}", end='')
    except Exception as e:
        print(f"\nERROR: {e}", end='')

if __name__ == "__main__":
    main()
