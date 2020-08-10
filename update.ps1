Write-Host "[[[UPDATE SCRIPT]]]" -ForegroundColor DarkRed
Write-Host ""
Write-Host "..." -ForegroundColor Red
Write-Host ""

###

$wslName = "WSL Ubuntu"
$wslUser = wsl whoami
Write-Host "[Update, upgrade, and autoremove in $wslName]" -ForegroundColor Red
$sudopw = Read-Host -assecurestring "[sudo] password for $wslUser (blank to skip)"

if ($sudopw.Length -ne 0) {
	Write-Host "Updating, upgrading, and autoremoving in $wslName..."

	$sudopw = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($sudopw))

	wsl export HISTIGNORE='*sudo -S*'
	
	Write-Host "Updating in $wslName..." -ForegroundColor Red
	wsl echo "$sudopw" | wsl sudo -S -k apt update
	Write-Host "Done updating in $wslName." -ForegroundColor Red
	
	Write-Host "Upgrading in $wslName..." -ForegroundColor Red
	wsl echo "$sudopw" | wsl sudo -S -k apt upgrade
	Write-Host "Done upgrading in $wslName." -ForegroundColor Red
	
	Write-Host "Autoremoving in $wslName..." -ForegroundColor Red
	wsl echo "$sudopw" | wsl sudo -S -k apt autoremove
	Write-Host "Done autoremoving in $wslName." -ForegroundColor Red
	
	Write-Host "Done with $wslName." -ForegroundColor Red
} else {
	Write-Host "Skipped" -ForegroundColor Red
}

Write-Host ""
Write-Host "..." -ForegroundColor Red
Write-Host ""

###

Write-Host "[Upgrade Chocolatey Packages]" -ForegroundColor Red
Write-Host "Upgrading all Chocolatey packages..." -ForegroundColor Red
choco upgrade all -y
Write-Host "Done upgrading all Chocolatey packages." -ForegroundColor Red
Write-Host ""
Write-Host "..." -ForegroundColor Red
Write-Host ""

###

### Write-Host "[Update PowerShellGet modules]" -ForegroundColor Red
### Write-Host "Updating PowerShellGet modules (this can be very slow)..." -ForegroundColor Red
### Update-Module -Verbose
### Write-Host "Done updating PowerShellGet modules." -ForegroundColor Red
### Write-Host ""
### Write-Host "..." -ForegroundColor Red
### Write-Host ""

###

Write-Host "[Update all Microsoft Store apps]" -ForegroundColor Red
Write-Host "Updating all Microsoft Store apps..." -ForegroundColor Red
Get-CimInstance -Namespace "Root\cimv2\mdm\dmmap" -ClassName "MDM_EnterpriseModernAppManagement_AppManagement01" | Invoke-CimMethod -MethodName UpdateScanMethod -Verbose
Write-Host "Done updating all Microsoft Store apps." -ForegroundColor Red
Write-Host ""
Write-Host "..." -ForegroundColor Red
Write-Host ""

###

Write-Host "[Windows Update and Microsoft Update]" -ForegroundColor Red
Write-Host "Running Windows Update and Microsoft Update..." -ForegroundColor Red
# Requires PowerShell >=5
#$PSVersionTable.PSVersion

# Only needed on first run
#Install-Module PSWindowsUpdate
#Get-Command -module PSWindowsUpdate
#Add-WUServiceManager -ServiceID 7971f918-a847-4430-9279-4a52d1efe18d

Get-WindowsUpdate -MicrosoftUpdate -Install -AcceptAll -Verbose
Write-Host "Done running Windows Update and Microsoft Update." -ForegroundColor Red
Write-Host ""
Write-Host "..." -ForegroundColor Red
Write-Host ""

###

Write-Host "[npm patch-level updates]" -ForegroundColor Red
Write-Host "Checking npm global for patch-level updates..." -ForegroundColor Red
npm install -g npm-check-updates
ncu --global --semverLevel minor
Write-Host "Done checking npm global for patch-level updates." -ForegroundColor Red
Write-Host ""
Write-Host "..." -ForegroundColor Red
Write-Host ""

###

Write-Host "Done!" -ForegroundColor DarkRed

#$user = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
#Get-AppxPackage -User $user
