from ..db import connect


def get_customer_orders(customer_id: int, limit: int = 25):
    """Return a simple order history for a customer."""
    query = """
    SELECT TOP (?)
        oh.SalesOrderID,
        oh.OrderDate,
        oh.Status,
        SUM(od.LineTotal) AS OrderTotal
    FROM SalesLT.SalesOrderHeader oh
    JOIN SalesLT.SalesOrderDetail od ON oh.SalesOrderID = od.SalesOrderID
    WHERE oh.CustomerID = ?
    GROUP BY oh.SalesOrderID, oh.OrderDate, oh.Status
    ORDER BY oh.OrderDate DESC;
    """

    with connect() as conn:
        cur = conn.cursor()
        rows = cur.execute(query, limit, customer_id).fetchall()

    return [
        {
            "sales_order_id": int(r.SalesOrderID),
            "order_date": str(r.OrderDate),
            "status": int(r.Status),
            "order_total": float(r.OrderTotal),
        }
        for r in rows
    ]
