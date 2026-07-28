# PC Setup Documentation

This repo now includes a repeatable Windows bootstrap flow that makes this PC operational without hand-editing install paths.

## What the bootstrap does
- Detects VS Code, LM Studio, Python, and Git in common install locations
- Writes a machine-local `config.local.json` so the repo can run consistently on this PC
- Creates the `knowledge/inbox` directory structure expected by the ingest tools
- Enables a one-click launch path for the local AI hub

## Fast start
1. Open PowerShell in the repo root.
2. Run:
   `powershell -ExecutionPolicy Bypass -File .\tools\bootstrap-ai-hub.ps1`
3. If you want to set Git identity for this machine, add values to `config.local.json` before running the bootstrap again:
   - `git_user_name`
   - `git_user_email`
4. Launch the hub with:
   `powershell -ExecutionPolicy Bypass -File .\tools\launch-ai-hub.ps1`

## Optional manual launch paths
- `launch-ai-hub.bat`
- `launchers\launch-lmstudio.bat`
- `tools\run-daily-ops.ps1`

## Recommended operating loop
1. Run the daily ops script after you add or change notes.
2. Open the repo in VS Code and use the launched LM Studio session for local models.
3. Keep `config.local.json` as the source of truth for machine-specific paths and identity.

## Why this matters
This becomes your operational reference for troubleshooting, upgrades, reproducibility, and long-term continuity.
