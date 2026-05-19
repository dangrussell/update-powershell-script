#region Init
Set-Location ~
#endregion Init

#region Settings
<#
# TODO: Use a gitignored settings file instead of hardcoding these values
#>
$color1 = "DarkMagenta"
$color2 = "DarkRed"
$color3 = "Red"
$color4 = "Cyan"

$verbose = @{
	all           = $false; # Set to `$true` to turn on verbosity for all sections
	# Sections that use verbosity
	WSL           = $true; #TODO: Not yet implemented
	Chocolatey    = $false; # Chocolatey verbosity isn't very useful
	Winget        = $true; #TODO: Not yet implemented
	PowerShellGet = $true;
	MSStore       = $true;
	ncu           = $false; # ncu verbosity isn't very useful
	WindowsUpdate = $true;
	npmcache      = $true;
	yarncache     = $false
}

$run = @{
	WSL           = $true; # Run Windows Subsystem for Linux (WSL) update
	Chocolatey    = $true;
	Winget        = $false;
	PowerShellGet = $false;
	MSStore       = $true;
	ncu           = $true;
	WindowsUpdate = $true;
	ChocoCleaner  = $true;
	npmcache      = $false;
	yarncache     = $false;
	dotnetcache   = $false;
}
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
Write-Host "[[[UPDATE SCRIPT]]]" -ForegroundColor $color1
Write-Host ""

Write-Host "..." -ForegroundColor $color3
Write-Host ""
#endregion Opening

#region Windows Subsystem for Linux (WSL)
<#
# TODO: Add list of default/recommend apt packages to install on first run
#>
if ($run.WSL -and (Test-CommandExists wsl)) {
	Write-Host "Press any key to update WSL. (WSL update will be skipped in 10 seconds.)"

	if (Watch-Keypress) {
		Write-Host ""
		Write-Host "Running WSL update."
		Write-Host ""

		Write-Host "[Update, upgrade, and autoremove in WSL]" -ForegroundColor $color2
		Write-Host ""

		Write-Host "Updating, upgrading, and autoremoving in WSL..." -ForegroundColor $color3
		Write-Host ""

		Write-Host "Updating in WSL..." -ForegroundColor $color3
		wsl -u root -- apt update
		Write-Host "Done updating in WSL." -ForegroundColor $color3
		Write-Host ""

		Write-Host "Upgrading in WSL..." -ForegroundColor $color3
		wsl -u root -- apt upgrade -y
		Write-Host "Done upgrading in WSL." -ForegroundColor $color3
		Write-Host ""

		Write-Host "Autoremoving in WSL..." -ForegroundColor $color3
		wsl -u root -- apt autoremove -y
		Write-Host "Done autoremoving in WSL." -ForegroundColor $color3
		Write-Host ""

		Write-Host "Done with WSL." -ForegroundColor $color3
	}
	else {
		Write-Host "Skipping WSL update."
	}

	Write-Host ""

	Write-Host "..." -ForegroundColor $color3
	Write-Host ""
}
#endregion Windows Subsystem for Linux (WSL)

#region Chocolatey packages
<#
# TODO: Add list of default/recommended choco packages to install on first run
#>
if ($run.Chocolatey -and (Test-CommandExists choco)) {
	Write-Host "[Upgrade Chocolatey Packages]" -ForegroundColor $color2
	Write-Host ""

	Write-Host "Upgrading all Chocolatey packages..." -ForegroundColor $color3
	if ($verbose.all -or $verbose.Chocolatey) {
		Write-Host "choco upgrade all --yes --exit-when-reboot-detected --verbose"
		choco upgrade all --yes --exit-when-reboot-detected --verbose
	}
	else {
		Write-Host "choco upgrade all --yes --exit-when-reboot-detected"
		choco upgrade all --exit-when-reboot-detected --yes
	}
	Write-Host ""

	Write-Host "Done upgrading all Chocolatey packages." -ForegroundColor $color3
	Write-Host ""
	Write-Host "If you encountered any 'already referencing a newer version' errors, try running this:"
	Write-Host "choco upgrade all --yes --ignore-dependencies" -ForegroundColor $color4
	Write-Host ""
	Write-Host "Or, try to solve the issue by looking in C:\ProgramData\chocolatey\lib\ to verify the referenced package has only one nupkg folder (without a version number in the name of the nupkg). If you find any others, delete them."
	Write-Host "Reference: https://github.com/chocolatey/choco/issues/227#issuecomment-1107213230"
	Write-Host ""

	Write-Host "..." -ForegroundColor $color3
	Write-Host ""
}
#endregion Chocolatey packages

