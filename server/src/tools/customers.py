from ..db import connect


def get_top_customers_by_sales(year: int, limit: int = 5):
    """Return top customers by sales amount in a given calendar year."""
    query = """
    SELECT TOP (?)
        c.CustomerKey,
        c.FirstName,
        c.LastName,
        SUM(f.SalesAmount) AS TotalSales
    FROM dbo.FactInternetSales f
    JOIN dbo.DimCustomer c ON f.CustomerKey = c.CustomerKey
    JOIN dbo.DimDate d ON f.OrderDateKey = d.DateKey
    WHERE d.CalendarYear = ?
    GROUP BY c.CustomerKey, c.FirstName, c.LastName
    ORDER BY TotalSales DESC;
    """

    with connect() as conn:
        cur = conn.cursor()
        rows = cur.execute(query, limit, year).fetchall()

    return [
        {
            "customer_key": int(r.CustomerKey),
            "first_name": r.FirstName,
            "last_name": r.LastName,
            "total_sales": float(r.TotalSales),
        }
        for r in rows
    ]
