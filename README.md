[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https://raw.githubusercontent.com/trajkovicn/mcp-azure-sql-adventureworksdw/main/infra/azuredeploy.json)
![Azure SQL](https://img.shields.io/badge/Azure-SQL%20Database-blue)
![MCP](https://img.shields.io/badge/MCP-Model%20Context%20Protocol-purple)
![Python](https://img.shields.io/badge/Python-3.10%2B-blue)
![License](https://img.shields.io/badge/License-MIT-green)

# MCP + Azure SQL (AdventureWorksDW) Starter

A reproducible starter repo to help you learn **MCP (Model Context Protocol)** by exposing **read-only tools** over an **Azure SQL Database**.

> ✅ Designed for: Azure subscription + Azure CLI + Python + VS Code.

## What you get

- **One-command infrastructure**: deploy Azure SQL Server + Database (Bicep + Azure CLI)
- **One-command seed**: load a small *AdventureWorksDW-like* dataset into Azure SQL Database
- **Python MCP server**: exposes a few useful tools over the dataset
- **Polished DX**: deploy, seed, run, and destroy scripts

## Architecture

```
MCP Client (Claude Desktop / Agent)
        |
        | MCP (stdio)
        v
Python MCP Server (server/src/server.py)
        |
        | ODBC (pyodbc)
        v
Azure SQL Database (AdventureWorksDW)
```

---

## 🚀 Deploy to Azure

This repository includes an Azure Resource Manager (ARM) template that deploys
an Azure SQL Server and database required for the MCP starter.

Click the button below to deploy directly into your Azure subscription:

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https://raw.githubusercontent.com/trajkovicn/mcp-azure-sql-adventureworksdw/main/infra/azuredeploy.json)



---

## Prerequisites

- Azure subscription + permissions to create Azure SQL resources
- [Azure CLI](https://learn.microsoft.com/cli/azure/)
- Python 3.10+ (3.11 recommended)
- ODBC Driver 18 for SQL Server

> Tip: if `pyodbc` install fails, it’s usually due to missing ODBC drivers.

---

## 💰 Cost & Cleanup Warning

This project deploys **Azure SQL Database**, which is a **billable Azure resource**.

While this starter uses **low-cost defaults**, charges will continue to accrue
as long as the resources exist in your subscription.

### What gets created
- Azure SQL logical server
- Azure SQL Database (`AdventureWorksDW`)
- Firewall rules

### Important
- This repo is intended for **learning and experimentation**
- **Do not leave resources running** when you are finished
- Always delete the resource group to stop charges

### Clean up when finished
```bash
./infra/destroy.sh -g <your-resource-group>

## Quickstart (Azure CLI)

### 1) Login and select subscription

```bash
az login
az account set --subscription "<SUBSCRIPTION_ID>"
```

### 2) Deploy Azure SQL (Bicep)

```bash
chmod +x infra/deploy.sh infra/destroy.sh seed/seed_minidw.sh

./infra/deploy.sh \
  -g rg-mcp-awdw \
  -l eastus \
  -n <globally-unique-sql-server-name> \
  -u sqladmin
```

This writes `server/.env` with your connection settings.

### 3) Seed the database (Mini AdventureWorksDW)

```bash
./seed/seed_minidw.sh
```

### 4) Run the MCP server

```bash
cd server
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
python src/server.py
```

### 5) Connect an MCP client

- For Claude Desktop, see: `client/claude_desktop_config.json.example`
- Try prompts from: `client/examples/sample_prompts.md`

---

## Clean up

```bash
./infra/destroy.sh -g rg-mcp-awdw
```

---

## Notes about AdventureWorksDW data

This repo seeds a **mini AdventureWorksDW-style schema** that works reliably on Azure SQL Database.

If you want the **full** AdventureWorksDW dataset, see `seed/README.md` for options (e.g., import a `.bacpac`).

---

## License

MIT (recommended for starters). Add your preferred license file.
