#Requires -RunAsAdministrator

#region Init
Set-Location ~
#endregion Init

#region Settings
$settingsPath = Join-Path $PSScriptRoot "settings.psd1"
$defaultSettings = @{
	colors  = @{
		banner    = "DarkMagenta";
		section   = "DarkRed";
		status    = "Red";
		highlight = "Cyan";
	};
	verbose = @{
		all = $false;
	};
	run     = @{
		all = $true;
	};
}
$settings = $defaultSettings.Clone()

if (Test-Path $settingsPath) {
	$customSettings = Import-PowerShellDataFile -Path $settingsPath

	if ($customSettings.colors -is [hashtable]) {
		foreach ($key in $customSettings.colors.Keys) {
			$settings.colors[$key] = $customSettings.colors[$key]
		}
	}

	if ($customSettings.verbose -is [hashtable]) {
		foreach ($key in $customSettings.verbose.Keys) {
			$settings.verbose[$key] = $customSettings.verbose[$key]
		}
	}

	if ($customSettings.run -is [hashtable]) {
		foreach ($key in $customSettings.run.Keys) {
			$settings.run[$key] = $customSettings.run[$key]
		}
	}
}
else {
	Write-Host "Settings file not found. Using built-in defaults." -ForegroundColor Yellow
}
#endregion Settings

#region Functions
function Test-CommandExists {
	<#
	.NOTES
		Adapted from https://devblogs.microsoft.com/scripting/use-a-powershell-function-to-see-if-a-command-exists/
	#>

	param (
		$command,
		[switch]$Silent
	)

	$oldPreference = $ErrorActionPreference

	$ErrorActionPreference = "stop"

	try {
		if (Get-Command $command) {
			return $true
		}
		if (-not $Silent) {
			Write-Host "Command '$command' does not exist."
		}
		return $false
	}
	catch {
		if (-not $Silent) {
			Write-Host "Checking for command '$command' failed."
		}
		return $false
	}
	finally {
		$ErrorActionPreference = $oldPreference
	}
}

function Test-RunEnabled {
	param (
		[string]$Section
	)

	if ($settings.run.all) {
		return $true
	}

	if (($settings.run -is [hashtable]) -and $settings.run.ContainsKey($Section)) {
		return [bool]$settings.run[$Section]
	}

	return $false
}

function Test-VerboseEnabled {
	param (
		[string]$Section
	)

	if ($settings.verbose.all) {
		return $true
	}

	if (($settings.verbose -is [hashtable]) -and $settings.verbose.ContainsKey($Section)) {
		return [bool]$settings.verbose[$Section]
	}

	return $false
}
#endregion Functions

#region Opening
Write-Host "[[[UPDATE SCRIPT]]]" -ForegroundColor $settings.colors.banner
Write-Host ""

Write-Host "..." -ForegroundColor $settings.colors.status
Write-Host ""
#endregion Opening

#region Windows Subsystem for Linux (WSL)
if ((Test-RunEnabled "WSL") -and (Test-CommandExists wsl)) {
	Write-Host "[Update, upgrade, and autoremove in WSL]" -ForegroundColor $settings.colors.section
	Write-Host ""

	Write-Host "Updating, upgrading, and autoremoving in WSL..." -ForegroundColor $settings.colors.status
	Write-Host ""

	Write-Host "Updating in WSL..." -ForegroundColor $settings.colors.status
	if (Test-VerboseEnabled "WSL") {
		Write-Host "wsl -u root -- apt update"
		wsl -u root -- apt update
	}
	else {
		Write-Host "wsl -u root -- apt -q update"
		wsl -u root -- apt -q update
	}
	Write-Host "Done updating in WSL." -ForegroundColor $settings.colors.status
	Write-Host ""

	Write-Host "Upgrading in WSL..." -ForegroundColor $settings.colors.status
	if (Test-VerboseEnabled "WSL") {
		Write-Host "wsl -u root -- apt upgrade -y"
		wsl -u root -- apt upgrade -y
	}
	else {
		Write-Host "wsl -u root -- apt -q upgrade -y"
		wsl -u root -- apt -q upgrade -y
	}
	Write-Host "Done upgrading in WSL." -ForegroundColor $settings.colors.status
	Write-Host ""

	Write-Host "Autoremoving in WSL..." -ForegroundColor $settings.colors.status
	if (Test-VerboseEnabled "WSL") {
		Write-Host "wsl -u root -- apt autoremove -y"
		wsl -u root -- apt autoremove -y
	}
	else {
		Write-Host "wsl -u root -- apt -q autoremove -y"
		wsl -u root -- apt -q autoremove -y
	}
	Write-Host "Done autoremoving in WSL." -ForegroundColor $settings.colors.status
	Write-Host ""

	Write-Host "Done with WSL." -ForegroundColor $settings.colors.status

	Write-Host ""

	Write-Host "..." -ForegroundColor $settings.colors.status
	Write-Host ""
}
#endregion Windows Subsystem for Linux (WSL)

