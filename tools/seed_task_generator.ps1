param(
    [string]$WorkflowTrackerPath = "d:\ai-hub\projects\workflow-tracker.json",
    [string]$IngestSummaryPath = "d:\ai-hub\knowledge\last-ingest-summary.json",
    [string]$Salt = "",
    [string]$OutputPath = "d:\ai-hub\knowledge\daily-seed-plan.json"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

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
$ingest = Get-Content -Path $IngestSummaryPath -Raw | ConvertFrom-Json

$date = (Get-Date).ToString("yyyy-MM-dd")
$topPriority = Get-TopPriorityProjectName -Tracker $tracker
$docCount = 0
if ($ingest.PSObject.Properties.Name -contains "documentsProcessed") {
    $docCount = [int]$ingest.documentsProcessed
} elseif ($ingest.PSObject.Properties.Name -contains "documentsIndexed") {
    $docCount = [int]$ingest.documentsIndexed
} elseif ($ingest.PSObject.Properties.Name -contains "documentsSeen") {
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

$plan | ConvertTo-Json -Depth 5 | Set-Content -Path $OutputPath -Encoding UTF8
Write-Output "Daily seed plan written to $OutputPath"
