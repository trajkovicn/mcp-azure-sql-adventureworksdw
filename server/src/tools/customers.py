from db import connect


def get_top_customers_by_sales(year: int, limit: int = 5):
    """Return top customers by total sales amount in a given calendar year."""
    query = """
    SELECT TOP (?)
        c.CustomerID,
        c.FirstName,
        c.LastName,
        c.CompanyName,
        SUM(od.LineTotal) AS TotalSales
    FROM SalesLT.Customer c
    JOIN SalesLT.SalesOrderHeader oh ON c.CustomerID = oh.CustomerID
    JOIN SalesLT.SalesOrderDetail od ON oh.SalesOrderID = od.SalesOrderID
    WHERE YEAR(oh.OrderDate) = ?
    GROUP BY c.CustomerID, c.FirstName, c.LastName, c.CompanyName
    ORDER BY TotalSales DESC;
    """

    with connect() as conn:
        cur = conn.cursor()
        rows = cur.execute(query, limit, year).fetchall()

    return [
        {
            "customer_id": int(r.CustomerID),
            "first_name": r.FirstName,
            "last_name": r.LastName,
            "company_name": r.CompanyName,
            "total_sales": float(r.TotalSales),
        }
        for r in rows
    ]
