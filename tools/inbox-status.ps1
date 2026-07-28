param(
    [string]$HubRoot = "d:\ai-hub",
    [int]$Top = 10
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$configPath = Join-Path $HubRoot "config.local.json"
if (-not (Test-Path $configPath)) {
    throw "Missing config file: $configPath"
}

$config = Get-Content $configPath -Raw | ConvertFrom-Json
$inboxPath = Join-Path $HubRoot $config.knowledge_inbox
$processedPath = Join-Path $HubRoot "knowledge\processed"
$summaryPath = Join-Path $HubRoot "knowledge\last-ingest-summary.json"

if (-not (Test-Path $inboxPath)) {
    throw "Inbox path not found: $inboxPath"
}

$supported = @('.md', '.txt', '.json', '.docx')
$files = Get-ChildItem -Path $inboxPath -File -Recurse -ErrorAction Stop
$supportedFiles = @($files | Where-Object { $supported -contains $_.Extension.ToLowerInvariant() })
$unsupportedFiles = @($files | Where-Object { $supported -notcontains $_.Extension.ToLowerInvariant() })

$lastSummary = $null
if (Test-Path $summaryPath) {
    $lastSummary = Get-Content $summaryPath -Raw | ConvertFrom-Json
}

Write-Output "Inbox path: $inboxPath"
Write-Output "Processed path: $processedPath"
Write-Output ""
Write-Output ("Inbox files total: {0}" -f $files.Count)
Write-Output ("Supported ingest files: {0}" -f $supportedFiles.Count)
Write-Output ("Unsupported files: {0}" -f $unsupportedFiles.Count)

if ($lastSummary) {
    Write-Output ""
    Write-Output ("Last ingest runAt: {0}" -f $lastSummary.runAt)
    Write-Output ("Last ingest documentsSeen: {0}" -f $lastSummary.documentsSeen)
    Write-Output ("Last ingest documentsIndexed: {0}" -f $lastSummary.documentsIndexed)
    if ($lastSummary.PSObject.Properties.Name -contains "documentsDeleted") {
        Write-Output ("Last ingest documentsDeleted: {0}" -f $lastSummary.documentsDeleted)
    }
    if ($lastSummary.PSObject.Properties.Name -contains "archivedInboxFiles") {
        Write-Output ("Last ingest archivedInboxFiles: {0}" -f $lastSummary.archivedInboxFiles)
    }
}

Write-Output ""
Write-Output "Top newest supported files:"
$supportedFiles |
    Sort-Object LastWriteTime -Descending |
    Select-Object -First $Top |
    ForEach-Object {
        $rel = $_.FullName.Substring($HubRoot.Length).TrimStart('\\')
        " - {0} ({1})" -f $rel.Replace('\\', '/'), $_.LastWriteTime
    }

if ($unsupportedFiles.Count -gt 0) {
    Write-Output ""
    Write-Output "Unsupported files detected (convert or move):"
    $unsupportedFiles |
        Sort-Object FullName |
        Select-Object -First $Top |
        ForEach-Object {
            $rel = $_.FullName.Substring($HubRoot.Length).TrimStart('\\')
            " - {0}" -f $rel.Replace('\\', '/')
        }
}
