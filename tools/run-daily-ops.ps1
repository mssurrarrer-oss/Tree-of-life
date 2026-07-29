param(
    [string]$HubRoot = "",
    [switch]$ArchiveInbox,
    [switch]$GenerateBrief
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

$ingestScript = Join-Path $HubRoot "tools\run-memory-ingest.ps1"
$seedScript = Join-Path $HubRoot "tools\seed_task_generator.ps1"
$inboxStatusScript = Join-Path $HubRoot "tools\inbox-status.ps1"
$dailyBriefScript = Join-Path $HubRoot "tools\generate-daily-brief.ps1"

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
& $seedScript `
    -WorkflowTrackerPath (Join-Path $HubRoot "projects\workflow-tracker.json") `
    -IngestSummaryPath (Join-Path $HubRoot "knowledge\last-ingest-summary.json") `
    -OutputPath (Join-Path $HubRoot "knowledge\daily-seed-plan.json")

Write-Output "[3/3] Inbox status"
& $inboxStatusScript -HubRoot $HubRoot -Top 5

if ($GenerateBrief) {
    if (Test-Path $dailyBriefScript) {
        Write-Output "[4/4] Generating daily brief"
        & $dailyBriefScript `
            -HubRoot $HubRoot `
            -BriefFile (Join-Path $HubRoot "knowledge\daily-brief.md")
    } else {
        Write-Warning "Daily brief script not found: $dailyBriefScript"
    }

    Write-Output "[5/5] Daily ops ready"
} else {
    Write-Output "[4/4] Daily ops ready"
}
Write-Output "Next: open knowledge/daily-seed-plan.json and execute one stability + one exploration task."
