$ErrorActionPreference = 'Stop'
$Vault = Split-Path -Parent $PSScriptRoot
$Port = 4173
$Uri = "http://127.0.0.1:$Port/Atlas.html"

try {
  $listener = [System.Net.Sockets.TcpClient]::new()
  $listener.Connect('127.0.0.1', $Port)
  $listener.Dispose()
} catch {
  $python = (Get-Command python -ErrorAction Stop).Source
  Start-Process -FilePath $python -ArgumentList @('-m', 'http.server', $Port, '--bind', '127.0.0.1') -WorkingDirectory $Vault -WindowStyle Hidden
  Start-Sleep -Milliseconds 700
}
Start-Process $Uri
