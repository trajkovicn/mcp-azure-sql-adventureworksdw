![MCP](https://img.shields.io/badge/MCP-Model%20Context%20Protocol-purple)
![Azure SQL](https://img.shields.io/badge/Azure-SQL%20Database-blue)
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
MCP Client (VS Code + GitHub Copilot)
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
- VS Code (1.99+) with **GitHub Copilot** and **GitHub Copilot Chat** extensions
- ODBC Driver 18 for SQL Server ([download](https://learn.microsoft.com/sql/connect/odbc/download-odbc-driver-for-sql-server))

> **Tip:** If `pyodbc` install fails, it's almost always a missing ODBC driver.

## Verify your environment

Open a terminal (Command Prompt, PowerShell, or your shell of choice) and run the commands below. Confirm each tool is installed and meets the minimum version.

| Tool | Minimum version | Check command |
|---|---|---|
| **Git** | 2.40+ | `git --version` |
| **Python** | 3.10+ | `python --version` |
| **pip** | 22.0+ | `pip --version` |
| **VS Code** | 1.99+ | `code --version` |
| **ODBC Driver 18** | 18.x | see below |

**Check ODBC driver:**

```bash
# Windows (PowerShell)
Get-OdbcDriver | Where-Object Name -like "*ODBC Driver 18*"

# macOS / Linux
odbcinst -q -d | grep "ODBC Driver 18"
```

If any tool is missing or below the minimum version, install or update it before continuing.

> **Optional:**
>
> | Tool | Purpose | Check command |
> |---|---|---|
> | **Azure CLI** | Deploy your own Azure SQL (optional section) | `az --version` |
> | **Claude Desktop** | Alternative MCP client | Open the app → check version in *Settings* |

## 1) Clone the repo

```bash
git clone https://github.com/trajkovicn/mcp-azure-sql-adventureworksdw.git
cd mcp-azure-sql-adventureworksdw
```

## 2) Configure the MCP server connection

Open `.vscode/mcp.json` in your workspace and update the `env` values with the connection details provided by your instructor:

```json
{
  "servers": {
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

> **Note:** VS Code injects these environment variables directly into the MCP server process — no `.env` file is needed when using VS Code.

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

## 4) Connect VS Code to the MCP server

1. Open VS Code in the workspace (`code .`)
2. Open **Settings** (`Ctrl+,`) and search for `chat.mcp.enabled` — make sure it's checked
3. Open **Copilot Chat** (`Ctrl+Shift+I` or the Chat panel)
4. Switch to **Agent mode** (dropdown at the top of the chat panel)
5. Click the **Tools** icon — you should see the three MCP tools listed

If the tools don't appear, try reloading the window (`Ctrl+Shift+P` → *Developer: Reload Window*).

## 5) Try sample prompts

In the Copilot Chat panel (Agent mode), try these prompts to see MCP in action:

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

If you want to run your own database instead of using the shared one, you can provision an Azure SQL Server with the **AdventureWorksLT** sample database through the [Azure Portal](https://portal.azure.com).

## About AdventureWorksLT

**AdventureWorksLT** (Lightweight) is a sample OLTP database provided by Microsoft. It ships with Azure SQL Database as a built-in option — when you create a new database and select **"Sample"** as the data source, Azure automatically loads the AdventureWorksLT schema and data. No `.bacpac` import or seed scripts required.

The schema uses the `SalesLT` namespace and includes:

| Table | Description |
|---|---|
| `SalesLT.Customer` | Customer names, contact info, company |
| `SalesLT.Address` / `CustomerAddress` | Customer addresses |
| `SalesLT.Product` | Products with prices, colors, sizes |
| `SalesLT.ProductCategory` | Product category hierarchy |
| `SalesLT.ProductModel` / `ProductDescription` | Product metadata and descriptions |
| `SalesLT.SalesOrderHeader` | Order headers (date, status, totals) |
| `SalesLT.SalesOrderDetail` | Order line items (product, quantity, price) |

The sample data contains ~800 customers, ~300 products, and ~30,000 order line items.

## Database requirements

When creating your Azure SQL Database in the portal, use the following settings:

| Setting | Value |
|---|---|
| **Resource** | Azure SQL Database (single database) |
| **Database name** | `AdventureWorks` (or your preference) |
| **Data source** | **Sample** (loads AdventureWorksLT automatically) |
| **Service tier** | General Purpose |
| **Compute tier** | Serverless |
| **Compute hardware** | Standard-series (Gen5) |
| **vCores** | 1 (minimum) |
| **Auto-pause delay** | 1 hour (saves cost when idle) |
| **Max storage** | 32 GB (default is fine) |
| **Backup redundancy** | Locally-redundant (cheapest option) |
| **Authentication** | SQL authentication |

> **Estimated cost:** General Purpose Serverless with 1 vCore costs roughly **$0.50–$1.50/day** depending on activity. Auto-pause stops compute charges when the database is idle.

## Network access (required)

By default, Azure SQL blocks all external connections. To connect from your local machine, you need to configure network access on the **SQL server** resource (not the database):

1. Navigate to your **SQL server** in the Azure Portal
2. Go to **Networking** (under Security)
3. Under **Public network access**, select **Selected networks**
4. Under **Firewall rules**:
   - Click **+ Add your client IPv4 address** — this adds your current IP
   - For training purposes, you can add the rule `0.0.0.0` to `255.255.255.255` to allow all IPs (⚠️ not recommended for production)
5. Optionally check **Allow Azure services and resources to access this server**
6. Click **Save**

> **⚠️ Security note:** Public access with broad IP rules is acceptable for a short-lived training database. For production workloads, use [private endpoints](https://learn.microsoft.com/azure/azure-sql/database/private-endpoint-overview) or VNet service endpoints.

## Connect your MCP server

Once your database is provisioned, update your `.vscode/mcp.json`:

```json
"env": {
  "SQL_SERVER": "<your-server-name>.database.windows.net",
  "SQL_DATABASE": "AdventureWorks",
  "SQL_USER": "sqladmin",
  "SQL_PASSWORD": "<your-password>"
}
```

## 💰 Cleanup

**Always delete the resource group when you're done** to stop charges. You can do this in the Azure Portal by navigating to your resource group and clicking **Delete resource group**.

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
