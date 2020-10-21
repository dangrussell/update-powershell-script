$color1 = "DarkMagenta"
$color2 = "DarkRed"
$color3 = "Red"

Write-Host "[[[UPDATE SCRIPT]]]" -ForegroundColor $color1
Write-Host ""

Write-Host "..." -ForegroundColor $color3
Write-Host ""

#

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
} else {
	Write-Host "(skipped)" -ForegroundColor $color3
}
Write-Host ""

Write-Host "..." -ForegroundColor $color3
Write-Host ""

#

Write-Host "[Upgrade Chocolatey Packages]" -ForegroundColor $color2
Write-Host ""

Write-Host "Upgrading all Chocolatey packages..." -ForegroundColor $color3
Write-Host "choco upgrade all --yes"
choco upgrade all --yes
Write-Host ""

Write-Host "Done upgrading all Chocolatey packages." -ForegroundColor $color3
Write-Host ""

Write-Host "..." -ForegroundColor $color3
Write-Host ""

<#
Write-Host "[Update PowerShellGet modules]" -ForegroundColor $color2
Write-Host ""

Write-Host "Updating PowerShellGet modules (this can be very slow)..." -ForegroundColor $color3
Update-Module -Verbose
Write-Host ""

# Update-Help
# Write-Host ""

Write-Host "Done updating PowerShellGet modules." -ForegroundColor $color3
Write-Host ""

Write-Host "..." -ForegroundColor $color3
Write-Host ""
#>

Write-Host "[Update all Microsoft Store apps]" -ForegroundColor $color2
Write-Host ""

Write-Host "Updating all Microsoft Store apps..." -ForegroundColor $color3
Write-Host ""

$namespaceName = "Root\cimv2\mdm\dmmap"
$className = "MDM_EnterpriseModernAppManagement_AppManagement01"
$methodName = "UpdateScanMethod"
Get-CimInstance -Namespace $namespaceName -ClassName $className -Verbose | Invoke-CimMethod -MethodName $methodName -Verbose
Write-Host ""

Write-Host "Opening Downloads and Updates in Microsoft Store..." -ForegroundColor $color3
# shell:appsFolder\Microsoft.WindowsStore_8wekyb3d8bbwe!App
Start-Process ms-windows-store://downloadsandupdates
Write-Host ""

Write-Host "Done updating all Microsoft Store apps." -ForegroundColor $color3
Write-Host ""

Write-Host "..." -ForegroundColor $color3
Write-Host ""

#

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

Get-WindowsUpdate -MicrosoftUpdate -Install -AcceptAll -Verbose
Write-Host ""

Write-Host "Opening Windows Update in Settings..." -ForegroundColor $color3
Start-Process ms-settings:windowsupdate-action
Write-Host ""

Write-Host "Done running Windows Update and Microsoft Update." -ForegroundColor $color3
Write-Host ""

Write-Host "..." -ForegroundColor $color3
Write-Host ""

#

Write-Host "[npm patch-level updates]" -ForegroundColor $color2
Write-Host ""

Write-Host "Installing npm-check-updates..." -ForegroundColor $color3
Write-Host "npm install -g npm-check-updates"
npm install -g npm-check-updates
Write-Host ""

Write-Host "Checking npm global for patch-level updates..." -ForegroundColor $color3
Write-Host "ncu --global --target patch --loglevel verbose"
ncu --global --target patch --loglevel verbose
Write-Host ""

Write-Host "Done checking npm global for patch-level updates." -ForegroundColor $color3
Write-Host ""

Write-Host "..." -ForegroundColor $color3
Write-Host ""

#

Write-Host "Done!" -ForegroundColor $color1

<#
$user = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
Get-AppxPackage -User $user
#>
