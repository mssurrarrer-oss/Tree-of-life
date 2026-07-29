param(
    [string]$HubRoot = "",
    [string]$LedgerPath = "",
    [string]$StartDate = "",
    [string]$EndDate = "",
    [double]$BudgetUsd = 0,
    [string]$OutputPath = ""
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

if ([string]::IsNullOrWhiteSpace($LedgerPath)) {
    $LedgerPath = Join-Path $HubRoot "knowledge\cloud-spend-ledger.csv"
}

if ([string]::IsNullOrWhiteSpace($StartDate)) {
    $StartDate = (Get-Date).ToString('yyyy-MM-dd')
}

if ([string]::IsNullOrWhiteSpace($EndDate)) {
    $EndDate = $StartDate
}

$start = [DateTime]::ParseExact($StartDate, 'yyyy-MM-dd', [System.Globalization.CultureInfo]::InvariantCulture)
$end = [DateTime]::ParseExact($EndDate, 'yyyy-MM-dd', [System.Globalization.CultureInfo]::InvariantCulture)

$rows = @()
if (Test-Path $LedgerPath) {
    $rows = Import-Csv -Path $LedgerPath
}

$filtered = @($rows | Where-Object {
    try {
        $rowDate = [DateTime]::ParseExact([string]$_.date, 'yyyy-MM-dd', [System.Globalization.CultureInfo]::InvariantCulture)
        $rowDate.Date -ge $start.Date -and $rowDate.Date -le $end.Date
    }
    catch {
        $false
    }
})

$totalCost = 0.0
$totalIn = 0
$totalOut = 0
foreach ($row in $filtered) {
    $totalCost += [double]$row.costUsd
    $totalIn += [int]$row.tokensIn
    $totalOut += [int]$row.tokensOut
}

$grouped = $filtered |
    Group-Object provider, model |
    Sort-Object Count -Descending

$lines = @()
$lines += "# Cloud Spend Summary"
$lines += ""
$lines += "- Window: $StartDate to $EndDate"
$lines += "- Entries: $($filtered.Count)"
$lines += ("- Total Cost (USD): {0:N4}" -f $totalCost)
$lines += "- Tokens In: $totalIn"
$lines += "- Tokens Out: $totalOut"
$lines += "- Total Tokens: $($totalIn + $totalOut)"

if ($BudgetUsd -gt 0) {
    $remaining = $BudgetUsd - $totalCost
    $lines += ("- Budget (USD): {0:N4}" -f $BudgetUsd)
    $lines += ("- Remaining (USD): {0:N4}" -f $remaining)
}

$lines += ""
$lines += "## Breakdown"
$lines += "| Provider | Model | Runs | Cost USD | Tokens |"
$lines += "|---|---|---:|---:|---:|"

foreach ($group in $grouped) {
    $provider = [string]$group.Group[0].provider
    $model = [string]$group.Group[0].model
    $runs = $group.Count
    $cost = 0.0
    $tokens = 0
    foreach ($entry in $group.Group) {
        $cost += [double]$entry.costUsd
        $tokens += ([int]$entry.tokensIn + [int]$entry.tokensOut)
    }

    $lines += ("| {0} | {1} | {2} | {3:N4} | {4} |" -f $provider, $model, $runs, $cost, $tokens)
}

if ([string]::IsNullOrWhiteSpace($OutputPath)) {
    Write-Output ($lines -join [Environment]::NewLine)
} else {
    $outputDir = Split-Path -Parent $OutputPath
    if (-not [string]::IsNullOrWhiteSpace($outputDir)) {
        New-Item -Path $outputDir -ItemType Directory -Force | Out-Null
    }

    Set-Content -Path $OutputPath -Value ($lines -join [Environment]::NewLine) -Encoding UTF8
    Write-Output "Cloud spend summary written to $OutputPath"
}
