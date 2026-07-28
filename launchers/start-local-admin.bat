@echo off
echo =======================================================
echo Preparing Local Admin AI on Mini PC (Core Ultra 9)
echo =======================================================

echo [1] Ensuring Ollama Backend is running with Vulkan...
start /b cmd /c "launchers\launch-ollama.bat"
timeout /t 3 /nobreak > nul

echo [2] Launching Python Local Admin Router...
cd services\automation-framework
python local-admin-router.py

pause
