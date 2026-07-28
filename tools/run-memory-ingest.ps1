param(
  [switch]$ArchiveInbox
)

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

$ingestArgs = @("$scriptDir/memory_ingest.py")
if ($ArchiveInbox) {
  $ingestArgs += "--archive-inbox"
}

$pyLauncher = Get-Command py -ErrorAction SilentlyContinue
$python = Get-Command python -ErrorAction SilentlyContinue

function Get-UvPython {
  $uvRoot = Join-Path $env:APPDATA "uv\python"
  if (-not (Test-Path $uvRoot)) {
    return $null
  }

  $candidates = @(Get-ChildItem -Path $uvRoot -Filter python.exe -Recurse -ErrorAction SilentlyContinue |
    Sort-Object LastWriteTime -Descending)

  if ($candidates -and $candidates.Count -gt 0) {
    return $candidates[0].FullName
  }

  return $null
}

if ($pyLauncher) {
  & py @ingestArgs
  exit $LASTEXITCODE
} elseif ($python -and $python.Source -notlike "*WindowsApps\python.exe") {
  & $python.Source @ingestArgs
  exit $LASTEXITCODE
} else {
  $uvPython = Get-UvPython
  if ($uvPython) {
    & $uvPython @ingestArgs
    exit $LASTEXITCODE
  }

  $conda = Get-Command conda -ErrorAction SilentlyContinue
  if ($conda) {
    & conda run -n base python @ingestArgs
    exit $LASTEXITCODE
  }

  Write-Error "Python not found on PATH and no uv/conda runtime detected. Configure Python before running ingest."
  exit 1
}
