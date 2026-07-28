@echo off
setlocal

set "OLLAMA_EXE="

if exist "C:\Users\micha\AppData\Local\AMD\AI_Bundle\Ollama\ollama.exe" set "OLLAMA_EXE=C:\Users\micha\AppData\Local\AMD\AI_Bundle\Ollama\ollama.exe"
if not defined OLLAMA_EXE if exist "C:\Program Files\Ollama\ollama.exe" set "OLLAMA_EXE=C:\Program Files\Ollama\ollama.exe"

if not defined OLLAMA_EXE (
	for /f "delims=" %%I in ('where ollama 2^>nul') do (
		set "OLLAMA_EXE=%%I"
		goto :found
	)
)

:found
if defined OLLAMA_EXE (
	echo Configuring Ollama for Mini PC (Arc GPU/Vulkan) & Network Access...
	set OLLAMA_HOST=0.0.0.0
	set OLLAMA_ORIGINS="*"
	set OLLAMA_INTEL_GPU=1
	set GGML_VULKAN=1
	set SYCL_ENABLE_PCI=1 
	start "" "%OLLAMA_EXE%" serve
) else (
	echo Ollama executable was not found. Update launchers\launch-ollama.bat with your install path.
)

endlocal
