import os
import sys
from pathlib import Path

import pyodbc
from dotenv import load_dotenv


def main():
    root = Path(__file__).resolve().parents[1]
    load_dotenv(root / "server" / ".env")

    server = os.getenv("SQL_SERVER")
    database = os.getenv("SQL_DATABASE", "AdventureWorksDW")
    user = os.getenv("SQL_USER")
    password = os.getenv("SQL_PASSWORD")

    if not all([server, database, user, password]):
        print("Missing SQL connection settings. Ensure server/.env exists (created by infra/deploy scripts).")
        sys.exit(1)

    sql_path = root / "seed" / "sql" / "minidw.sql"
    script = sql_path.read_text(encoding="utf-8")

    conn_str = (
        "Driver={ODBC Driver 18 for SQL Server};"
        f"Server={server};"
        f"Database={database};"
        f"Uid={user};"
        f"Pwd={password};"
        "Encrypt=yes;TrustServerCertificate=no;Connection Timeout=30;"
    )

    print(f"Connecting to {server}/{database}...")
    with pyodbc.connect(conn_str, autocommit=True) as conn:
        cursor = conn.cursor()
        # Split on GO batch separators
        batches = []
        current = []
        for line in script.splitlines():
            if line.strip().upper() == "GO":
                if current:
                    batches.append("\n".join(current))
                    current = []
            else:
                current.append(line)
        if current:
            batches.append("\n".join(current))

        for i, batch in enumerate(batches, start=1):
            if batch.strip():
                cursor.execute(batch)

    print("Seed completed: Mini AdventureWorksDW tables + data are ready.")


if __name__ == "__main__":
    main()
