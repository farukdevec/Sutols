Write-Host "=== Sutol AI Backend Baslatiliyor ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Once Ollama'nin calistigindan emin olun!" -ForegroundColor Yellow
Write-Host "- Ollama'yi https://ollama.com/download adresinden indirin" -ForegroundColor Yellow
Write-Host "- Calistirmak icin: ollama serve" -ForegroundColor Yellow
Write-Host "- Model indirmek icin: ollama pull llama3.2" -ForegroundColor Yellow
Write-Host ""

# Install dependencies
Write-Host "Python bagimliliklari yukleniyor..." -ForegroundColor Green
pip install -r requirements.txt
if ($LASTEXITCODE -ne 0) {
    Write-Host "pip install basarisiz!" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Backend baslatiliyor: http://localhost:8765" -ForegroundColor Green
Write-Host ""
uvicorn main:app --host 0.0.0.0 --port 8765 --reload

pause
