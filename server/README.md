# MCP Server

This folder contains a Python MCP server that exposes read-only tools backed by the **AdventureWorksLT** Azure SQL Database.

## Run locally

```bash
cd server
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt

# Ensure server/.env exists with SQL_SERVER, SQL_DATABASE, SQL_USER, SQL_PASSWORD
python src/server.py
```

## What tools are included?

- `top_customers_by_sales(year, limit=5)`
- `sales_by_category(year)`
- `customer_orders(customer_id, limit=25)`

These query the `SalesLT` schema in AdventureWorksLT (Customer, Product, ProductCategory, SalesOrderHeader, SalesOrderDetail).
