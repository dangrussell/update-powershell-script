#region Init & Settings
Set-Location ~

$color1 = "DarkMagenta"
$color2 = "DarkRed"
$color3 = "Red"
$color4 = "Cyan"

$verbose = $true
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
#endregion

#region Opening
Write-Host "[[[UPDATE SCRIPT]]]" -ForegroundColor $color1
Write-Host ""

Write-Host "..." -ForegroundColor $color3
Write-Host ""
#endregion

#region Windows Subsystem for Linux (WSL)
<#
# TODO: Check for wsl installation before using wsl
# TODO: Add list of default/recommend apt packages to install on first run
#>
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
#endregion

#region Chocolatey packages
<#
# TODO: Check for chocolatey installation before using choco
# TODO: Add list of default/recommend choco packages to install on first run
#>

Write-Host "[Upgrade Chocolatey Packages]" -ForegroundColor $color2
Write-Host ""

Write-Host "Upgrading all Chocolatey packages..." -ForegroundColor $color3
# Chocolatey verbosity isn't very useful
# if ($verbose) {
#	Write-Host "choco upgrade all --yes --verbose"
#	choco upgrade all --yes --verbose
#}
#else {
Write-Host "choco upgrade all --yes"
choco upgrade all --yes
#}
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
#endregion

#region Winget packages
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
#endregion

#region PowerShellGet modules
Write-Host "[Update PowerShellGet modules]" -ForegroundColor $color2
Write-Host ""
<#
Write-Host "Updating PowerShellGet modules (this can be very slow)..." -ForegroundColor $color3
if ($verbose) {
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
#endregion

#region Microsoft Store apps
Write-Host "[Update all Microsoft Store apps]" -ForegroundColor $color2
Write-Host ""

Write-Host "Updating all Microsoft Store apps..." -ForegroundColor $color3
Write-Host ""

$namespaceName = "Root\cimv2\mdm\dmmap"
$className = "MDM_EnterpriseModernAppManagement_AppManagement01"
$methodName = "UpdateScanMethod"
if ($verbose) {
	Get-CimInstance -Namespace $namespaceName -ClassName $className -Verbose | Invoke-CimMethod -MethodName $methodName -Verbose
}
else {
	Get-CimInstance -Namespace $namespaceName -ClassName $className | Invoke-CimMethod -MethodName $methodName
}
Write-Host ""

Write-Host "Opening Downloads and Updates in Microsoft Store..." -ForegroundColor $color3
# shell:appsFolder\Microsoft.WindowsStore_8wekyb3d8bbwe!App
Start-Process ms-windows-store://downloadsandupdates
Write-Host ""

Write-Host "Done updating all Microsoft Store apps." -ForegroundColor $color3
Write-Host ""

Write-Host "..." -ForegroundColor $color3
Write-Host ""
#endregion

#region Node Package Manager (npm) packages
<#
# TODO: Check for nodejs installation before using npm
# TODO: Add list of default/recommend npm packages to install on first run
#>

Write-Host "[npm patch-level updates]" -ForegroundColor $color2
Write-Host ""

Write-Host "Installing npm-check-updates..." -ForegroundColor $color3
Write-Host "npm install npm-check-updates --global"
npm install npm-check-updates --global
Write-Host ""

Write-Host "Checking npm global for patch-level updates..." -ForegroundColor $color3
if ($verbose) {
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
#endregion

#region Windows Update and Microsoft Update
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

if ($verbose) {
	Get-WindowsUpdate -MicrosoftUpdate -Install -AcceptAll -Verbose
}
else {
	Get-WindowsUpdate -MicrosoftUpdate -Install -AcceptAll
}
Write-Host ""

Write-Host "Opening Windows Update in Settings..." -ForegroundColor $color3
Start-Process ms-settings:windowsupdate-action
Write-Host ""

Write-Host "Done running Windows Update and Microsoft Update." -ForegroundColor $color3
Write-Host ""

Write-Host "..." -ForegroundColor $color3
Write-Host ""
#endregion

#region Finish & Clean-Up
Write-Host "[Finish & Clean-Up]" -ForegroundColor $color2
Write-Host ""

# Choco Cleaner
Write-Host "Cleaning up chocolatey..." -ForegroundColor $color3
choco-cleaner
Write-Host ""

# Verify NPM cache (does garbage collection)
Write-Host "Cleaning up npm..." -ForegroundColor $color3
npm cache verify
Write-Host ""

# Clean yarn cache
Write-Host "Cleaning up yarn..." -ForegroundColor $color3
yarn cache clean
Write-Host ""

# Clear all local nuget caches
# Write-Host "Cleaning up nuget..." -ForegroundColor $color3
# dotnet nuget locals all --clear
# Write-Host ""

# Write-Host "Refreshing environment variables..." -ForegroundColor $color3
RefreshEnv
Write-Host ""

Write-Host "..." -ForegroundColor $color3
Write-Host ""
#endregion

#region Done
Write-Host "Done!" -ForegroundColor $color1
#endregion
