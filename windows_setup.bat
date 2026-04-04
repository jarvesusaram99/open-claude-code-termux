@echo off
setlocal enabledelayedexpansion

echo =================================================
echo   [>>] OpenClaude Windows Auto-Installer
echo =================================================
echo.
echo   Let's get your settings first!
echo =================================================
echo.

set /p API_KEY="Enter your OpenRouter API Key (sk-or-...): "

echo.
echo Fetching live list of FREE OpenRouter models...

:: Fetch models using PowerShell native JSON parsing
powershell -NoProfile -Command "$response = Invoke-RestMethod -Uri 'https://openrouter.ai/api/v1/models'; $freeModels = $response.data | Where-Object { $_.id -like '*:free' }; $i = 1; foreach ($model in $freeModels) { Write-Host ($i.ToString() + ') ' + $model.id); $i++ }; Write-Host ($i.ToString() + ') Custom (Type your own)')" > "%TEMP%\models.txt"

echo.
type "%TEMP%\models.txt"
echo.

set /p MODEL_CHOICE="Choose a number (Default: 1): "
if "%MODEL_CHOICE%"=="" set MODEL_CHOICE=1

:: Extract the chosen model string from the file
for /f "tokens=1,* delims=) " %%A in ('type "%TEMP%\models.txt" ^| findstr /b "%MODEL_CHOICE%)"') do (
    set MODEL_NAME=%%B
)

if "!MODEL_NAME!"=="Custom (Type your own)" (
    set /p MODEL_NAME="Enter custom model name: "
)

if "!MODEL_NAME!"=="" set MODEL_NAME=qwen/qwen3.6-plus:free

echo.
echo [OK] You have selected: !MODEL_NAME!
echo.
pause

echo.
echo =================================================
echo   [>>] Installing OpenClaude...
echo =================================================
echo.

call npm init -y
call npm install @gitlawb/openclaude

echo.
echo [3/3] Generating start.bat launcher script...

(
echo @echo off
echo set CLAUDE_CODE_USE_OPENAI=1
echo set OPENAI_API_KEY=%API_KEY%
echo set OPENAI_BASE_URL=https://openrouter.ai/api/v1
echo set OPENAI_MODEL=!MODEL_NAME!
echo set ANTHROPIC_API_KEY=
echo echo Booting OpenClaude with !MODEL_NAME!...
echo npx openclaude %%*
) > start.bat

echo.
echo =================================================
echo   [DONE] Setup Complete!
echo.
echo   To run your AI assistant anytime, just double
echo   click 'start.bat' or type: .\start.bat
echo =================================================
echo.
pause