#region Chocolatey packages
if ((Test-RunEnabled "Chocolatey") -and (Test-CommandExists choco)) {
	Write-Host "[Upgrade Chocolatey Packages]" -ForegroundColor $settings.colors.section
	Write-Host ""

	Write-Host "Upgrading all Chocolatey packages..." -ForegroundColor $settings.colors.status
	if (Test-VerboseEnabled "Chocolatey") {
		Write-Host "choco upgrade all --yes --exit-when-reboot-detected --verbose"
		choco upgrade all --yes --exit-when-reboot-detected --verbose
	}
	else {
		Write-Host "choco upgrade all --yes --exit-when-reboot-detected"
		choco upgrade all --exit-when-reboot-detected --yes
	}
	Write-Host ""

	Write-Host "Done upgrading all Chocolatey packages." -ForegroundColor $settings.colors.status
	Write-Host ""
	Write-Host "If you encountered any 'already referencing a newer version' errors, try running this:"
	Write-Host "choco upgrade all --yes --ignore-dependencies" -ForegroundColor $settings.colors.highlight
	Write-Host ""
	Write-Host "Or, try to solve the issue by looking in C:\ProgramData\chocolatey\lib\ to verify the referenced package has only one nupkg folder (without a version number in the name of the nupkg). If you find any others, delete them."
	Write-Host "Reference: https://github.com/chocolatey/choco/issues/227#issuecomment-1107213230"
	Write-Host ""

	Write-Host "..." -ForegroundColor $settings.colors.status
	Write-Host ""
}
#endregion Chocolatey packages

#region Winget packages
if ((Test-RunEnabled "Winget") -and (Test-CommandExists winget)) {
	Write-Host "[Upgrade Winget Packages]" -ForegroundColor $settings.colors.section
	Write-Host ""

	Write-Host "Upgrading all Winget packages..." -ForegroundColor $settings.colors.status
	if (Test-VerboseEnabled "Winget") {
		Write-Host "winget upgrade --all --accept-package-agreements --accept-source-agreements --verbose-logs"
		winget upgrade --all --accept-package-agreements --accept-source-agreements --verbose-logs
	}
	else {
		Write-Host "winget upgrade --all --accept-package-agreements --accept-source-agreements"
		winget upgrade --all --accept-package-agreements --accept-source-agreements
	}
	Write-Host ""

	Write-Host "Done upgrading all Winget packages." -ForegroundColor $settings.colors.status
	Write-Host ""

	Write-Host "..." -ForegroundColor $settings.colors.status
	Write-Host ""
}
#endregion Winget packages

#region PowerShellGet modules
if ((Test-RunEnabled "PowerShellGet") -and (Test-CommandExists Update-Module)) {
	Write-Host "[Update PowerShellGet modules]" -ForegroundColor $settings.colors.section
	Write-Host ""

	Write-Host "Updating PowerShellGet modules (this can be very slow)..." -ForegroundColor $settings.colors.status
	if (Test-VerboseEnabled "PowerShellGet") {
		Update-Module -Verbose
	}
	else {
		Update-Module
	}
	Write-Host ""

	# Update-Help
	# Write-Host ""

	Write-Host "Done updating PowerShellGet modules." -ForegroundColor $settings.colors.status
	Write-Host ""

	Write-Host "..." -ForegroundColor $settings.colors.status
	Write-Host ""
}
#endregion PowerShellGet modules

