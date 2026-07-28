$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$python = Get-Command py -ErrorAction SilentlyContinue
if ($python) {
  & py "$scriptDir/starter-agent.py"
} else {
  Write-Host "Python launcher not found. Install Python or add py.exe to PATH."
}
