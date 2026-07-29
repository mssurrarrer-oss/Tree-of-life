param(
    [string]$HubRoot = "",
    [switch]$ArchiveInbox,
    [switch]$SkipTriage,
    [switch]$SkipImport,
    [switch]$SkipSpendSummary,
    [switch]$RunCareSimulation
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
if ([string]::IsNullOrWhiteSpace($HubRoot)) {
    $HubRoot = (Resolve-Path (Join-Path $scriptDir "..")).ProviderPath
} elseif (-not (Test-Path $HubRoot)) {
    throw "Hub root not found: $HubRoot"
} else {
    $HubRoot = (Resolve-Path $HubRoot).ProviderPath
}

$checkinScript = Join-Path $HubRoot "tools\run-daily-checkin.ps1"
if (-not (Test-Path $checkinScript)) {
    throw "Missing daily check-in script: $checkinScript"
}

$logDir = Join-Path $HubRoot "knowledge\checkins"
New-Item -Path $logDir -ItemType Directory -Force | Out-Null

$timeStamp = Get-Date -Format "yyyyMMdd-HHmmss"
$runLog = Join-Path $logDir "scheduler-run-$timeStamp.log"
$latestLog = Join-Path $logDir "scheduler-last-run.log"

try {
    "[$((Get-Date).ToString('s'))] Starting scheduled daily check-in" | Set-Content -Path $runLog -Encoding UTF8

    $invokeParams = @{ HubRoot = $HubRoot }
    if ($ArchiveInbox) { $invokeParams["ArchiveInbox"] = $true }
    if ($SkipTriage) { $invokeParams["SkipTriage"] = $true }
    if ($SkipImport) { $invokeParams["SkipImport"] = $true }
    if ($SkipSpendSummary) { $invokeParams["SkipSpendSummary"] = $true }
    if ($RunCareSimulation) { $invokeParams["RunCareSimulation"] = $true }

    & $checkinScript @invokeParams *>&1 | Tee-Object -FilePath $runLog -Append | Out-Null

    if ($LASTEXITCODE -and $LASTEXITCODE -ne 0) {
        throw "Daily check-in returned non-zero exit code: $LASTEXITCODE"
    }

    "[$((Get-Date).ToString('s'))] Scheduled daily check-in completed successfully" | Add-Content -Path $runLog -Encoding UTF8
    Copy-Item -Path $runLog -Destination $latestLog -Force
    exit 0
}
catch {
    "[$((Get-Date).ToString('s'))] Scheduled daily check-in failed" | Add-Content -Path $runLog -Encoding UTF8
    ($_ | Out-String) | Add-Content -Path $runLog -Encoding UTF8
    Copy-Item -Path $runLog -Destination $latestLog -Force
    exit 1
}
