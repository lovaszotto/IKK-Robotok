import sqlite3

# Connect to the database
conn = sqlite3.connect('resources/test_database.db')
cursor = conn.cursor()

# Get table info
cursor.execute("PRAGMA table_info(hashCodes)")
columns = cursor.fetchall()

print("hashCodes tábla oszlopai:")
for col in columns:
    print(f"  {col[1]} ({col[2]})")

# Get all table names
cursor.execute("SELECT name FROM sqlite_master WHERE type='table'")
tables = cursor.fetchall()

print("\nMeglévő táblák:")
for table in tables:
    print(f"  {table[0]}")

conn.close()