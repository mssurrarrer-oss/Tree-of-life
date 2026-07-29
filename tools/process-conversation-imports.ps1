param(
    [string]$HubRoot = "",
    [string]$DropPath = "",
    [ValidateSet("Move", "Copy")]
    [string]$Mode = "Move",
    [ValidateSet("group", "personal")]
    [string]$DefaultLane = "group"
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

if ([string]::IsNullOrWhiteSpace($DropPath)) {
    $DropPath = Join-Path $HubRoot "knowledge\inbox\import-drop"
}

if (-not (Test-Path $DropPath)) {
    New-Item -Path $DropPath -ItemType Directory -Force | Out-Null
}

function To-Slug {
    param([string]$Text)

    $clean = $Text.ToLowerInvariant()
    $clean = $clean -replace '[^a-z0-9]+', '-'
    $clean = $clean.Trim('-')
    if ([string]::IsNullOrWhiteSpace($clean)) {
        return "item"
    }

    return $clean
}

function Resolve-SourceTag {
    param([string]$FileName)

    $name = $FileName.ToLowerInvariant()

    if ($name -match 'copilot|microsoft|ms-') { return 'ms-copilot' }
    if ($name -match 'gemini|google') { return 'google-gemini' }
    if ($name -match 'chatgpt|openai') { return 'openai-chatgpt' }
    if ($name -match 'claude|anthropic') { return 'anthropic-claude' }

    return 'unknown-source'
}

function Resolve-Lane {
    param(
        [string]$FileName,
        [string]$Default
    )

    $name = $FileName.ToLowerInvariant()
    if ($name -match 'personal|private|journal|diary') { return 'personal' }
    if ($name -match 'group|shared|collab|mission|team') { return 'group' }

    return $Default
}

function New-UniquePath {
    param([string]$CandidatePath)

    if (-not (Test-Path $CandidatePath)) {
        return $CandidatePath
    }

    $dir = Split-Path -Parent $CandidatePath
    $name = [System.IO.Path]::GetFileNameWithoutExtension($CandidatePath)
    $ext = [System.IO.Path]::GetExtension($CandidatePath)

    for ($i = 1; $i -lt 10000; $i++) {
        $next = Join-Path $dir ("{0}-{1}{2}" -f $name, $i, $ext)
        if (-not (Test-Path $next)) {
            return $next
        }
    }

    throw "Unable to create unique file path for $CandidatePath"
}

$allowed = @('.md', '.txt', '.json', '.docx', '.xlsx')
$excludedNames = @('readme.md')
$files = @(
    Get-ChildItem -Path $DropPath -File -Recurse -ErrorAction SilentlyContinue |
        Where-Object {
            $allowed -contains $_.Extension.ToLowerInvariant() -and
            $excludedNames -notcontains $_.Name.ToLowerInvariant() -and
            -not $_.Name.ToLowerInvariant().EndsWith('.meta.md')
        }
)

if ($files.Count -eq 0) {
    Write-Output "No supported import files found in $DropPath"
    exit 0
}

$imported = @()
foreach ($file in $files) {
    $sourceTag = Resolve-SourceTag -FileName $file.Name
    $lane = Resolve-Lane -FileName $file.Name -Default $DefaultLane
    $dateTag = $file.LastWriteTime.ToString('yyyy-MM-dd')
    $slug = To-Slug -Text $file.BaseName

    $destinationDir = Join-Path $HubRoot (Join-Path "knowledge\inbox" (Join-Path $lane "conversations"))
    New-Item -Path $destinationDir -ItemType Directory -Force | Out-Null

    $baseFileName = "{0}-{1}-{2}{3}" -f $dateTag, $sourceTag, $slug, $file.Extension.ToLowerInvariant()
    $destinationPath = Join-Path $destinationDir $baseFileName
    $destinationPath = New-UniquePath -CandidatePath $destinationPath

    if ($Mode -eq 'Copy') {
        Copy-Item -Path $file.FullName -Destination $destinationPath -Force
    } else {
        Move-Item -Path $file.FullName -Destination $destinationPath -Force
    }

    $metaPath = "$destinationPath.meta.md"
    $metaLines = @(
        "# Conversation Import Metadata"
        ""
        "- ImportedAt: $((Get-Date).ToString('s'))"
        "- OriginalFileName: $($file.Name)"
        "- SourceTag: $sourceTag"
        "- Lane: $lane"
        "- Mode: $Mode"
        "- RoutedPath: $destinationPath"
    )

    Set-Content -Path $metaPath -Value ($metaLines -join [Environment]::NewLine) -Encoding UTF8

    $imported += [PSCustomObject]@{
        Source = $file.FullName
        Destination = $destinationPath
        Lane = $lane
        SourceTag = $sourceTag
    }
}

Write-Output ("Imported conversation files: {0}" -f $imported.Count)
$imported | ForEach-Object {
    Write-Output (" - [{0}] {1} -> {2}" -f $_.Lane, $_.Source, $_.Destination)
}
