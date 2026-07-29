import csv
import sqlite3
import os

# 1. Initialize SQLite Database
conn = sqlite3.connect("hsk_dictionary.sqlite")
cursor = conn.cursor()

# cursor.execute("DROP TABLE IF EXISTS vocabulary;")
# cursor.execute("DROP INDEX IF EXISTS idx_level;")
# cursor.execute("DROP INDEX IF EXISTS idx_word;")
# cursor.execute("DROP INDEX IF EXISTS idx_pinyin;")
# 2. Create the streamlined schema
cursor.execute("""
CREATE TABLE IF NOT EXISTS vocabulary (
    id TEXT PRIMARY KEY,
    level TEXT NOT NULL,
    word TEXT NOT NULL,
    pinyin TEXT NOT NULL,
    pinyin_numbered TEXT NOT NULL,
    part_of_speech TEXT,
    definition TEXT NOT NULL
);
""")

# 3. Add Indexes for rapid SwiftUI querying
# cursor.execute("CREATE INDEX IF NOT EXISTS idx_level ON vocabulary(level);")
cursor.execute("CREATE INDEX IF NOT EXISTS idx_word ON vocabulary(word);")
cursor.execute("CREATE INDEX IF NOT EXISTS idx_pinyin ON vocabulary(pinyin_numbered);")

# 4. Parse TSV and insert selected columns
# 1. Get the directory where this current script is saved
script_dir = os.path.dirname(os.path.abspath(__file__))

# 2. Join that directory path with your TSV file name
tsv_file_path = os.path.join(script_dir, "hsk_word_list.tsv")
inserted_rows = 0

with open(tsv_file_path, mode="r", newline="\n") as file:
    lines = file.readlines()
    file.seek(0)  # Ensure we're at the start of the file
    reader = csv.DictReader(file, delimiter="\t")
    print("Detected columns:", reader.fieldnames)

    for idx, row in enumerate(reader, start=1):
        print(row['level'].strip())
        word_id = str(idx)
        cursor.execute("""
        INSERT OR REPLACE INTO vocabulary 
        (id, level, word, pinyin, pinyin_numbered, part_of_speech, definition)
        VALUES (?, ?, ?, ?, ?, ?, ?);
        """, (
            word_id,
            row['level'].strip(),
            row['word'],
            row['pinyin'],
            row['pinyin_numbered'],
            row['part_of_speech'],
            row['definition_cc-cedict']
        ))
        inserted_rows += 1

conn.commit()
conn.close()

print(f"Successfully created hsk_dictionary.sqlite with {inserted_rows} entries!")
absolute_path = os.path.abspath("hsk_dictionary.sqlite")

print(f"Your database file is saved here:\n{absolute_path}")