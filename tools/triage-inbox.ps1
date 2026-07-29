param(
    [string]$HubRoot = "",
    [string]$OutputPath = "",
    [int]$Top = 20
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

function To-RepoRelativePath {
    param(
        [string]$AbsolutePath,
        [string]$BasePath
    )

    $base = (Resolve-Path $BasePath).ProviderPath.TrimEnd('\\')
    $target = (Resolve-Path $AbsolutePath).ProviderPath

    if ($target.StartsWith($base, [System.StringComparison]::OrdinalIgnoreCase)) {
        return ($target.Substring($base.Length).TrimStart('\\') -replace '\\', '/')
    }

    return ($target -replace '\\', '/')
}

function Get-Lane {
    param([string]$RelativePath)

    if ($RelativePath -match '^knowledge/inbox/personal/') {
        return 'personal'
    }

    if ($RelativePath -match '^knowledge/inbox/group/') {
        return 'group'
    }

    return 'shared'
}

function Get-PriorityLabel {
    param([int]$Score)

    if ($Score -ge 80) { return 'P0' }
    if ($Score -ge 60) { return 'P1' }
    if ($Score -ge 40) { return 'P2' }
    return 'P3'
}

$configPath = Join-Path $HubRoot "config.local.json"
if (-not (Test-Path $configPath)) {
    throw "Missing config file: $configPath"
}

$config = Get-Content -Path $configPath -Raw | ConvertFrom-Json
$knowledgeRootRel = if ($config.knowledge_root) { [string]$config.knowledge_root } else { "knowledge" }
$inboxRel = if ($config.knowledge_inbox) { [string]$config.knowledge_inbox } else { (Join-Path $knowledgeRootRel "inbox") }
$inboxPath = Join-Path $HubRoot $inboxRel

if (-not (Test-Path $inboxPath)) {
    throw "Inbox path not found: $inboxPath"
}

if ([string]::IsNullOrWhiteSpace($OutputPath)) {
    $dateTag = (Get-Date).ToString("yyyy-MM-dd")
    $OutputPath = Join-Path $HubRoot "knowledge\checkins\$dateTag-inbox-triage.md"
}

$outputDir = Split-Path -Parent $OutputPath
if (-not [string]::IsNullOrWhiteSpace($outputDir)) {
    New-Item -Path $outputDir -ItemType Directory -Force | Out-Null
}

$supportedExtensions = @('.md', '.txt', '.json', '.docx', '.xlsx')

$urgentWeights = @{
    "critical" = 40
    "urgent" = 35
    "asap" = 30
    "security" = 35
    "incident" = 35
    "outage" = 35
    "hotfix" = 30
}

$operationsWeights = @{
    "camera" = 20
    "electrical" = 20
    "firmware" = 25
    "software" = 15
    "network" = 15
    "update" = 20
    "patch" = 20
    "automation" = 20
    "coordination" = 15
}

$planningWeights = @{
    "spec" = 15
    "roadmap" = 15
    "tracker" = 15
    "plan" = 15
    "constitution" = 12
}

$nowUtc = (Get-Date).ToUniversalTime()
$rows = @()
$files = Get-ChildItem -Path $inboxPath -File -Recurse

foreach ($file in $files) {
    $relativePath = To-RepoRelativePath -AbsolutePath $file.FullName -BasePath $HubRoot
    $nameLower = $file.Name.ToLowerInvariant()
    $score = 0
    $reasons = @()

    foreach ($token in $urgentWeights.Keys) {
        if ($nameLower.Contains($token)) {
            $score += [int]$urgentWeights[$token]
            $reasons += "urgent:$token"
        }
    }

    foreach ($token in $operationsWeights.Keys) {
        if ($nameLower.Contains($token)) {
            $score += [int]$operationsWeights[$token]
            $reasons += "ops:$token"
        }
    }

    foreach ($token in $planningWeights.Keys) {
        if ($nameLower.Contains($token)) {
            $score += [int]$planningWeights[$token]
            $reasons += "plan:$token"
        }
    }

    $ageHours = (($nowUtc) - $file.LastWriteTimeUtc).TotalHours
    if ($ageHours -le 24) {
        $score += 20
        $reasons += "fresh:24h"
    } elseif ($ageHours -le 72) {
        $score += 10
        $reasons += "fresh:72h"
    }

    $extension = $file.Extension.ToLowerInvariant()
    $isSupported = $supportedExtensions -contains $extension
    if (-not $isSupported) {
        $score -= 20
        $reasons += "unsupported:$extension"
    }

    $lane = Get-Lane -RelativePath $relativePath
    if ($lane -eq 'group') {
        $score += 5
        $reasons += "lane:group"
    } elseif ($lane -eq 'personal') {
        $score += 3
        $reasons += "lane:personal"
    }

    if ($score -lt 0) {
        $score = 0
    }

    $rows += [PSCustomObject]@{
        Priority = Get-PriorityLabel -Score $score
        Score = $score
        Lane = $lane
        RelativePath = $relativePath
        LastWriteTime = $file.LastWriteTime
        Reasons = if ($reasons.Count -gt 0) { ($reasons -join ', ') } else { 'baseline' }
    }
}

$sorted = $rows |
    Sort-Object @{ Expression = 'Score'; Descending = $true }, @{ Expression = 'LastWriteTime'; Descending = $true }, RelativePath

$topRows = @($sorted | Select-Object -First $Top)

$p0Count = @($rows | Where-Object { $_.Priority -eq 'P0' }).Count
$p1Count = @($rows | Where-Object { $_.Priority -eq 'P1' }).Count
$p2Count = @($rows | Where-Object { $_.Priority -eq 'P2' }).Count
$p3Count = @($rows | Where-Object { $_.Priority -eq 'P3' }).Count

$lines = @()
$lines += "# Inbox Triage Report"
$lines += ""
$lines += "Generated At: $((Get-Date).ToString('yyyy-MM-dd HH:mm:ss'))"
$lines += "Inbox Path: $inboxPath"
$lines += "Total Files Evaluated: $($rows.Count)"
$lines += "Priority Counts: P0=$p0Count, P1=$p1Count, P2=$p2Count, P3=$p3Count"
$lines += ""
$lines += "## Queue (Top $($topRows.Count))"
$lines += "| Rank | Priority | Lane | Score | File | Reasons | Last Modified |"
$lines += "|---:|:---:|:---:|---:|---|---|---|"

$rank = 0
foreach ($row in $topRows) {
    $rank += 1
    $safePath = $row.RelativePath.Replace('|', '/')
    $safeReasons = [string]$row.Reasons
    $safeReasons = $safeReasons.Replace('|', ', ')
    $lines += "| $rank | $($row.Priority) | $($row.Lane) | $($row.Score) | $safePath | $safeReasons | $($row.LastWriteTime.ToString('yyyy-MM-dd HH:mm')) |"
}

$lines += ""
$lines += "## Recommended Routing"
$lines += "1. P0: route immediately to cloud coordination officer for same-session action."
$lines += "2. P1: assign to today's execution window and capture evidence output."
$lines += "3. P2: schedule for this cycle after stability task completion."
$lines += "4. P3: keep as backlog until promoted by new context."

$lines += ""
$lines += "## Personal and Group Inbox Guidance"
$lines += "- Place private materials under knowledge/inbox/personal/."
$lines += "- Place shared mission materials under knowledge/inbox/group/."
$lines += "- Root-level knowledge/inbox/ items are treated as shared by default."

Set-Content -Path $OutputPath -Value ($lines -join [Environment]::NewLine) -Encoding UTF8
Write-Output "Inbox triage report written to $OutputPath"
