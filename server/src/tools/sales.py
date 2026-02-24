from ..db import connect


def get_sales_by_category(year: int):
    """Return total sales grouped by product category for a given year."""
    query = """
    SELECT
        pc.Name AS ProductCategory,
        SUM(od.LineTotal) AS TotalSales
    FROM SalesLT.SalesOrderDetail od
    JOIN SalesLT.SalesOrderHeader oh ON od.SalesOrderID = oh.SalesOrderID
    JOIN SalesLT.Product p ON od.ProductID = p.ProductID
    JOIN SalesLT.ProductCategory pc ON p.ProductCategoryID = pc.ProductCategoryID
    WHERE YEAR(oh.OrderDate) = ?
    GROUP BY pc.Name
    ORDER BY TotalSales DESC;
    """

    with connect() as conn:
        cur = conn.cursor()
        rows = cur.execute(query, year).fetchall()

    return [
        {"category": r.ProductCategory, "total_sales": float(r.TotalSales)}
        for r in rows
    ]