#region Microsoft Store apps
if (Test-RunEnabled "MSStore") {
	Write-Host "[Update Microsoft Store apps]" -ForegroundColor $settings.colors.section
	Write-Host ""

	# Instructs the Windows Store service to scan for, download, and install updates for all
	# installed Store apps. This runs asynchronously in the background — the Store service
	# handles the actual work after this call returns. The Downloads page opened below lets
	# you see what's downloading/installing in real time.
	Write-Host "Instructing the Store service to scan, download, and install all app updates..." -ForegroundColor $settings.colors.status
	$storeScanResult = Get-CimInstance -Namespace "Root\cimv2\mdm\dmmap" `
		-ClassName "MDM_EnterpriseModernAppManagement_AppManagement01" |
	Invoke-CimMethod -MethodName "UpdateScanMethod"
	if ($storeScanResult.ReturnValue -eq 0) {
		Write-Host "Store update cycle started successfully. Updates are downloading/installing in the background." -ForegroundColor $settings.colors.status
	}
	else {
		Write-Host "Store update cycle returned unexpected code: $($storeScanResult.ReturnValue)" -ForegroundColor $settings.colors.status
	}
	if (Test-VerboseEnabled "MSStore") {
		Write-Host "ReturnValue: $($storeScanResult.ReturnValue)" -ForegroundColor $settings.colors.status
	}
	Write-Host ""

	Write-Host "Opening Microsoft Store Downloads page to monitor progress..." -ForegroundColor $settings.colors.status
	Start-Process ms-windows-store://downloadsandupdates
	Write-Host ""

	Write-Host "Store updates are running in the background." -ForegroundColor $settings.colors.status
	Write-Host ""

	Write-Host "..." -ForegroundColor $settings.colors.status
	Write-Host ""
}
#endregion Microsoft Store apps

#region Windows Update and Microsoft Update
if ((Test-RunEnabled "WindowsUpdate") -and (Test-CommandExists Get-WindowsUpdate)) {
	Write-Host "[Windows Update and Microsoft Update]" -ForegroundColor $settings.colors.section
	Write-Host ""

	Write-Host "Running Windows Update and Microsoft Update..." -ForegroundColor $settings.colors.status
	Write-Host ""

	<#
	# Requires PowerShell >=5
	$PSVersionTable.PSVersion

	# Only needed on first run
	# Install-Module PSWindowsUpdate
	# Write-Host ""

	Get-Command -module PSWindowsUpdate
	Write-Host ""

	# Add-WUServiceManager -ServiceID 7971f918-a847-4430-9279-4a52d1efe18d
	# Write-Host ""
	#>

	if (Test-VerboseEnabled "WindowsUpdate") {
		Get-WindowsUpdate -MicrosoftUpdate -Install -AcceptAll -Verbose
	}
	else {
		Get-WindowsUpdate -MicrosoftUpdate -Install -AcceptAll
	}
	Write-Host ""

	Write-Host "Opening Windows Update in Settings..." -ForegroundColor $settings.colors.status
	Start-Process ms-settings:windowsupdate
	Write-Host ""

	Write-Host "Done running Windows Update and Microsoft Update." -ForegroundColor $settings.colors.status
	Write-Host ""

	Write-Host "..." -ForegroundColor $settings.colors.status
	Write-Host ""
}
#endregion Windows Update and Microsoft Update

#region Node Package Manager (npm) packages
if ((Test-RunEnabled "ncu") -and (Test-CommandExists node -and Test-CommandExists npm)) {
	Write-Host "[npm patch-level updates]" -ForegroundColor $settings.colors.section
	Write-Host ""

	if (Test-CommandExists ncu) {
		Write-Host "npm-check-updates is already installed." -ForegroundColor $settings.colors.status
		Write-Host ""
	}
	else {
		# Install npm-check-updates
		Write-Host "Installing npm-check-updates..." -ForegroundColor $settings.colors.status
		Write-Host "npm install npm-check-updates --global"
		npm install npm-check-updates --global
		Write-Host ""
	}

	Write-Host "Checking npm global for patch-level updates..." -ForegroundColor $settings.colors.status
	if (Test-VerboseEnabled "ncu") {
		Write-Host "ncu --global --target patch --loglevel verbose"
		ncu --global --target patch --loglevel verbose
	}
	else {
		Write-Host "ncu --global --target patch"
		ncu --global --target patch
	}
	Write-Host ""

	Write-Host "Done checking npm global for patch-level updates." -ForegroundColor $settings.colors.status
	Write-Host ""

	Write-Host "..." -ForegroundColor $settings.colors.status
	Write-Host ""
}
#endregion Node Package Manager (npm) packages

#region Finish & Clean-Up
Write-Host "[Finish & Clean-Up]" -ForegroundColor $settings.colors.section
Write-Host ""

# Choco Cleaner
if ((Test-RunEnabled "ChocoCleaner") -and (Test-CommandExists choco-cleaner)) {
	Write-Host "Cleaning up chocolatey..." -ForegroundColor $settings.colors.status
	choco-cleaner
	Write-Host ""
}

# Verify NPM cache (does garbage collection)
if ((Test-RunEnabled "npmcache") -and (Test-CommandExists npm)) {
	Write-Host "Cleaning up npm..." -ForegroundColor $settings.colors.status
	if (Test-VerboseEnabled "npmcache") {
		Write-Host "npm cache verify --verbose"
		npm cache verify --verbose
	}
	else {
		Write-Host "npm cache verify"
		npm cache verify
	}
	Write-Host ""
}

# Clean yarn cache
if ((Test-RunEnabled "yarncache") -and (Test-CommandExists yarn)) {
	Write-Host "Cleaning up yarn..." -ForegroundColor $settings.colors.status
	if (Test-VerboseEnabled "yarncache") {
		Write-Host "yarn cache clean --verbose"
		yarn cache clean --verbose
	}
	else {
		Write-Host "yarn cache clean"
		yarn cache clean
	}
	Write-Host ""
}

# Clear all local nuget caches
if ((Test-RunEnabled "dotnetcache") -and (Test-CommandExists dotnet)) {
	Write-Host "Cleaning up nuget..." -ForegroundColor $settings.colors.status
	Write-Host "dotnet nuget locals all --clear"
	dotnet nuget locals all --clear
	Write-Host ""
}

$chocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path $chocolateyProfile) {
	Write-Host "Refreshing environment variables..." -ForegroundColor $settings.colors.status
	Import-Module $chocolateyProfile
	if (Test-CommandExists refreshenv -Silent) {
		refreshenv # alias for Update-SessionEnvironment
	}
	elseif (Test-CommandExists Update-SessionEnvironment -Silent) {
		Update-SessionEnvironment
	}
	Write-Host ""
}

Write-Host "..." -ForegroundColor $settings.colors.status
Write-Host ""
#endregion Finish & Clean-Up

#region Done
Write-Host "Done!" -ForegroundColor $settings.colors.banner

if (Test-Path $PROFILE) {
	. $PROFILE
}
#endregion Done
