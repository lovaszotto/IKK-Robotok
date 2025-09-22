#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Konfiguráció Robot Framework számára
"""

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
    
    config_file = "Duplikacio.config"
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
        except:
            pass
    
    # Útvonalak normalizálása
    input_folder = os.path.normpath(config.get('input_folder', './test'))
    output_folder = os.path.normpath(config.get('output_folder', './test'))
    
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
        # Email részek eltávolítva - csak az alapvető konfigurációs értékek
        print(f"INPUT:{config['input_folder']}|OUTPUT:{config['output_folder']}|EXCEL_PREFIX:{config['excel_prefix']}|RENAME_PREFIX:{config['rename_prefix']}|THRESHOLD_GYANUS:{config['status_threshold_gyanus']}|THRESHOLD_MASOLT:{config['status_threshold_masolt']}", end='')
    except Exception as e:
        print(f"ERROR:{e}", end='')

if __name__ == "__main__":
    main()
