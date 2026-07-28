# Model Performance Monitor Script
# Tracks GPU/CPU usage, memory consumption, and token generation speed
# Useful for comparing different quantization levels

Write-Host "=== Gemma 4 Model Performance Monitor ===" -ForegroundColor Cyan

# Function to get current system memory info
function Get-MemoryStats {
    $physicalMemory = [System.GC]::GetGCMemoryInfo()
    Write-Host "Available Physical Memory: $($physicalMemory.AvailableMemory / 1GB) GB" -ForegroundColor Gray
    
    # Check for LM Studio memory usage (if available via process list)
    try {
        $lmProcesses = Get-Process | Where-Object {$_.ProcessName -like "*LM*"}
        if ($lmProcesses) {
            Write-Host "LM Studio Memory: $($lmProcesses.TotalWorkingSet / 1MB) MB" -ForegroundColor Green
        }
    } catch {
        Write-Host "Could not detect LM Studio process" -ForegroundColor Yellow
    }
}

# Function to get GPU usage (requires PowerShell +WMI or similar)
function Get-GPUStats {
    try {
        $gpuInfo = Get-CimInstance Win32_VideoController | Select-Object Name, DriverVersion, AdapterRAM
        Write-Host "GPU: $($gpuInfo.Name)" -ForegroundColor Gray
        Write-Host "VRAM: $($gpuInfo.AdapterRAM / 1GB) GB" -ForegroundColor Gray
    } catch {
        Write-Host "Could not access GPU information" -ForegroundColor Yellow
    }
}

# Function to monitor CPU usage over time
function Monitor-CPUUsage {
    Write-Host "`nMonitoring CPU Usage..." -ForegroundColor Cyan
    
    for ($i = 0; $i -lt 10; $i++) {
        $cpuInfo = Get-CimInstance Win32_Processor | Select-Object Name, CurrentClockSpeed, PowerState
        Write-Host "Processor $($i+1): $($cpuInfo.Name) | Speed: $($cpuInfo.CurrentClockSpeed) | State: $($cpuInfo.PowerState)" -ForegroundColor Gray
        
        Start-Sleep -Seconds 5
    }
}

# Function to check model quantization settings (read from LM Studio config if available)
function Check-QuantizationSetting {
    try {
        $configFile = "config.local.json"
        if (Test-Path $configFile) {
            $config = Get-Content $configFile -Raw | ConvertFrom-Json
            Write-Host "Current Quantization: $($config.lmstudio.quantization)" -ForegroundColor Green
            Write-Host "Batch Size: $($config.lmstudio.batchSize)" -ForegroundColor Green
        }
    } catch {
        Write-Host "Could not read LM Studio configuration" -ForegroundColor Yellow
    }
}

# Main monitoring loop
Write-Host "`nStarting Performance Monitor..." -ForegroundColor Cyan
Get-MemoryStats
Check-QuantizationSetting
Get-GPUStats

Write-Host "`nPress Ctrl+C to stop monitoring..." -ForegroundColor Yellow
