param(
    [string]$HubRoot = "",
    [string]$TriggerConfigPath = "",
    [string]$EventPath = "",
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

if ([string]::IsNullOrWhiteSpace($TriggerConfigPath)) {
    $TriggerConfigPath = Join-Path $HubRoot "services\automation-framework\care-alert-triggers.json"
}
if ([string]::IsNullOrWhiteSpace($EventPath)) {
    $EventPath = Join-Path $HubRoot "services\automation-framework\care-alert-sample-events.json"
}
if ([string]::IsNullOrWhiteSpace($OutputPath)) {
    $dateTag = (Get-Date).ToString('yyyy-MM-dd')
    $OutputPath = Join-Path $HubRoot "knowledge\checkins\$dateTag-care-alert-simulation.md"
}

if (-not (Test-Path $TriggerConfigPath)) {
    throw "Trigger config not found: $TriggerConfigPath"
}
if (-not (Test-Path $EventPath)) {
    throw "Event file not found: $EventPath"
}

$triggerConfig = Get-Content -Path $TriggerConfigPath -Raw | ConvertFrom-Json
$events = Get-Content -Path $EventPath -Raw | ConvertFrom-Json

function Test-TimeWindow {
    param(
        [DateTime]$Timestamp,
        [string]$Window
    )

    if ([string]::IsNullOrWhiteSpace($Window)) {
        return $true
    }

    $parts = $Window.Split('-')
    if ($parts.Count -ne 2) {
        return $true
    }

    $start = [TimeSpan]::Parse($parts[0])
    $end = [TimeSpan]::Parse($parts[1])
    $t = $Timestamp.TimeOfDay

    if ($start -le $end) {
        return ($t -ge $start -and $t -le $end)
    }

    # overnight window such as 22:00-06:00
    return ($t -ge $start -or $t -le $end)
}

function Test-TriggerCondition {
    param(
        [object]$Record,
        [object]$Trigger
    )

    if ([string]$Record.eventType -ne [string]$Trigger.eventType) {
        return $false
    }

    $c = $Trigger.conditions

    if ($c.PSObject.Properties.Name -contains 'personRole') {
        if ([string]$Record.personRole -ne [string]$c.personRole) { return $false }
    }

    if ($c.PSObject.Properties.Name -contains 'zone') {
        if ([string]$Record.zone -ne [string]$c.zone) { return $false }
    }

    if ($c.PSObject.Properties.Name -contains 'deviceType') {
        if ([string]$Record.deviceType -ne [string]$c.deviceType) { return $false }
    }

    if ($c.PSObject.Properties.Name -contains 'status') {
        if ([string]$Record.status -ne [string]$c.status) { return $false }
    }

    if ($c.PSObject.Properties.Name -contains 'confidenceMin') {
        if ([double]$Record.confidence -lt [double]$c.confidenceMin) { return $false }
    }

    if ($c.PSObject.Properties.Name -contains 'inactivityMinutesMin') {
        if ([int]$Record.inactivityMinutes -lt [int]$c.inactivityMinutesMin) { return $false }
    }

    if ($c.PSObject.Properties.Name -contains 'offlineMinutesMin') {
        if ([int]$Record.offlineMinutes -lt [int]$c.offlineMinutesMin) { return $false }
    }

    if ($c.PSObject.Properties.Name -contains 'heartRateMin') {
        if ([int]$Record.heartRate -lt [int]$c.heartRateMin) { return $false }
    }

    if ($c.PSObject.Properties.Name -contains 'heartRateMax') {
        if ([int]$Record.heartRate -gt [int]$c.heartRateMax) { return $false }
    }

    if ($c.PSObject.Properties.Name -contains 'spo2Min') {
        if ([double]$Record.spo2 -lt [double]$c.spo2Min) { return $false }
    }

    if ($c.PSObject.Properties.Name -contains 'spo2Max') {
        if ([double]$Record.spo2 -gt [double]$c.spo2Max) { return $false }
    }

    if ($c.PSObject.Properties.Name -contains 'missedMinutesMin') {
        if ([int]$Record.missedMinutes -lt [int]$c.missedMinutesMin) { return $false }
    }

    if ($c.PSObject.Properties.Name -contains 'timeWindow') {
        $timestamp = [DateTime]::Parse([string]$Record.timestamp)
        if (-not (Test-TimeWindow -Timestamp $timestamp -Window ([string]$c.timeWindow))) {
            return $false
        }
    }

    return $true
}

$triggerHits = @()
foreach ($evtRecord in $events) {
    foreach ($trigger in $triggerConfig.triggers) {
        if (Test-TriggerCondition -Record $evtRecord -Trigger $trigger) {
            $triggerHits += [PSCustomObject]@{
                EventId = [string]$evtRecord.eventId
                EventType = [string]$evtRecord.eventType
                TriggerId = [string]$trigger.id
                Severity = [string]$trigger.severity
                Actions = ([string[]]$trigger.actions -join ', ')
                Source = [string]$evtRecord.source
                Timestamp = [string]$evtRecord.timestamp
            }
        }
    }
}

$outputDir = Split-Path -Parent $OutputPath
if (-not [string]::IsNullOrWhiteSpace($outputDir)) {
    New-Item -Path $outputDir -ItemType Directory -Force | Out-Null
}

$lines = @()
$lines += "# Care Alert Simulation Report"
$lines += ""
$lines += "- GeneratedAt: $((Get-Date).ToString('s'))"
$lines += "- TriggerConfig: $TriggerConfigPath"
$lines += "- EventSource: $EventPath"
$lines += "- EventsProcessed: $($events.Count)"
$lines += "- TriggerMatches: $($triggerHits.Count)"
$lines += ""
$lines += "| Event ID | Event Type | Trigger | Severity | Actions | Source | Timestamp |"
$lines += "|---|---|---|---|---|---|---|"

foreach ($row in $triggerHits) {
    $lines += ("| {0} | {1} | {2} | {3} | {4} | {5} | {6} |" -f $row.EventId, $row.EventType, $row.TriggerId, $row.Severity, $row.Actions, $row.Source, $row.Timestamp)
}

if ($triggerHits.Count -eq 0) {
    $lines += "| - | - | - | - | - | - | - |"
}

$lines += ""
$lines += "## Recommended Next Steps"
$lines += "1. Connect live camera and wearable events to this schema."
$lines += "2. Route high severity alerts to at least two contacts."
$lines += "3. Review thresholds weekly to reduce false positives."
$lines += "4. Keep consent and privacy controls explicit for all monitored individuals."

Set-Content -Path $OutputPath -Value ($lines -join [Environment]::NewLine) -Encoding UTF8
Write-Output "Care alert simulation report written to $OutputPath"
