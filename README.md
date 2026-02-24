![Azure SQL](https://img.shields.io/badge/Azure-SQL%20Database-blue)
![MCP](https://img.shields.io/badge/MCP-Model%20Context%20Protocol-purple)
![Python](https://img.shields.io/badge/Python-3.10%2B-blue)
![License](https://img.shields.io/badge/License-MIT-green)

# MCP + Azure SQL (AdventureWorksLT) Starter

> **Training goal:** Teach how MCP enables LLMs to safely, predictably, and transparently pull data from an external SQL database and use it for reasoning and responses.

A hands-on starter repo that connects a **Python MCP server** to an **Azure SQL Database** (AdventureWorksLT schema). You'll see firsthand how an LLM discovers available tools, calls them with structured parameters, receives typed results, and reasons over real data — all without writing raw SQL or giving the model direct database access.

---

## What you'll learn

| Concept | How this repo demonstrates it |
|---|---|
| **Tool discovery** | The MCP client automatically discovers the server's tools — no manual wiring needed |
| **Controlled access** | The server exposes only read-only, parameterized queries — the LLM never sees raw SQL |
| **Structured outputs** | Tools return typed JSON; the LLM can reason, summarise, or compare results naturally |
| **Transparency** | Every tool call is visible in the client UI — you can inspect what the LLM asked for and what it got back |
| **Separation of concerns** | Business logic lives in the server; the LLM focuses on language, intent, and presentation |

---

## What you get

- **Python MCP server** — three read-only tools over the AdventureWorksLT dataset
- **Sample prompts** — ready-to-use prompts to validate tool calls and LLM reasoning
- **Optional infrastructure** — Bicep/ARM templates + scripts to deploy your own Azure SQL Server + Database

---

## Architecture

```
MCP Client (Claude Desktop / VS Code / Agent)
        │
        │  MCP protocol (stdio)
        ▼
Python MCP Server  (server/src/server.py)
  ├─ top_customers_by_sales(year, limit)
  ├─ sales_by_category(year)
  └─ customer_orders(customer_id, limit)
        │
        │  ODBC (pyodbc)
        ▼
Azure SQL Database — AdventureWorksLT
  ├─ SalesLT.Customer
  ├─ SalesLT.Product / ProductCategory
  ├─ SalesLT.SalesOrderHeader
  └─ SalesLT.SalesOrderDetail
```

**Key point:** The LLM never connects to the database directly. It can only call the tools the server exposes, with the parameters each tool defines.

---

## Available MCP tools

| Tool | Parameters | Returns |
|---|---|---|
| `top_customers_by_sales` | `year` (int), `limit` (int, default 5) | Top N customers ranked by total sales for that year |
| `sales_by_category` | `year` (int) | Total sales grouped by product category for that year |
| `customer_orders` | `customer_id` (int), `limit` (int, default 25) | A customer's recent orders (order ID, date, status, total) |

All tools are **read-only** — they execute parameterized `SELECT` queries and return structured JSON.

---

# 🚀 Quickstart (Recommended): Use the Shared Read-Only Database

To keep the focus on **MCP concepts**, the recommended path uses a **shared, read-only database** hosted by the instructor / training environment.

## Prerequisites

- Git
- Python 3.10+ (3.11 recommended)
- ODBC Driver 18 for SQL Server ([download](https://learn.microsoft.com/sql/connect/odbc/download-odbc-driver-for-sql-server))
- An MCP client — e.g., [Claude Desktop](https://claude.ai/download) or any MCP-compatible client

> **Tip:** If `pyodbc` install fails, it's almost always a missing ODBC driver.

## Verify your environment

Open a terminal (Command Prompt, PowerShell, or your shell of choice) and run the commands below. Confirm each tool is installed and meets the minimum version.

| Tool | Minimum version | Check command |
|---|---|---|
| **Git** | 2.40+ | `git --version` |
| **Python** | 3.10+ | `python --version` |
| **pip** | 22.0+ | `pip --version` |
| **ODBC Driver 18** | 18.x | see below |

**Check ODBC driver:**

```bash
# Windows (PowerShell)
Get-OdbcDriver | Where-Object Name -like "*ODBC Driver 18*"

# macOS / Linux
odbcinst -q -d | grep "ODBC Driver 18"
```

If any tool is missing or below the minimum version, install or update it before continuing.

> **Optional but recommended:**
>
> | Tool | Purpose | Check command |
> |---|---|---|
> | **Azure CLI** | Deploy your own Azure SQL (optional section) | `az --version` |
> | **VS Code** | Recommended editor | `code --version` |
> | **Claude Desktop** | MCP client for testing | Open the app → check version in *Settings* |

## 1) Clone the repo

```bash
git clone https://github.com/trajkovicn/mcp-azure-sql-adventureworksdw.git
cd mcp-azure-sql-adventureworksdw
```

## 2) Create the `.env` file

Copy the provided template and fill in the values from your instructor:

```bash
# macOS / Linux
cp server/.env.example server/.env

# Windows (PowerShell)
Copy-Item server/.env.example server/.env
```

Then open `server/.env` and fill in the connection details:

```env
SQL_SERVER=<server>.database.windows.net
SQL_DATABASE=AdventureWorks
SQL_USER=sqladmin
SQL_PASSWORD=<password>
```

## 3) Install dependencies and run the server

```bash
cd server
python -m venv .venv

# macOS / Linux
source .venv/bin/activate

# Windows (PowerShell)
.\.venv\Scripts\Activate.ps1

pip install -r requirements.txt
python src/server.py
```

The server starts on **stdio** — it's now waiting for an MCP client to connect.

## 4) Connect an MCP client

### Claude Desktop

Add the server to your Claude Desktop config (see `client/claude_desktop_config.json.example`):

```json
{
  "mcpServers": {
    "adventureworks": {
      "command": "python",
      "args": ["-u", "server/src/server.py"],
      "env": {
        "SQL_SERVER": "<server>.database.windows.net",
        "SQL_DATABASE": "AdventureWorks",
        "SQL_USER": "<username>",
        "SQL_PASSWORD": "<password>"
      }
    }
  }
}
```

Restart Claude Desktop. You should see the three tools available in the tool picker.

## 5) Try sample prompts

Once connected, try these prompts to see MCP in action:

- *"Who are the top 5 customers by sales in 2008?"*
- *"Show sales by product category for 2008. Summarize in one paragraph."*
- *"Show me the most recent orders for customer 29825."*

The model will **automatically discover and call** the appropriate tools, then use the returned data to form its response. Watch the tool call panel to see exactly what happened.

> More prompts: `client/examples/sample_prompts.md`

---

## 🔍 What to observe (training exercises)

As you try the sample prompts, pay attention to:

1. **Tool selection** — Did the LLM pick the right tool? Why?
2. **Parameter inference** — How did the LLM decide which values to pass (e.g., `year=2008`)?
3. **Result interpretation** — How does the LLM present structured JSON as a natural-language answer?
4. **Multi-tool orchestration** — Try: *"Who is the top customer in 2008, and what did they order?"* — does the LLM chain two tool calls?
5. **Guardrails** — Try: *"Delete all customers"* — what happens when there's no tool for that?

---

# 🏗️ Optional: Deploy Your Own Azure SQL Database

If you want to run your own database instead of using the shared one, follow the steps below.

> **Note:** AdventureWorksLT comes **pre-loaded** when you create an Azure SQL Database with the sample dataset — no seed scripts needed.

## Prerequisites

- Azure subscription + permissions to create Azure SQL resources
- [Azure CLI](https://learn.microsoft.com/cli/azure/)

## Deploy to Azure (one-click)

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https://raw.githubusercontent.com/trajkovicn/mcp-azure-sql-adventureworksdw/main/infra/azuredeploy.json)

## Deploy to Azure (CLI)

```bash
az login
az account set --subscription "<SUBSCRIPTION_ID>"

chmod +x infra/deploy.sh

./infra/deploy.sh \
  -g rg-mcp-awdw \
  -l eastus \
  -n <globally-unique-sql-server-name> \
  -u sqladmin
```

This creates the Azure SQL Server + Database and writes `server/.env` with your connection settings.

## Clean up

```bash
./infra/destroy.sh -g rg-mcp-awdw
```

---

## Project structure

```
├── client/                          # MCP client configuration examples
│   ├── claude_desktop_config.json.example
│   └── examples/sample_prompts.md
├── infra/                           # Azure deployment (Bicep + ARM + scripts)
│   ├── main.bicep
│   ├── azuredeploy.json
│   ├── deploy.sh / deploy.ps1
│   └── destroy.sh / destroy.ps1
└── server/                          # Python MCP server
    ├── requirements.txt
    └── src/
        ├── server.py                # MCP server entry point (FastMCP)
        ├── db.py                    # Database connection helper
        └── tools/                   # One file per tool
            ├── customers.py
            ├── orders.py
            └── sales.py
```

---

## License

MIT
