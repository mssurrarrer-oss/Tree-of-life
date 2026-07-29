[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [string]$HubRoot = "",
    [string]$TaskName = "AI-Hub-Daily-Checkin",
    [string]$Time = "08:00",
    [switch]$ArchiveInbox,
    [switch]$SkipTriage,
    [switch]$SkipImport,
    [switch]$SkipSpendSummary,
    [switch]$RunCareSimulation,
    [switch]$RunNow,
    [switch]$Force
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

$schedulerHubRoot = $HubRoot
$rootPrefix = [System.IO.Path]::GetPathRoot($HubRoot)
if ($rootPrefix -and $rootPrefix.Length -ge 2 -and $rootPrefix[1] -eq ':') {
    $driveName = $rootPrefix.Substring(0, 1)
    $driveInfo = Get-PSDrive -Name $driveName -ErrorAction SilentlyContinue
    if ($driveInfo -and -not [string]::IsNullOrWhiteSpace($driveInfo.DisplayRoot)) {
        $relativePart = $HubRoot.Substring($rootPrefix.Length).TrimStart('\\')
        if ([string]::IsNullOrWhiteSpace($relativePart)) {
            $schedulerHubRoot = $driveInfo.DisplayRoot
        } else {
            $schedulerHubRoot = Join-Path $driveInfo.DisplayRoot $relativePart
        }
    }
}

$scheduledWrapperScript = Join-Path $HubRoot "tools\run-daily-checkin-scheduled.ps1"
if (-not (Test-Path $scheduledWrapperScript)) {
    throw "Missing scheduled check-in wrapper: $scheduledWrapperScript"
}

$scheduledWrapperScriptForTask = Join-Path $schedulerHubRoot "tools\run-daily-checkin-scheduled.ps1"

try {
    $timeValue = [DateTime]::ParseExact($Time, "HH:mm", [System.Globalization.CultureInfo]::InvariantCulture)
}
catch {
    throw "Invalid time format '$Time'. Use HH:mm, for example 08:00 or 21:30."
}

$existingTask = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
if ($existingTask -and -not $Force) {
    throw "Task '$TaskName' already exists. Re-run with -Force to replace it."
}

if ($existingTask -and $Force) {
    if ($PSCmdlet.ShouldProcess($TaskName, "Remove existing scheduled task")) {
        Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
    }
}

$checkinArgs = @(
    "-NoProfile"
    "-ExecutionPolicy"
    "Bypass"
    "-File"
    "`"$scheduledWrapperScriptForTask`""
    "-HubRoot"
    "`"$schedulerHubRoot`""
)

if ($ArchiveInbox) {
    $checkinArgs += "-ArchiveInbox"
}

if ($SkipTriage) {
    $checkinArgs += "-SkipTriage"
}

if ($SkipImport) {
    $checkinArgs += "-SkipImport"
}

if ($SkipSpendSummary) {
    $checkinArgs += "-SkipSpendSummary"
}

if ($RunCareSimulation) {
    $checkinArgs += "-RunCareSimulation"
}

$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument ($checkinArgs -join ' ') -WorkingDirectory $schedulerHubRoot
$triggerTime = Get-Date -Hour $timeValue.Hour -Minute $timeValue.Minute -Second 0
$trigger = New-ScheduledTaskTrigger -Daily -At $triggerTime
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable
$principal = New-ScheduledTaskPrincipal -UserId "$env:USERDOMAIN\$env:USERNAME" -LogonType Interactive -RunLevel Limited
$description = "Runs AI Hub daily check-in workflow and generates brief + triage artifacts."

if ($PSCmdlet.ShouldProcess($TaskName, "Register scheduled task")) {
    Register-ScheduledTask -TaskName $TaskName -Action $action -Trigger $trigger -Settings $settings -Principal $principal -Description $description | Out-Null
}

if ($RunNow) {
    if ($PSCmdlet.ShouldProcess($TaskName, "Run scheduled task now")) {
        Start-ScheduledTask -TaskName $TaskName
    }
}

$taskInfo = Get-ScheduledTaskInfo -TaskName $TaskName
Write-Output "Scheduled task '$TaskName' registered."
Write-Output "TaskHubRoot: $schedulerHubRoot"
Write-Output "NextRunTime: $($taskInfo.NextRunTime)"
Write-Output "LastRunTime: $($taskInfo.LastRunTime)"
Write-Output "LastTaskResult: $($taskInfo.LastTaskResult)"
