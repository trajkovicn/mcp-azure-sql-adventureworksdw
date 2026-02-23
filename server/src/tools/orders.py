from ..db import connect


def get_customer_orders(customer_key: int, limit: int = 25):
    """Return a simple order history for a customer."""
    query = """
    SELECT TOP (?)
        f.SalesOrderNumber,
        d.FullDateAlternateKey AS OrderDate,
        SUM(f.SalesAmount) AS OrderTotal
    FROM dbo.FactInternetSales f
    JOIN dbo.DimDate d ON f.OrderDateKey = d.DateKey
    WHERE f.CustomerKey = ?
    GROUP BY f.SalesOrderNumber, d.FullDateAlternateKey
    ORDER BY d.FullDateAlternateKey DESC;
    """

    with connect() as conn:
        cur = conn.cursor()
        rows = cur.execute(query, limit, customer_key).fetchall()

    return [
        {
            "sales_order_number": r.SalesOrderNumber,
            "order_date": str(r.OrderDate),
            "order_total": float(r.OrderTotal),
        }
        for r in rows
    ]
