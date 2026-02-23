Param(
  [Parameter(Mandatory=$true)][string]$ResourceGroup
)

$ErrorActionPreference = "Stop"

az group delete -n $ResourceGroup --yes --no-wait | Out-Null
Write-Host "Delete started for resource group: $ResourceGroup"
