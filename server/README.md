# MCP Server

This folder contains a Python MCP server that exposes read-only tools backed by the **AdventureWorksDW** Azure SQL Database deployed by `infra/`.

## Run locally

```bash
cd server
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt

# Ensure server/.env exists (created by infra/deploy scripts)
python src/server.py
```

## What tools are included?

- `top_customers_by_sales(year, limit=5)`
- `sales_by_category(year)`
- `customer_orders(customer_key, limit=25)`

These query a **mini** AdventureWorksDW-style schema created by `seed/seed_minidw.*`.
