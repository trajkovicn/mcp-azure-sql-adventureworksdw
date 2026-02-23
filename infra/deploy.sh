#!/usr/bin/env bash
set -euo pipefail

# Deploy Azure SQL Server + Database using Bicep and Azure CLI
# Usage:
#   ./infra/deploy.sh -g <resourceGroup> -l <location> -n <uniqueSqlServerName> -u <adminLogin>
# The script will prompt for password securely.

usage() {
  echo "Usage: $0 -g <resourceGroup> -l <location> -n <uniqueSqlServerName> -u <adminLogin> [-s <skuName>] [--no-azure-services]"
}

RG=""; LOC=""; SQLNAME=""; ADMIN=""; SKU="S0"; ALLOW_AZURE_SERVICES=true

while [[ $# -gt 0 ]]; do
  case "$1" in
    -g) RG="$2"; shift 2;;
    -l) LOC="$2"; shift 2;;
    -n) SQLNAME="$2"; shift 2;;
    -u) ADMIN="$2"; shift 2;;
    -s) SKU="$2"; shift 2;;
    --no-azure-services) ALLOW_AZURE_SERVICES=false; shift 1;;
    -h|--help) usage; exit 0;;
    *) echo "Unknown arg: $1"; usage; exit 1;;
  esac
done

if [[ -z "$RG" || -z "$LOC" || -z "$SQLNAME" || -z "$ADMIN" ]]; then
  usage
  exit 1
fi

if ! command -v az >/dev/null 2>&1; then
  echo "Azure CLI (az) not found. Install from https://learn.microsoft.com/cli/azure/"
  exit 1
fi

# Create RG
az group create -n "$RG" -l "$LOC" 1>/dev/null

# Best-effort public IP detection (optional)
CLIENT_IP=""
if command -v curl >/dev/null 2>&1; then
  CLIENT_IP=$(curl -s https://api.ipify.org || true)
fi

read -s -p "Enter SQL admin password for '$ADMIN': " ADMIN_PWD
echo

echo "Deploying Azure SQL resources..."
az deployment group create \
  -g "$RG" \
  -f "$(dirname "$0")/main.bicep" \
  -p location="$LOC" \
     sqlServerName="$SQLNAME" \
     adminLogin="$ADMIN" \
     adminPassword="$ADMIN_PWD" \
     databaseName="AdventureWorksDW" \
     skuName="$SKU" \
     allowAzureServices="$ALLOW_AZURE_SERVICES" \
     clientIp="$CLIENT_IP" \
  1>/dev/null

FQDN=$(az deployment group show -g "$RG" -n main --query properties.outputs.sqlServerFqdn.value -o tsv 2>/dev/null || true)
if [[ -z "$FQDN" ]]; then
  # If deployment name isn't 'main' (Azure CLI auto-names sometimes), fetch last deployment
  DEP=$(az deployment group list -g "$RG" --query "[0].name" -o tsv)
  FQDN=$(az deployment group show -g "$RG" -n "$DEP" --query properties.outputs.sqlServerFqdn.value -o tsv)
fi

echo "\nDeployment complete."
echo "SQL Server: $FQDN"
echo "Database: AdventureWorksDW"

# Write local .env for server
ENV_FILE="$(dirname "$0")/../server/.env"
cat > "$ENV_FILE" <<EOF
SQL_SERVER=$FQDN
SQL_DATABASE=AdventureWorksDW
SQL_USER=$ADMIN
SQL_PASSWORD=$ADMIN_PWD
EOF

echo "Wrote connection settings to $ENV_FILE"

echo "Next: run seed scripts: ./seed/seed_minidw.sh"
