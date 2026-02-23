from ..db import connect


def get_sales_by_category(year: int):
    """Return total sales grouped by product category for a given year."""
    query = """
    SELECT
        p.ProductCategory,
        SUM(f.SalesAmount) AS TotalSales
    FROM dbo.FactInternetSales f
    JOIN dbo.DimProduct p ON f.ProductKey = p.ProductKey
    JOIN dbo.DimDate d ON f.OrderDateKey = d.DateKey
    WHERE d.CalendarYear = ?
    GROUP BY p.ProductCategory
    ORDER BY TotalSales DESC;
    """

    with connect() as conn:
        cur = conn.cursor()
        rows = cur.execute(query, year).fetchall()

    return [
        {"category": r.ProductCategory, "total_sales": float(r.TotalSales)}
        for r in rows
    ]
