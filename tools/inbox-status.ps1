param(
    [string]$HubRoot = "",
    [int]$Top = 10
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

$configPath = Join-Path $HubRoot "config.local.json"
if (-not (Test-Path $configPath)) {
    throw "Missing config file: $configPath"
}

$config = Get-Content $configPath -Raw | ConvertFrom-Json
$knowledgeRootRel = if (-not [string]::IsNullOrWhiteSpace($config.knowledge_root)) { [string]$config.knowledge_root } else { "knowledge" }
$inboxRel = if (-not [string]::IsNullOrWhiteSpace($config.knowledge_inbox)) { [string]$config.knowledge_inbox } else { (Join-Path $knowledgeRootRel "inbox") }
$processedRel = if ($config.PSObject.Properties.Name -contains "knowledge_archive" -and -not [string]::IsNullOrWhiteSpace($config.knowledge_archive)) { [string]$config.knowledge_archive } else { (Join-Path $knowledgeRootRel "processed") }

$inboxPath = Join-Path $HubRoot $inboxRel
$processedPath = Join-Path $HubRoot $processedRel
$summaryPath = Join-Path (Join-Path $HubRoot $knowledgeRootRel) "last-ingest-summary.json"

if (-not (Test-Path $inboxPath)) {
    throw "Inbox path not found: $inboxPath"
}

$supported = @('.md', '.txt', '.json', '.docx', '.xlsx')
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
        $rel = To-RepoRelativePath -AbsolutePath $_.FullName -BasePath $HubRoot
        " - {0} ({1})" -f $rel, $_.LastWriteTime
    }

if ($unsupportedFiles.Count -gt 0) {
    Write-Output ""
    Write-Output "Unsupported files detected (convert or move):"
    $unsupportedFiles |
        Sort-Object FullName |
        Select-Object -First $Top |
        ForEach-Object {
            $rel = To-RepoRelativePath -AbsolutePath $_.FullName -BasePath $HubRoot
            " - {0}" -f $rel
        }
}
