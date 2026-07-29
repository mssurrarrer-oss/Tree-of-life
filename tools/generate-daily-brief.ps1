param(
    [string]$HubRoot = "",
    [string]$BriefFile = ""
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

$configPath = Join-Path $HubRoot "config.local.json"
$knowledgeRootRel = "knowledge"
$inboxRel = "knowledge\inbox"
if (Test-Path $configPath) {
    $config = Get-Content $configPath -Raw | ConvertFrom-Json
    if ($config.knowledge_root) {
        $knowledgeRootRel = [string]$config.knowledge_root
    }
    if ($config.knowledge_inbox) {
        $inboxRel = [string]$config.knowledge_inbox
    }
}

if ([string]::IsNullOrWhiteSpace($BriefFile)) {
    $BriefFile = Join-Path $HubRoot (Join-Path $knowledgeRootRel "daily-brief.md")
}

$briefDir = Split-Path -Parent $BriefFile
if (-not [string]::IsNullOrWhiteSpace($briefDir)) {
    New-Item -ItemType Directory -Path $briefDir -Force | Out-Null
}

$now = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$today = Get-Date -Format "yyyy-MM-dd"

# Check knowledge inbox status
$inboxPath = Join-Path $HubRoot $inboxRel
$inboxFiles = @()
if (Test-Path $inboxPath) {
    $inboxFiles = Get-ChildItem -Path $inboxPath -File -Recurse | Select-Object -First 10
}

# Check cluster state file
$agentStatePath = Join-Path $HubRoot "agent\state.json"
$agentState = $null
if (Test-Path $agentStatePath) {
    $agentState = Get-Content $agentStatePath -Raw | ConvertFrom-Json
}

# Check daily seed plan
$seedPlanPath = Join-Path $HubRoot (Join-Path $knowledgeRootRel "daily-seed-plan.json")
$seedPlan = $null
if (Test-Path $seedPlanPath) {
    $seedPlan = Get-Content $seedPlanPath -Raw | ConvertFrom-Json
}

# Check ingest summary recency
$ingestSummaryPath = Join-Path $HubRoot (Join-Path $knowledgeRootRel "last-ingest-summary.json")
$lastIngest = $null
if (Test-Path $ingestSummaryPath) {
    $lastIngest = Get-Content $ingestSummaryPath -Raw | ConvertFrom-Json
}

$agentRuns = if ($agentState -and $agentState.PSObject.Properties['runs']) { $agentState.runs } else { "N/A" }
$noteCount = if ($agentState -and $agentState.PSObject.Properties['last_note_count']) { $agentState.last_note_count } else { "N/A" }
$clusterStatus = if ($agentState -and $agentState.PSObject.Properties['cluster_link']) { $agentState.cluster_link } else { "Offline / Standalone" }
$suggestion = if ($agentState -and $agentState.PSObject.Properties['last_suggestion']) { $agentState.last_suggestion } else { "None" }

$topProject = if ($seedPlan -and $seedPlan.PSObject.Properties['topPriorityProject']) { $seedPlan.topPriorityProject } else { "Unspecified" }
$docsProcessed = if ($seedPlan -and $seedPlan.PSObject.Properties['ingestDocumentsProcessed']) { $seedPlan.ingestDocumentsProcessed } else { 0 }
$lastIngestRun = if ($lastIngest -and $lastIngest.PSObject.Properties['runAt']) { $lastIngest.runAt } else { "Unknown" }

$briefText = @(
    "# AI Hub Daily State-of-Affairs Brief"
    "**Generated At**: $now"
    "**Date**: $today"
    ""
    "## 1. System Status & Cluster Link"
    "- **Agent Runs**: $agentRuns"
    "- **Knowledge Note Count**: $noteCount"
    "- **Cluster Status**: $clusterStatus"
    "- **Last Agent Suggestion**: $suggestion"
    ""
    "## 2. Active Priorities & Seed Plan"
    "- **Top Priority Project**: $topProject"
    "- **Ingest Documents Processed**: $docsProcessed"
    "- **Last Ingest Run**: $lastIngestRun"
    ""
    "## 3. Knowledge Inbox Status"
    "- **Pending Inbox Items**: $($inboxFiles.Count) item(s) detected in preview"
) -join [Environment]::NewLine

Set-Content -Path $BriefFile -Value $briefText -Encoding UTF8
Write-Output "Daily brief updated successfully at $BriefFile"