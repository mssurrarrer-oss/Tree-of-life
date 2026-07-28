@echo off
py "%~dp0memory_ingest.py"
if errorlevel 1 (
  echo.
  echo Memory ingest failed. Ensure Python launcher (py.exe) is installed.
)
pause
