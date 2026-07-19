param(
    [switch]$NoFlutter,
    [switch]$Help
)

if ($Help) {
    Write-Host @"
Sutol AI Launcher - Tum servisleri baslatir.

Kullanim:
  .\start.ps1          -> Ollama + Backend + Flutter
  .\start.ps1 -NoFlutter -> Sadece Ollama + Backend

Kisayol: .\s.ps1
"@
    exit 0
}

$ollamaExe = "$env:LOCALAPPDATA\Programs\Ollama\ollama.exe"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$backendDir = Join-Path $scriptDir "backend"
$projectDir = $scriptDir

function Write-Status($icon, $text) {
    $t = Get-Date -Format "HH:mm:ss"
    Write-Host "[$t] $icon $text" -ForegroundColor Cyan
}

function Wait-Port($port, $timeoutSeconds = 30) {
    $end = (Get-Date).AddSeconds($timeoutSeconds)
    while ((Get-Date) -lt $end) {
        try {
            $tcp = New-Object System.Net.Sockets.TcpClient
            $tcp.Connect("127.0.0.1", $port)
            $tcp.Close()
            return $true
        } catch {
            Start-Sleep -Milliseconds 500
        }
    }
    return $false
}

# === 1. OLLAMA ===
Write-Status "==>" "1/3: Ollama kontrol ediliyor..."

$ollamaRunning = $false
try {
    $null = Invoke-RestMethod -Uri "http://localhost:11434/api/tags" -TimeoutSec 3
    $ollamaRunning = $true
    Write-Status " OK" "Ollama zaten calisiyor"
} catch {
    Write-Status "~~>" "Ollama baslatiliyor..."
    $ollamaProcess = Start-Process -FilePath $ollamaExe -ArgumentList "serve" -WindowStyle Hidden -PassThru
    Write-Status "~~>" "Ollama hazir olmasi bekleniyor..."
    if (Wait-Port -port 11434 -timeoutSeconds 60) {
        Write-Status " OK" "Ollama hazir (PID: $($ollamaProcess.Id))"
        $ollamaRunning = $true
    } else {
        Write-Status "FAIL" "Ollama baslatilamadi! Elle: $ollamaExe serve"
        exit 1
    }
}

# Model kontrol
try {
    $modelList = (Invoke-RestMethod -Uri "http://localhost:11434/api/tags" -TimeoutSec 5).models
    $hasModel = $false
    foreach ($m in $modelList) {
        if ($m.name -like "llama3.2*") { $hasModel = $true; break }
    }
    if (-not $hasModel) {
        Write-Status "~~>" "Model 'llama3.2' indiriliyor (~2GB, ilk seferde)..."
        & $ollamaExe pull llama3.2
    }
} catch {
    Write-Status " OK" "Model kontrol edilemedi, devam ediliyor..."
}
Write-Status " OK" "Model 'llama3.2' hazir"

# === 2. PYTHON BACKEND ===
Write-Status "==>" "2/3: Python backend kontrol ediliyor..."

$backendRunning = $false
try {
    $null = Invoke-RestMethod -Uri "http://localhost:8765/health" -TimeoutSec 2
    $backendRunning = $true
    Write-Status " OK" "Backend zaten calisiyor"
} catch {
    Write-Status "~~>" "Backend baslatiliyor..."
    pip install -r "$backendDir\requirements.txt" -q 2>$null
    $backendProcess = Start-Process -FilePath "python" -ArgumentList "-m uvicorn main:app --host 0.0.0.0 --port 8765" -WorkingDirectory $backendDir -WindowStyle Hidden -PassThru
    Write-Status "~~>" "Backend hazir olmasi bekleniyor..."
    if (Wait-Port -port 8765 -timeoutSeconds 30) {
        Write-Status " OK" "Backend hazir (PID: $($backendProcess.Id))"
        $backendRunning = $true
    } else {
        Write-Status "FAIL" "Backend baslatilamadi! Elle: cd backend; uvicorn main:app --port 8765"
        exit 1
    }
}

# === 3. SON DURUM ===
Write-Status "==>" "Servisler hazir!"
Write-Status "   " "  Ollama  : http://localhost:11434"
Write-Status "   " "  Backend : http://localhost:8765"

if (-not $NoFlutter) {
    Write-Status "==>" "3/3: Flutter baslatiliyor..."
    Write-Status "   " "  Cikis: Ctrl+C"
    Write-Host ""
    Set-Location $projectDir
    flutter run -d chrome
} else {
    Write-Status "   " "  Flutter: flutter run -d chrome"
}
