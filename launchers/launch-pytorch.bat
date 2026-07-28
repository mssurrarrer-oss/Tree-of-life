@echo off
start "" cmd /k "python -m pip show torch && python -c \"import torch; print(torch.__version__)\""
