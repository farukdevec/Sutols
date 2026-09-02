$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot
python -m PyInstaller --noconfirm --clean --windowed --name Atlas atlas_app.pyw
