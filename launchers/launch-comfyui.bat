@echo off
setlocal

set "COMFY_EXE="

if exist "C:\Program Files\ComfyUI\ComfyUI.exe" set "COMFY_EXE=C:\Program Files\ComfyUI\ComfyUI.exe"
if not defined COMFY_EXE if exist "C:\Users\micha\AppData\Local\Programs\ComfyUI\ComfyUI.exe" set "COMFY_EXE=C:\Users\micha\AppData\Local\Programs\ComfyUI\ComfyUI.exe"
if not defined COMFY_EXE if exist "C:\Users\micha\AppData\Local\ComfyUI\ComfyUI.exe" set "COMFY_EXE=C:\Users\micha\AppData\Local\ComfyUI\ComfyUI.exe"

if not defined COMFY_EXE (
	for /f "delims=" %%I in ('where comfyui 2^>nul') do (
		set "COMFY_EXE=%%I"
		goto :found
	)
)

:found
if defined COMFY_EXE (
	start "" "%COMFY_EXE%"
) else (
	echo ComfyUI executable was not found yet. Finish installation, then update launchers\launch-comfyui.bat if needed.
)

endlocal
