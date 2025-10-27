import os
import sqlite3

backups = sorted(
    [d for d in os.listdir(".") if os.path.isdir(d) and d.startswith("2025-")]
)

if not backups:
    print("No backups found!")
    exit(1)

print("\n" + "=" * 60)
print(" Available Backups")
print("=" * 60)
for i, backup in enumerate(backups, 1):
    marker = " [most recent]" if i == len(backups) else ""
    print(f" {i:2d}. {backup}{marker}")
print("=" * 60)

default_backup = backups[-1]
choice = input(f"\nSelect backup number (default: {len(backups)}): ").strip()

if choice == "":
    selected_backup = default_backup
    print("Using most recent backup")
else:
    try:
        backup_index = int(choice) - 1
        if 0 <= backup_index < len(backups):
            selected_backup = backups[backup_index]
        else:
            print("Invalid selection. Using most recent backup.")
            selected_backup = default_backup
    except ValueError:
        print("Invalid input. Using most recent backup.")
        selected_backup = default_backup

db_path = os.path.join(selected_backup, "data.db")
print(f"\nProcessing backup: {selected_backup}")

conn = sqlite3.connect(db_path)
cursor = conn.cursor()

cursor.execute("SELECT title, path FROM pages ORDER BY id")
rows = cursor.fetchall()

output_file = f"combined_{selected_backup}.md"

print(f"\nExtracting {len(rows)} pages...\n")

with open(output_file, "w", encoding="utf-8") as out_md:
    out_md.write(f"# Combined pages (from backup {selected_backup})\n\n")
    out_md.write("---\n")

    for idx, (title, path) in enumerate(rows, 1):
        full_path = os.path.join(selected_backup, path)

        print(f"[{idx}/{len(rows)}] {title} ({path})")

        out_md.write(f"\n## {title}\n\n")
        try:
            if os.path.exists(full_path):
                with open(full_path, "r", encoding="utf-8") as md_file:
                    content = md_file.read()
                    out_md.write(content + "\n")
            else:
                out_md.write(f"*Warning: File '{full_path}' not found.*\n\n")
                print("WARNING: File not found!")
        except Exception as e:
            out_md.write(f"*Error reading '{full_path}': {e}*\n\n")
            print(f"ERROR: {e}")

conn.close()
print("\n" + "=" * 60)
print(f"Combined markdown written to: {output_file}")
print("=" * 60)