#region Winget packages
if ($run.Winget -and (Test-CommandExists winget)) {
	Write-Host "[Upgrade Winget Packages]" -ForegroundColor $color2
	Write-Host ""

	Write-Host "Upgrading all Winget packages..." -ForegroundColor $color3
	winget upgrade --all --accept-package-agreements --accept-source-agreements
	Write-Host ""

	Write-Host "Done upgrading all Winget packages." -ForegroundColor $color3
	Write-Host ""

	Write-Host "..." -ForegroundColor $color3
	Write-Host ""
}
#endregion Winget packages

#region PowerShellGet modules
if ($run.PowerShellGet -and (Test-CommandExists Update-Module)) {
	Write-Host "[Update PowerShellGet modules]" -ForegroundColor $color2
	Write-Host ""

	Write-Host "Updating PowerShellGet modules (this can be very slow)..." -ForegroundColor $color3
	if ($verbose.all -or $verbose.PowerShellGet) {
		Update-Module -Verbose
	}
	else {
		Update-Module
	}
	Write-Host ""

	# Update-Help
	# Write-Host ""

	Write-Host "Done updating PowerShellGet modules." -ForegroundColor $color3
	Write-Host ""

	Write-Host "..." -ForegroundColor $color3
	Write-Host ""
}
#endregion PowerShellGet modules

