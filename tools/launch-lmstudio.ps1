Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = (Resolve-Path (Join-Path $scriptDir "..")).Path
$bootstrapScript = Join-Path $scriptDir "bootstrap-ai-hub.ps1"
$configPath = Join-Path $repoRoot "config.local.json"

if (Test-Path $bootstrapScript) {
	& $bootstrapScript -Quiet
}

if (-not (Test-Path $configPath)) {
	throw "Bootstrap did not produce config.local.json at $configPath"
}

$config = Get-Content $configPath -Raw | ConvertFrom-Json
if (-not $config.lmstudio_executable) {
	throw "LM Studio executable could not be discovered. Update config.local.json or install LM Studio."
}

Start-Process -FilePath $config.lmstudio_executable
Write-Host "LM Studio launch requested."
