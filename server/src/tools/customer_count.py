from db import connect


def get_customer_count():
    """Return the total number of customers in the database."""
    query = "SELECT COUNT(*) AS CustomerCount FROM SalesLT.Customer;"

    with connect() as conn:
        cur = conn.cursor()
        row = cur.execute(query).fetchone()

    return {"customer_count": int(row.CustomerCount)}
