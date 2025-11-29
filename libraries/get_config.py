
#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Konfiguráció Robot Framework számára
"""
import os
import sys

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
    # DEBUG üzenetek eltávolítva
    # debug_output.txt írása megszüntetve
    
    config_file = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "IKK.config"))
    # DEBUG üzenetek eltávolítva
    # debug_output.txt írása megszüntetve
   
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
            # DEBUG üzenetek eltávolítva
            # debug_output.txt írása megszüntetve
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
    # DEBUG üzenetek eltávolítva
    # debug_output.txt írása megszüntetve

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
        # DEBUG üzenetek eltávolítva
        # debug_output.txt írása megszüntetve
        print(f"INPUT:{config['input_folder']}|OUTPUT:{config['output_folder']}|EXCEL_PREFIX:{config['excel_prefix']}|RENAME_PREFIX:{config['rename_prefix']}|THRESHOLD_GYANUS:{config['status_threshold_gyanus']}|THRESHOLD_MASOLT:{config['status_threshold_masolt']}", end='')
    except Exception as e:
        print(f"\nERROR: {e}", end='')

if __name__ == "__main__":
    main()
