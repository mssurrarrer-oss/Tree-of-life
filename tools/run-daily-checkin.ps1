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

$dailyOpsScript = Join-Path $HubRoot "tools\run-daily-ops.ps1"
$triageScript = Join-Path $HubRoot "tools\triage-inbox.ps1"
$importScript = Join-Path $HubRoot "tools\process-conversation-imports.ps1"
$spendSummaryScript = Join-Path $HubRoot "tools\cloud-spend-summary.ps1"
$careSimScript = Join-Path $HubRoot "tools\run-care-alert-simulation.ps1"
$briefPath = Join-Path $HubRoot "knowledge\daily-brief.md"
$seedPlanPath = Join-Path $HubRoot "knowledge\daily-seed-plan.json"
$checkinDir = Join-Path $HubRoot "knowledge\checkins"
$dateTag = (Get-Date).ToString("yyyy-MM-dd")
$briefSnapshotPath = Join-Path $checkinDir "$dateTag-brief.md"
$triageSnapshotPath = Join-Path $checkinDir "$dateTag-inbox-triage.md"
$importLogPath = Join-Path $checkinDir "$dateTag-imports.log"
$spendSummaryPath = Join-Path $checkinDir "$dateTag-cloud-spend.md"
$careSimPath = Join-Path $checkinDir "$dateTag-care-alert-simulation.md"
$notesPath = Join-Path $checkinDir "$dateTag-notes.md"

if (-not (Test-Path $dailyOpsScript)) {
    throw "Missing daily ops script: $dailyOpsScript"
}

New-Item -ItemType Directory -Path $checkinDir -Force | Out-Null

$importPathForNotes = "Skipped"
if (-not $SkipImport) {
    if (Test-Path $importScript) {
        Write-Output "[1/6] Processing conversation import drop"
        (& $importScript -HubRoot $HubRoot *>&1) | Tee-Object -FilePath $importLogPath | Out-Null
        $importPathForNotes = $importLogPath
    } else {
        Write-Warning "Import script not found: $importScript"
    }
}

Write-Output "[2/6] Running daily operations and generating brief"
if ($ArchiveInbox) {
    & $dailyOpsScript -HubRoot $HubRoot -ArchiveInbox -GenerateBrief
} else {
    & $dailyOpsScript -HubRoot $HubRoot -GenerateBrief
}

if (-not (Test-Path $briefPath)) {
    throw "Expected brief file not found: $briefPath"
}

Copy-Item -Path $briefPath -Destination $briefSnapshotPath -Force

$triagePathForNotes = "Skipped"
if (-not $SkipTriage) {
    if (Test-Path $triageScript) {
        Write-Output "[3/6] Building inbox triage queue"
        & $triageScript -HubRoot $HubRoot -OutputPath $triageSnapshotPath -Top 20
        if (Test-Path $triageSnapshotPath) {
            $triagePathForNotes = $triageSnapshotPath
        }
    } else {
        Write-Warning "Triage script not found: $triageScript"
    }
}

$spendSummaryForNotes = "Skipped"
if (-not $SkipSpendSummary) {
    if (Test-Path $spendSummaryScript) {
        Write-Output "[4/6] Building cloud spend summary"
        & $spendSummaryScript -HubRoot $HubRoot -StartDate $dateTag -EndDate $dateTag -OutputPath $spendSummaryPath
        if (Test-Path $spendSummaryPath) {
            $spendSummaryForNotes = $spendSummaryPath
        }
    } else {
        Write-Warning "Cloud spend summary script not found: $spendSummaryScript"
    }
}

$careSimForNotes = "Skipped"
if ($RunCareSimulation) {
    if (Test-Path $careSimScript) {
        Write-Output "[5/6] Running care alert simulation"
        & $careSimScript -HubRoot $HubRoot -OutputPath $careSimPath
        if (Test-Path $careSimPath) {
            $careSimForNotes = $careSimPath
        }
    } else {
        Write-Warning "Care simulation script not found: $careSimScript"
    }
}

$seedTaskSummary = "Unavailable"
if (Test-Path $seedPlanPath) {
    $seedPlan = Get-Content -Path $seedPlanPath -Raw | ConvertFrom-Json
    $stabilityTask = $seedPlan.tasks | Where-Object { $_.type -eq "stability" } | Select-Object -First 1
    $explorationTask = $seedPlan.tasks | Where-Object { $_.type -eq "exploration" } | Select-Object -First 1

    $stabilityCategory = if ($stabilityTask) { [string]$stabilityTask.category } else { "none" }
    $explorationCategory = if ($explorationTask) { [string]$explorationTask.category } else { "none" }

    $seedTaskSummary = "Stability=$stabilityCategory; Exploration=$explorationCategory"
}

if (-not (Test-Path $notesPath)) {
    $notesTemplate = @"
# Daily Check-In Notes ($dateTag)

## Inputs
- Conversation Import Log: $importPathForNotes
- Brief Snapshot: $briefSnapshotPath
- Inbox Triage: $triagePathForNotes
- Cloud Spend Summary: $spendSummaryForNotes
- Care Alert Simulation: $careSimForNotes
- Seed Tasks: $seedTaskSummary

## Current state
- 

## Risks or blockers
- 

## Decisions today
- 

## Next action
- 
"@

    Set-Content -Path $notesPath -Value $notesTemplate -Encoding UTF8
}

$artifactStamp = @(
    ""
    "## Automation Artifacts ($((Get-Date).ToString('yyyy-MM-dd HH:mm:ss')))"
    "- Conversation Import Log: $importPathForNotes"
    "- Brief Snapshot: $briefSnapshotPath"
    "- Inbox Triage: $triagePathForNotes"
    "- Cloud Spend Summary: $spendSummaryForNotes"
    "- Care Alert Simulation: $careSimForNotes"
    "- Seed Tasks: $seedTaskSummary"
)
Add-Content -Path $notesPath -Value ($artifactStamp -join [Environment]::NewLine) -Encoding UTF8

Write-Output "[6/6] Brief snapshot saved to $briefSnapshotPath"
Write-Output "[done] Check-in notes template ready at $notesPath"
Write-Output "[done] Daily check-in workflow complete"
