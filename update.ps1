#region Init & Settings
Set-Location ~

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
	wsl = $false; # Run Windows Subsystem for Linux (WSL) update
}
#endregion

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
	}

	return $interrupted
}

function Test-CommandExists {
	<#
	.NOTES
		Adapted from https://devblogs.microsoft.com/scripting/use-a-powershell-function-to-see-if-a-command-exists/
	#>

	param ($command)

	$oldPreference = $ErrorActionPreference

	$ErrorActionPreference = "stop"

	try {
		if (Get-Command $command) {
			return $true
		}
		Write-Host "Command '$command' does not exist."
	}
	catch {
		Write-Host "Checking for command '$command' failed."
		return $false
	}
	finally {
		$ErrorActionPreference = $oldPreference
	}
}
#endregion

#region Opening
Write-Host "[[[UPDATE SCRIPT]]]" -ForegroundColor $color1
Write-Host ""

Write-Host "..." -ForegroundColor $color3
Write-Host ""
#endregion

#region Windows Subsystem for Linux (WSL)
<#
# TODO: Add list of default/recommend apt packages to install on first run
#>
if ($run.wsl -and (Test-CommandExists wsl)) {
	Write-Host "Press any key to update WSL. (WSL update will be skipped in 10 seconds.)"

	if (Watch-Keypress) {
		Write-Host ""
		Write-Host "Running WSL update."
		Write-Host ""

		$wslName = "WSL Ubuntu"
		$wslUser = wsl whoami
		Write-Host "[Update, upgrade, and autoremove in $wslName]" -ForegroundColor $color2
		$sudopw = Read-Host -assecurestring "[sudo] password for $wslUser (blank to skip)"
		Write-Host ""

		if ($sudopw.Length -ne 0) {
			Write-Host "Updating, upgrading, and autoremoving in $wslName..." -ForegroundColor $color3
			Write-Host ""

			$sudopw = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($sudopw))

			wsl export HISTIGNORE='*sudo -S*'

			Write-Host "Updating in $wslName..." -ForegroundColor $color3
			wsl echo "$sudopw" | wsl sudo -S -k apt update
			Write-Host "Done updating in $wslName." -ForegroundColor $color3
			Write-Host ""

			Write-Host "Upgrading in $wslName..." -ForegroundColor $color3
			wsl echo "$sudopw" | wsl sudo -S -k apt upgrade
			Write-Host "Done upgrading in $wslName." -ForegroundColor $color3
			Write-Host ""

			Write-Host "Autoremoving in $wslName..." -ForegroundColor $color3
			wsl echo "$sudopw" | wsl sudo -S -k apt autoremove
			Write-Host "Done autoremoving in $wslName." -ForegroundColor $color3
			Write-Host ""

			Write-Host "Done with $wslName." -ForegroundColor $color3
		}
		else {
			Write-Host "(skipped)" -ForegroundColor $color3
		}
	}
	else {
		Write-Host "Skipping WSL update."
	}

	Write-Host ""

	Write-Host "..." -ForegroundColor $color3
	Write-Host ""
}
#endregion