#region Microsoft Store apps
if ($run.MSStore) {
	Write-Host "[Update Microsoft Store apps]" -ForegroundColor $color2
	Write-Host ""

	# Instructs the Windows Store service to scan for, download, and install updates for all
	# installed Store apps. This runs asynchronously in the background — the Store service
	# handles the actual work after this call returns. The Downloads page opened below lets
	# you see what's downloading/installing in real time.
	Write-Host "Instructing the Store service to scan, download, and install all app updates..." -ForegroundColor $color3
	$storeScanResult = Get-CimInstance -Namespace "Root\cimv2\mdm\dmmap" `
		-ClassName "MDM_EnterpriseModernAppManagement_AppManagement01" |
	Invoke-CimMethod -MethodName "UpdateScanMethod"
	if ($storeScanResult.ReturnValue -eq 0) {
		Write-Host "Store update cycle started successfully. Updates are downloading/installing in the background." -ForegroundColor $color3
	}
	else {
		Write-Host "Store update cycle returned unexpected code: $($storeScanResult.ReturnValue)" -ForegroundColor $color3
	}
	if ($verbose.all -or $verbose.MSStore) {
		Write-Host "ReturnValue: $($storeScanResult.ReturnValue)" -ForegroundColor $color3
	}
	Write-Host ""

	Write-Host "Opening Microsoft Store Downloads page to monitor progress..." -ForegroundColor $color3
	Start-Process ms-windows-store://downloadsandupdates
	Write-Host ""

	Write-Host "Store updates are running in the background." -ForegroundColor $color3
	Write-Host ""

	Write-Host "..." -ForegroundColor $color3
	Write-Host ""
}
#endregion Microsoft Store apps

#region Windows Update and Microsoft Update
if ($run.WindowsUpdate -and (Test-CommandExists Get-WindowsUpdate)) {
	Write-Host "[Windows Update and Microsoft Update]" -ForegroundColor $color2
	Write-Host ""

	Write-Host "Running Windows Update and Microsoft Update..." -ForegroundColor $color3
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

	if ($verbose.all -or $verbose.WindowsUpdate) {
		Get-WindowsUpdate -MicrosoftUpdate -Install -AcceptAll -Verbose
	}
	else {
		Get-WindowsUpdate -MicrosoftUpdate -Install -AcceptAll
	}
	Write-Host ""

	Write-Host "Opening Windows Update in Settings..." -ForegroundColor $color3
	Start-Process ms-settings:windowsupdate
	Write-Host ""

	Write-Host "Done running Windows Update and Microsoft Update." -ForegroundColor $color3
	Write-Host ""

	Write-Host "..." -ForegroundColor $color3
	Write-Host ""
}
#endregion Windows Update and Microsoft Update

#region Node Package Manager (npm) packages
if ($run.ncu -and (Test-CommandExists node -and Test-CommandExists npm)) {
	<#
	# TODO: Add list of default/recommend npm packages to install on first run
	#>

	Write-Host "[npm patch-level updates]" -ForegroundColor $color2
	Write-Host ""

	if (Test-CommandExists ncu) {
		Write-Host "npm-check-updates is already installed." -ForegroundColor $color3
		Write-Host ""
	}
	else {
		# Install npm-check-updates
		Write-Host "Installing npm-check-updates..." -ForegroundColor $color3
		Write-Host "npm install npm-check-updates --global"
		npm install npm-check-updates --global
		Write-Host ""
	}

	Write-Host "Checking npm global for patch-level updates..." -ForegroundColor $color3
	if ($verbose.all -or $verbose.ncu) {
		Write-Host "ncu --global --target patch --loglevel verbose"
		ncu --global --target patch --loglevel verbose
	}
	else {
		Write-Host "ncu --global --target patch"
		ncu --global --target patch
	}
	Write-Host ""

	Write-Host "Done checking npm global for patch-level updates." -ForegroundColor $color3
	Write-Host ""

	Write-Host "..." -ForegroundColor $color3
	Write-Host ""
}
#endregion Node Package Manager (npm) packages

#region Finish & Clean-Up
Write-Host "[Finish & Clean-Up]" -ForegroundColor $color2
Write-Host ""

# Choco Cleaner
if ($run.ChocoCleaner -and (Test-CommandExists choco-cleaner)) {
	Write-Host "Cleaning up chocolatey..." -ForegroundColor $color3
	choco-cleaner
	Write-Host ""
}

# Verify NPM cache (does garbage collection)
if ($run.npmcache -and (Test-CommandExists npm)) {
	Write-Host "Cleaning up npm..." -ForegroundColor $color3
	if ($verbose.all -or $verbose.npmcache) {
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
if ($run.yarncache -and (Test-CommandExists yarn)) {
	Write-Host "Cleaning up yarn..." -ForegroundColor $color3
	if ($verbose.all -or $verbose.yarncache) {
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
if ($run.dotnetcache -and (Test-CommandExists dotnet)) {
	Write-Host "Cleaning up nuget..." -ForegroundColor $color3
	dotnet nuget locals all --clear
	Write-Host ""
}

$chocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path $chocolateyProfile) {
	Write-Host "Refreshing environment variables..." -ForegroundColor $color3
	Import-Module $chocolateyProfile
	if (Test-CommandExists refreshenv -Silent) {
		refreshenv # alias for Update-SessionEnvironment
	}
	elseif (Test-CommandExists Update-SessionEnvironment -Silent) {
		Update-SessionEnvironment
	}
	Write-Host ""
}

Write-Host "..." -ForegroundColor $color3
Write-Host ""
#endregion Finish & Clean-Up

#region Done
Write-Host "Done!" -ForegroundColor $color1

if (Test-Path $PROFILE) {
	. $PROFILE
}
#endregion Done
