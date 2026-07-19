@echo off
echo Sutol AI Backend baslatiliyor...
echo.
echo Once Ollama'nin calistigindan emin olun!
echo (Ollama yuklu degilse https://ollama.com/download adresinden indirin)
echo.
echo Modeli indirmek icin: ollama pull llama3.2
echo.

pip install -r requirements.txt
if %ERRORLEVEL% neq 0 (
    echo pip install basarisiz.
    pause
    exit /b 1
)

uvicorn main:app --host 0.0.0.0 --port 8765 --reload
pause
