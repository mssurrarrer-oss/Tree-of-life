param(
	[switch]$Quiet,
	[switch]$SkipGitConfig
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = (Resolve-Path (Join-Path $scriptDir "..")).Path
$configPath = Join-Path $repoRoot "config.local.json"

function Write-Status {
	param([string]$Message)
	if (-not $Quiet) {
		Write-Host $Message
	}
}

function Resolve-CommandPath {
	param(
		[string[]]$Names,
		[string[]]$CandidatePaths = @()
	)

	foreach ($name in $Names) {
		$command = Get-Command $name -ErrorAction SilentlyContinue
		if ($command) {
			return $command.Source
		}
	}

	foreach ($candidate in $CandidatePaths) {
		if (-not [string]::IsNullOrWhiteSpace($candidate) -and (Test-Path $candidate)) {
			return (Resolve-Path $candidate).Path
		}
	}

	return $null
}

function Resolve-LmStudioPath {
	$whereOutput = $null
	try {
		$whereOutput = & where.exe "LM Studio.exe" 2>$null
	}
	catch {
		$whereOutput = $null
	}

	if ($LASTEXITCODE -eq 0 -and $whereOutput) {
		foreach ($entry in $whereOutput) {
			if (-not [string]::IsNullOrWhiteSpace($entry) -and (Test-Path $entry)) {
				return (Resolve-Path $entry).Path
			}
		}
	}

	$candidatePaths = @(
		"$env:LOCALAPPDATA\Programs\LM Studio\LM Studio.exe",
		"$env:ProgramFiles\LM Studio\LM Studio.exe",
		"$env:ProgramFiles(x86)\LM Studio\LM Studio.exe"
	)

	return Resolve-CommandPath -Names @("LM Studio.exe") -CandidatePaths $candidatePaths
}

function Resolve-PythonPath {
	$candidatePaths = @(
		"$env:LOCALAPPDATA\Programs\Python\Python311\python.exe",
		"$env:LOCALAPPDATA\Programs\Python\Python310\python.exe",
		"$env:LOCALAPPDATA\Programs\Python\Python39\python.exe",
		"$env:ProgramFiles\Python311\python.exe",
		"$env:ProgramFiles\Python310\python.exe",
		"$env:ProgramFiles\Python39\python.exe"
	)

	return Resolve-CommandPath -Names @("py", "python", "python3") -CandidatePaths $candidatePaths
}

$config = @{}
if (Test-Path $configPath) {
	try {
		$rawConfig = Get-Content $configPath -Raw | ConvertFrom-Json
		if ($rawConfig) {
			foreach ($property in $rawConfig.PSObject.Properties) {
				$config[$property.Name] = $property.Value
			}
		}
	}
	catch {
		Write-Status "Existing config.local.json could not be parsed; creating a fresh config file."
	}
}

$config["repo_root"] = $repoRoot
$config["machine_name"] = $env:COMPUTERNAME
$config["user_name"] = if ($env:USERNAME) { $env:USERNAME } else { $config["user_name"] }
$config["model_directory"] = if ($config["model_directory"]) { $config["model_directory"] } else { "D:\Models" }
$config["knowledge_root"] = if ($config["knowledge_root"]) { $config["knowledge_root"] } else { "knowledge" }
$config["knowledge_inbox"] = if ($config["knowledge_inbox"]) { $config["knowledge_inbox"] } else { "knowledge/inbox" }
$existingExtraRoots = $config["knowledge_extra_roots"]
if ($existingExtraRoots) {
	if ($existingExtraRoots -is [System.Array]) {
		$config["knowledge_extra_roots"] = @($existingExtraRoots)
	} else {
		$config["knowledge_extra_roots"] = @([string]$existingExtraRoots)
	}
} else {
	$config["knowledge_extra_roots"] = @("projects/letter-research")
}
$config["memory_index_path"] = if ($config["memory_index_path"]) { $config["memory_index_path"] } else { "knowledge/memory-index.json" }
$config["memory_database_path"] = if ($config["memory_database_path"]) { $config["memory_database_path"] } else { "knowledge/memory-metadata.db" }
$config["default_mode"] = if ($config["default_mode"]) { $config["default_mode"] } else { "general" }

$config["vscode_executable"] = if ($config["vscode_executable"]) { $config["vscode_executable"] } else { Resolve-CommandPath -Names @("code-insiders", "code-insiders.cmd", "code", "code.cmd") -CandidatePaths @("$env:LOCALAPPDATA\Programs\Microsoft VS Code\bin\code.cmd", "$env:LOCALAPPDATA\Programs\Microsoft VS Code Insiders\bin\code-insiders.cmd", "$env:ProgramFiles\Microsoft VS Code\bin\code.cmd", "$env:ProgramFiles\Microsoft VS Code Insiders\bin\code-insiders.cmd") }
$config["lmstudio_executable"] = if ($config["lmstudio_executable"]) { $config["lmstudio_executable"] } else { Resolve-LmStudioPath }
$config["python_executable"] = if ($config["python_executable"]) { $config["python_executable"] } else { Resolve-PythonPath }
$config["git_executable"] = if ($config["git_executable"]) { $config["git_executable"] } else { (Resolve-CommandPath -Names @("git") -CandidatePaths @("$env:ProgramFiles\Git\cmd\git.exe")) }

$config["git_user_name"] = if ($config["git_user_name"]) { $config["git_user_name"] } else { "" }
$config["git_user_email"] = if ($config["git_user_email"]) { $config["git_user_email"] } else { "" }
$config["github_username"] = if ($config["github_username"]) { $config["github_username"] } else { "" }

$knowledgeRootPath = Join-Path $repoRoot $config["knowledge_root"]
$knowledgeInboxPath = Join-Path $repoRoot $config["knowledge_inbox"]
New-Item -ItemType Directory -Force -Path $knowledgeRootPath | Out-Null
New-Item -ItemType Directory -Force -Path $knowledgeInboxPath | Out-Null

$orderedConfig = [ordered]@{}
foreach ($key in $config.Keys) {
	$orderedConfig[$key] = $config[$key]
}

$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($configPath, ($orderedConfig | ConvertTo-Json -Depth 5), $utf8NoBom)

if (-not $SkipGitConfig -and $config["git_executable"] -and (-not [string]::IsNullOrWhiteSpace($config["git_user_name"])) -and (-not [string]::IsNullOrWhiteSpace($config["git_user_email"]))) {
	Write-Status "Applying Git identity from config.local.json"
	& $config["git_executable"] config --global user.name $config["git_user_name"] | Out-Null
	& $config["git_executable"] config --global user.email $config["git_user_email"] | Out-Null
	& $config["git_executable"] config --global init.defaultBranch main | Out-Null
}

Write-Status "Bootstrap complete."
Write-Status "Repository: $repoRoot"
Write-Status "VS Code: $($config["vscode_executable"])"
Write-Status "LM Studio: $($config["lmstudio_executable"])"
Write-Status "Python: $($config["python_executable"])"
