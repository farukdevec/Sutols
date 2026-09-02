$ErrorActionPreference = 'Stop'
$Vault = Split-Path -Parent $PSScriptRoot
$Desktop = [Environment]::GetFolderPath('Desktop')
$ShortcutPath = Join-Path $Desktop 'Atlas.lnk'
$Executable = Join-Path $Vault 'app\desktop\publish\Atlas.exe'
$Pythonw = (Get-Command pythonw -ErrorAction SilentlyContinue).Source

$Shell = New-Object -ComObject WScript.Shell
$Shortcut = $Shell.CreateShortcut($ShortcutPath)
$Shortcut.TargetPath = if (Test-Path -LiteralPath $Executable) { $Executable } elseif ($Pythonw) { $Pythonw } else { (Get-Command python -ErrorAction Stop).Source }
$Shortcut.Arguments = if (Test-Path -LiteralPath $Executable) { '' } else { '"' + (Join-Path $Vault 'app\atlas_app.pyw') + '"' }
$Shortcut.WorkingDirectory = $Vault
$Shortcut.IconLocation = "$env:SystemRoot\System32\shell32.dll,137"
$Shortcut.Description = 'Atlas — EmreOS ikinci beyin uygulaması'
$Shortcut.Save()
Write-Output ('Kısayol oluşturuldu: ' + $ShortcutPath)
