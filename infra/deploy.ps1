Param(
  [Parameter(Mandatory=$true)][string]$ResourceGroup,
  [Parameter(Mandatory=$true)][string]$Location,
  [Parameter(Mandatory=$true)][string]$SqlServerName,
  [Parameter(Mandatory=$true)][string]$AdminLogin,
  [string]$SkuName = "S0",
  [switch]$NoAzureServices
)

$ErrorActionPreference = "Stop"

if (-not (Get-Command az -ErrorAction SilentlyContinue)) {
  throw "Azure CLI (az) not found. Install from https://learn.microsoft.com/cli/azure/"
}

az group create -n $ResourceGroup -l $Location | Out-Null

# Best-effort public IP detection
$clientIp = ""
try {
  $clientIp = (Invoke-RestMethod -Uri "https://api.ipify.org").ToString()
} catch { }

$adminPwd = Read-Host -AsSecureString "Enter SQL admin password for '$AdminLogin'"
$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($adminPwd)
$plainPwd = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

$allowAzureServices = $true
if ($NoAzureServices) { $allowAzureServices = $false }

Write-Host "Deploying Azure SQL resources..."
az deployment group create `
  -g $ResourceGroup `
  -f (Join-Path $PSScriptRoot "main.bicep") `
  -p location=$Location sqlServerName=$SqlServerName adminLogin=$AdminLogin adminPassword=$plainPwd databaseName=AdventureWorksDW skuName=$SkuName allowAzureServices=$allowAzureServices clientIp=$clientIp | Out-Null

# Try to read output
$deployName = (az deployment group list -g $ResourceGroup --query "[0].name" -o tsv)
$fqdn = (az deployment group show -g $ResourceGroup -n $deployName --query "properties.outputs.sqlServerFqdn.value" -o tsv)

Write-Host "Deployment complete. SQL Server: $fqdn"

$envPath = Join-Path $PSScriptRoot "..\server\.env"
@"
SQL_SERVER=$fqdn
SQL_DATABASE=AdventureWorksDW
SQL_USER=$AdminLogin
SQL_PASSWORD=$plainPwd
"@ | Set-Content -Path $envPath -Encoding UTF8

Write-Host "Wrote connection settings to $envPath"
Write-Host "Next: run seed scripts: .\seed\seed_minidw.ps1"
