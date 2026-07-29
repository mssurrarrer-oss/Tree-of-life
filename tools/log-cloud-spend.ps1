param(
    [string]$HubRoot = "",
    [string]$LedgerPath = "",
    [string]$BatchId,
    [string]$Provider,
    [string]$Model,
    [int]$TokensIn = 0,
    [int]$TokensOut = 0,
    [double]$CostUsd,
    [string]$Objective = "",
    [string]$ArtifactPath = "",
    [string]$Status = "executed",
    [string]$Notes = ""
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($BatchId)) { throw "BatchId is required." }
if ([string]::IsNullOrWhiteSpace($Provider)) { throw "Provider is required." }
if ([string]::IsNullOrWhiteSpace($Model)) { throw "Model is required." }

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

$ledgerDir = Split-Path -Parent $LedgerPath
if (-not [string]::IsNullOrWhiteSpace($ledgerDir)) {
    New-Item -Path $ledgerDir -ItemType Directory -Force | Out-Null
}

$row = [PSCustomObject]@{
    timestamp = (Get-Date).ToString('s')
    date = (Get-Date).ToString('yyyy-MM-dd')
    batchId = $BatchId
    provider = $Provider
    model = $Model
    tokensIn = [int]$TokensIn
    tokensOut = [int]$TokensOut
    totalTokens = ([int]$TokensIn + [int]$TokensOut)
    costUsd = [double]$CostUsd
    objective = $Objective
    artifactPath = $ArtifactPath
    status = $Status
    notes = $Notes
}

if (-not (Test-Path $LedgerPath)) {
    $row | Export-Csv -Path $LedgerPath -NoTypeInformation -Encoding UTF8
} else {
    $row | Export-Csv -Path $LedgerPath -NoTypeInformation -Append -Encoding UTF8
}

Write-Output "Cloud spend entry appended to $LedgerPath"
Write-Output ("Batch={0} Provider={1} Model={2} CostUsd={3}" -f $BatchId, $Provider, $Model, $CostUsd)
