#region Init
Set-Location ~
#endregion Init

#region Settings
$settingsPath = Join-Path $PSScriptRoot "settings.psd1"
if (-not (Test-Path $settingsPath)) {
	throw "Missing settings file: $settingsPath"
}

$settings = Import-PowerShellDataFile -Path $settingsPath
#endregion Settings

#region Functions
function Watch-Keypress ($sleepSeconds = 10) {

	$timeout = New-TimeSpan -Seconds $sleepSeconds
	$stopWatch = [Diagnostics.Stopwatch]::StartNew()
	$interrupted = $false

	while ($stopWatch.Elapsed -lt $timeout) {
		if ($Host.UI.RawUI.KeyAvailable) {
			$keyPressed = $Host.UI.RawUI.ReadKey("NoEcho, IncludeKeyDown, IncludeKeyUp")
			if ($keyPressed) {
				$interrupted = $true
				break
			}
		}

		Start-Sleep -Milliseconds 50
	}

	return $interrupted
}

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
#endregion Functions

#region Opening
Write-Host "[[[UPDATE SCRIPT]]]" -ForegroundColor $settings.colors.banner
Write-Host ""

Write-Host "..." -ForegroundColor $settings.colors.status
Write-Host ""
#endregion Opening

#region Windows Subsystem for Linux (WSL)
<#
# TODO: Add list of default/recommend apt packages to install on first run
#>
if (($settings.run.all -or $settings.run.WSL) -and (Test-CommandExists wsl)) {
	Write-Host "Press any key to update WSL. (WSL update will be skipped in 10 seconds.)"

	if (Watch-Keypress) {
		Write-Host ""
		Write-Host "Running WSL update."
		Write-Host ""

		Write-Host "[Update, upgrade, and autoremove in WSL]" -ForegroundColor $settings.colors.section
		Write-Host ""

		Write-Host "Updating, upgrading, and autoremoving in WSL..." -ForegroundColor $settings.colors.status
		Write-Host ""

		Write-Host "Updating in WSL..." -ForegroundColor $settings.colors.status
		if ($settings.verbose.all -or $settings.verbose.WSL) {
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
		if ($settings.verbose.all -or $settings.verbose.WSL) {
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
		if ($settings.verbose.all -or $settings.verbose.WSL) {
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
	}
	else {
		Write-Host "Skipping WSL update."
	}

	Write-Host ""

	Write-Host "..." -ForegroundColor $settings.colors.status
	Write-Host ""
}
#endregion Windows Subsystem for Linux (WSL)

#region Chocolatey packages
<#
# TODO: Add list of default/recommended choco packages to install on first run
#>
if (($settings.run.all -or $settings.run.Chocolatey) -and (Test-CommandExists choco)) {
	Write-Host "[Upgrade Chocolatey Packages]" -ForegroundColor $settings.colors.section
	Write-Host ""

	Write-Host "Upgrading all Chocolatey packages..." -ForegroundColor $settings.colors.status
	if ($settings.verbose.all -or $settings.verbose.Chocolatey) {
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
if (($settings.run.all -or $settings.run.Winget) -and (Test-CommandExists winget)) {
	Write-Host "[Upgrade Winget Packages]" -ForegroundColor $settings.colors.section
	Write-Host ""

	Write-Host "Upgrading all Winget packages..." -ForegroundColor $settings.colors.status
	if ($settings.verbose.all -or $settings.verbose.Winget) {
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
if (($settings.run.all -or $settings.run.PowerShellGet) -and (Test-CommandExists Update-Module)) {
	Write-Host "[Update PowerShellGet modules]" -ForegroundColor $settings.colors.section
	Write-Host ""

	Write-Host "Updating PowerShellGet modules (this can be very slow)..." -ForegroundColor $settings.colors.status
	if ($settings.verbose.all -or $settings.verbose.PowerShellGet) {
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
if ($settings.run.all -or $settings.run.MSStore) {
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
	if ($settings.verbose.all -or $settings.verbose.MSStore) {
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
if (($settings.run.all -or $settings.run.WindowsUpdate) -and (Test-CommandExists Get-WindowsUpdate)) {
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

	if ($settings.verbose.all -or $settings.verbose.WindowsUpdate) {
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
if (($settings.run.all -or $settings.run.ncu) -and (Test-CommandExists node -and Test-CommandExists npm)) {
	<#
	# TODO: Add list of default/recommend npm packages to install on first run
	#>

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
	if ($settings.verbose.all -or $settings.verbose.ncu) {
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
if (($settings.run.all -or $settings.run.ChocoCleaner) -and (Test-CommandExists choco-cleaner)) {
	Write-Host "Cleaning up chocolatey..." -ForegroundColor $settings.colors.status
	choco-cleaner
	Write-Host ""
}

# Verify NPM cache (does garbage collection)
if (($settings.run.all -or $settings.run.npmcache) -and (Test-CommandExists npm)) {
	Write-Host "Cleaning up npm..." -ForegroundColor $settings.colors.status
	if ($settings.verbose.all -or $settings.verbose.npmcache) {
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
if (($settings.run.all -or $settings.run.yarncache) -and (Test-CommandExists yarn)) {
	Write-Host "Cleaning up yarn..." -ForegroundColor $settings.colors.status
	if ($settings.verbose.all -or $settings.verbose.yarncache) {
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
if (($settings.run.all -or $settings.run.dotnetcache) -and (Test-CommandExists dotnet)) {
	Write-Host "Cleaning up nuget..." -ForegroundColor $settings.colors.status
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
