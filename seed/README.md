# Seeding options

This repo ships a *Mini AdventureWorksDW* seed that works out-of-the-box on Azure SQL Database.

## Why a "mini" seed?

The full AdventureWorksDW scripts published for SQL Server often rely on loading data files from the local filesystem.
Azure SQL Database doesn't have access to your local disk, so a direct "run this on the server" install script usually won't work unchanged.

## If you want the full AdventureWorksDW

You have a few options:

1. **Import a `.bacpac`** into Azure SQL Database.
   - Restore the `.bak` to a local SQL Server instance.
   - Export a data-tier application (`.bacpac`).
   - Upload the `.bacpac` to Azure Storage.
   - Import it into Azure SQL Database.

2. **Adapt the DW install scripts** to load CSVs from Azure Blob Storage using `BULK INSERT`/`OPENROWSET` patterns.

We include the mini seed to keep this repo lightweight and repeatable.
