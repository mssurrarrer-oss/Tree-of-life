@echo off
setlocal
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\launch-ai-hub.ps1"
exit /b %ERRORLEVEL%
