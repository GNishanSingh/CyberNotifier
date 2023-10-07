$presentlocation = split-path -parent $MyInvocation.MyCommand.Definition
if ((Get-Service -Name "CyberNotifier" -ErrorAction SilentlyContinue)){
    Stop-Service -Name "CyberNotifier" | Out-Null
    & "$presentlocation/bin/nssm.exe" remove "CyberNotifier" confirm
} else{
    Write-Host "CyberNotifier not installed."
}