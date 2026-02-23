import os
import pyodbc


def connect():
    server = os.environ["SQL_SERVER"]
    database = os.environ.get("SQL_DATABASE", "AdventureWorksDW")
    user = os.environ["SQL_USER"]
    password = os.environ["SQL_PASSWORD"]

    conn_str = (
        "Driver={ODBC Driver 18 for SQL Server};"
        f"Server={server};"
        f"Database={database};"
        f"Uid={user};"
        f"Pwd={password};"
        "Encrypt=yes;TrustServerCertificate=no;Connection Timeout=30;"
    )
    return pyodbc.connect(conn_str)
