Param()

$ErrorActionPreference = "Stop"

$root = (Resolve-Path (Join-Path $PSScriptRoot ".."))

python -m venv (Join-Path $root ".venv") | Out-Null

$activate = Join-Path $root ".venv\Scripts\Activate.ps1"
. $activate

pip install -r (Join-Path $root "server\requirements.txt") | Out-Null
python (Join-Path $root "seed\seed_minidw.py")
