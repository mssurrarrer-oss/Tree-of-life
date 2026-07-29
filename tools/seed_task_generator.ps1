param(
    [string]$WorkflowTrackerPath = "",
    [string]$IngestSummaryPath = "",
    [string]$Salt = "",
    [string]$OutputPath = ""
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = (Resolve-Path (Join-Path $scriptDir "..")).Path

if ([string]::IsNullOrWhiteSpace($WorkflowTrackerPath)) {
    $WorkflowTrackerPath = Join-Path $repoRoot "projects\workflow-tracker.json"
}

if ([string]::IsNullOrWhiteSpace($IngestSummaryPath)) {
    $IngestSummaryPath = Join-Path $repoRoot "knowledge\last-ingest-summary.json"
}

if ([string]::IsNullOrWhiteSpace($OutputPath)) {
    $OutputPath = Join-Path $repoRoot "knowledge\daily-seed-plan.json"
}

if (-not (Test-Path $WorkflowTrackerPath)) {
    throw "Missing workflow tracker: $WorkflowTrackerPath"
}

function Get-TopPriorityProjectName {
    param([object]$Tracker)

    if (-not $Tracker.projects) {
        return "none"
    }

    $rank = @{ critical = 0; high = 1; medium = 2; low = 3 }
    $top = $Tracker.projects |
        Sort-Object { if ($rank.ContainsKey($_.priority)) { $rank[$_.priority] } else { 99 } } |
        Select-Object -First 1

    if ($null -eq $top) {
        return "none"
    }

    return [string]$top.name
}

$tracker = Get-Content -Path $WorkflowTrackerPath -Raw | ConvertFrom-Json
$ingest = $null
if (Test-Path $IngestSummaryPath) {
    $ingest = Get-Content -Path $IngestSummaryPath -Raw | ConvertFrom-Json
} else {
    Write-Warning "Ingest summary not found at $IngestSummaryPath; using 0 for document count."
}

$date = (Get-Date).ToString("yyyy-MM-dd")
$topPriority = Get-TopPriorityProjectName -Tracker $tracker
$docCount = 0
if ($ingest -and $ingest.PSObject.Properties.Name -contains "documentsProcessed") {
    $docCount = [int]$ingest.documentsProcessed
} elseif ($ingest -and $ingest.PSObject.Properties.Name -contains "documentsIndexed") {
    $docCount = [int]$ingest.documentsIndexed
} elseif ($ingest -and $ingest.PSObject.Properties.Name -contains "documentsSeen") {
    $docCount = [int]$ingest.documentsSeen
}

$seedInput = "$date|$topPriority|$docCount|$Salt"
$sha = [System.Security.Cryptography.SHA256]::Create()
$bytes = [System.Text.Encoding]::UTF8.GetBytes($seedInput)
$hashBytes = $sha.ComputeHash($bytes)
$seed = [BitConverter]::ToString($hashBytes).Replace("-", "").ToLowerInvariant()

$stabilityCategories = @("validation", "cleanup", "test-hardening", "documentation", "memory-hygiene")
$explorationCategories = @("prompt-experiment", "routing-experiment", "retrieval-experiment", "automation-experiment", "ux-experiment")

$stabilityIndex = [Convert]::ToInt32($seed.Substring(0, 2), 16) % $stabilityCategories.Count
$explorationIndex = [Convert]::ToInt32($seed.Substring(2, 2), 16) % $explorationCategories.Count

$plan = [ordered]@{
    generatedAt = (Get-Date).ToString("s")
    seedInput = $seedInput
    seed = $seed
    topPriorityProject = $topPriority
    ingestDocumentsProcessed = $docCount
    tasks = @(
        [ordered]@{
            type = "stability"
            category = $stabilityCategories[$stabilityIndex]
            objective = "Deliver one reliability improvement in under 30 minutes."
        },
        [ordered]@{
            type = "exploration"
            category = $explorationCategories[$explorationIndex]
            objective = "Run one measurable experiment and record outcome."
        }
    )
}

$outputDir = Split-Path -Parent $OutputPath
if (-not [string]::IsNullOrWhiteSpace($outputDir)) {
    New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
}

$plan | ConvertTo-Json -Depth 5 | Set-Content -Path $OutputPath -Encoding UTF8
Write-Output "Daily seed plan written to $OutputPath"
