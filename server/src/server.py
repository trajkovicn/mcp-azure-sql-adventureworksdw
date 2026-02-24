"""MCP server exposing read-only tools over the AdventureWorksLT dataset."""

import os
from dotenv import load_dotenv

# FastMCP is the quickest way to stand up a server with tool decorators.
from mcp.server.fastmcp import FastMCP

from tools.customers import get_top_customers_by_sales
from tools.sales import get_sales_by_category
from tools.orders import get_customer_orders


def load_env():
    here = os.path.dirname(__file__)
    env_path = os.path.join(here, "..", ".env")
    if os.path.exists(env_path):
        load_dotenv(env_path)


load_env()

mcp = FastMCP("adventureworks-mcp")


@mcp.tool()
def top_customers_by_sales(year: int, limit: int = 5):
    """Get the top customers by total sales for a given year."""
    return get_top_customers_by_sales(year=year, limit=limit)


@mcp.tool()
def sales_by_category(year: int):
    """Get total sales grouped by product category for a given year."""
    return get_sales_by_category(year=year)


@mcp.tool()
def customer_orders(customer_id: int, limit: int = 25):
    """Get a customer's recent orders (order ID, date, status, total)."""
    return get_customer_orders(customer_id=customer_id, limit=limit)


if __name__ == "__main__":
    # Runs using stdio transport by default for desktop clients.
    mcp.run()
