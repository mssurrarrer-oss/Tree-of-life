param(
	[switch]$NoBrowser
)

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

if ($config.vscode_executable) {
	Start-Process -FilePath $config.vscode_executable -ArgumentList $repoRoot
}

if ($config.lmstudio_executable) {
	Start-Process -FilePath $config.lmstudio_executable
}

$agentScript = Join-Path $repoRoot "agent\run-agent.ps1"
if (Test-Path $agentScript) {
	Start-Process -FilePath "powershell" -ArgumentList @("-NoProfile", "-ExecutionPolicy", "Bypass", "-File", $agentScript)
}

$indexPath = Join-Path $repoRoot "index.html"
if (-not $NoBrowser -and (Test-Path $indexPath)) {
	Start-Process -FilePath $indexPath
}

Write-Host "AI-Hub launch sequence started."