#region Chocolatey packages
<#
# TODO: Add list of default/recommended choco packages to install on first run
#>
if (Test-CommandExists choco) {
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
#endregion

#region Winget packages
if (Test-CommandExists winget) {
	Write-Host "[Upgrade Winget Packages]" -ForegroundColor $color2
	Write-Host ""
	<#
	Write-Host "Upgrading all Winget packages..." -ForegroundColor $color3
	winget upgrade --all --accept-package-agreements --accept-source-agreements
	Write-Host ""

	Write-Host "Done upgrading all Winget packages." -ForegroundColor $color3
	Write-Host ""
	#>
	Write-Host "Disabled. Command to run manually, if desired:" -ForegroundColor $color3
	Write-Host "winget upgrade --all --accept-package-agreements --accept-source-agreements" -ForegroundColor $color4
	Write-Host ""

	Write-Host "..." -ForegroundColor $color3
	Write-Host ""
}
#endregion

#region PowerShellGet modules
if (Test-CommandExists Update-Module) {
	Write-Host "[Update PowerShellGet modules]" -ForegroundColor $color2
	Write-Host ""
	<#
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
	#>
	Write-Host "Disabled. Command to run manually, if desired:" -ForegroundColor $color3
	Write-Host "Update-Module" -ForegroundColor $color4
	Write-Host ""

	Write-Host "..." -ForegroundColor $color3
	Write-Host ""
}
#endregion

#region Microsoft Store apps
if (Test-CommandExists Get-CimInstance -and Test-CommandExists Invoke-CimMethod -and Test-CommandExists Start-Process) {
	Write-Host "[Update all Microsoft Store apps]" -ForegroundColor $color2
	Write-Host ""

	if (Test-CommandExists Get-CimInstance -and Test-CommandExists Invoke-CimMethod) {
		Write-Host "Updating all Microsoft Store apps..." -ForegroundColor $color3
		Write-Host ""

		$namespaceName = "Root\cimv2\mdm\dmmap"
		$className = "MDM_EnterpriseModernAppManagement_AppManagement01"
		$methodName = "UpdateScanMethod"
		if ($verbose.all -or $verbose.MSStore) {
			Get-CimInstance -Namespace $namespaceName -ClassName $className -Verbose | Invoke-CimMethod -MethodName $methodName -Verbose
		}
		else {
			Get-CimInstance -Namespace $namespaceName -ClassName $className | Invoke-CimMethod -MethodName $methodName
		}
		Write-Host ""
	}

	if (Test-CommandExists Start-Process) {
		Write-Host "Opening Downloads and Updates in Microsoft Store..." -ForegroundColor $color3
		# shell:appsFolder\Microsoft.WindowsStore_8wekyb3d8bbwe!App
		Start-Process ms-windows-store://downloadsandupdates
		Write-Host ""
	}

	Write-Host "Done updating all Microsoft Store apps." -ForegroundColor $color3
	Write-Host ""

	Write-Host "..." -ForegroundColor $color3
	Write-Host ""
}
#endregion

#region Node Package Manager (npm) packages
if (Test-CommandExists node -and Test-CommandExists npm) {
	<#
	# TODO: Add list of default/recommend npm packages to install on first run
	#>

	Write-Host "[npm patch-level updates]" -ForegroundColor $color2
	Write-Host ""

	Write-Host "Installing npm-check-updates..." -ForegroundColor $color3
	Write-Host "npm install npm-check-updates --global"
	npm install npm-check-updates --global
	Write-Host ""

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
#endregion

#region Windows Update and Microsoft Update
if (Test-CommandExists Get-WindowsUpdate -and Test-CommandExists Start-Process) {
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
#endregion

#region Finish & Clean-Up
Write-Host "[Finish & Clean-Up]" -ForegroundColor $color2
Write-Host ""

# Choco Cleaner
if (Test-CommandExists choco-cleaner) {
	Write-Host "Cleaning up chocolatey..." -ForegroundColor $color3
	choco-cleaner
	Write-Host ""
}

# Verify NPM cache (does garbage collection)
# if (Test-CommandExists npm) {
# 	Write-Host "Cleaning up npm..." -ForegroundColor $color3
# 	if ($verbose.all -or $verbose.npmcache) {
# 		Write-Host "npm cache verify --verbose"
# 		npm cache verify --verbose
# 	}
# 	else {
# 		Write-Host "npm cache verify"
# 		npm cache verify
# 	}
# 	Write-Host ""
# }

# Clean yarn cache
# if (Test-CommandExists yarn) {
# 	Write-Host "Cleaning up yarn..." -ForegroundColor $color3
# 	if ($verbose.all -or $verbose.yarncache) {
# 		Write-Host "yarn cache clean --verbose"
# 		yarn cache clean --verbose
# 	}
# 	else {
# 		Write-Host "yarn cache clean"
# 		yarn cache clean
# 	}
# 	yarn cache clean
# 	Write-Host ""
# }

# Clear all local nuget caches
# if (Test-CommandExists dotnet) {
# 	Write-Host "Cleaning up nuget..." -ForegroundColor $color3
# 	dotnet nuget locals all --clear
# 	Write-Host ""
# }

if (Test-CommandExists RefreshEnv) {
	# Write-Host "Refreshing environment variables..." -ForegroundColor $color3
	RefreshEnv
	Write-Host ""
}

Write-Host "..." -ForegroundColor $color3
Write-Host ""
#endregion

#region Done
Write-Host "Done!" -ForegroundColor $color1
#endregion
