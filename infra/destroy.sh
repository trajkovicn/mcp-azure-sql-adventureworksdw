#!/usr/bin/env bash
set -euo pipefail

# Destroy all resources by deleting the resource group
# Usage:
#   ./infra/destroy.sh -g <resourceGroup>

usage() { echo "Usage: $0 -g <resourceGroup>"; }

RG=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    -g) RG="$2"; shift 2;;
    -h|--help) usage; exit 0;;
    *) echo "Unknown arg: $1"; usage; exit 1;;
  esac
done

if [[ -z "$RG" ]]; then
  usage
  exit 1
fi

az group delete -n "$RG" --yes --no-wait

echo "Delete started for resource group: $RG"
