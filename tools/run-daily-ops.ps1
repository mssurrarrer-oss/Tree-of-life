param(
    [string]$HubRoot = "d:\ai-hub",
    [switch]$ArchiveInbox
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$ingestScript = Join-Path $HubRoot "tools\run-memory-ingest.ps1"
$seedScript = Join-Path $HubRoot "tools\seed_task_generator.ps1"
$inboxStatusScript = Join-Path $HubRoot "tools\inbox-status.ps1"

if (-not (Test-Path $ingestScript)) {
    throw "Missing ingest script: $ingestScript"
}

if (-not (Test-Path $seedScript)) {
    throw "Missing seed generator: $seedScript"
}

if (-not (Test-Path $inboxStatusScript)) {
    throw "Missing inbox status script: $inboxStatusScript"
}

Write-Output "[1/3] Running memory ingest"
if ($ArchiveInbox) {
    & $ingestScript -ArchiveInbox
} else {
    & $ingestScript
}

Write-Output "[2/3] Generating daily seed plan"
& $seedScript

Write-Output "[3/3] Inbox status"
& $inboxStatusScript -HubRoot $HubRoot -Top 5

Write-Output "[4/4] Daily ops ready"
Write-Output "Next: open knowledge/daily-seed-plan.json and execute one stability + one exploration task."
