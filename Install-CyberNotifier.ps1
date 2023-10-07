$presentlocation = split-path -parent $MyInvocation.MyCommand.Definition
if (!(Get-Service -Name "CyberNotifier" -ErrorAction SilentlyContinue)){
    if ($PSVersionTable.PSEdition -eq "Core"){
    & "$presentlocation\bin\nssm.exe" install "CyberNotifier" "$PSHome\pwsh.exe" "-ExecutionPolicy Bypass -NoProfile -File \"$presentlocation\bin\RSSFeed.ps1\""
    } else{
        & "$presentlocation\bin\nssm.exe" install "CyberNotifier" "$PSHome\powershell.exe" "-ExecutionPolicy Bypass -NoProfile -File \"$presentlocation\bin\RSSFeed.ps1\""
    }
    & "$presentlocation\bin\nssm.exe" set "CyberNotifier" ObjectName "$env:USERDOMAIN\$env:USERNAME" (Get-Credential -UserName "$env:USERDOMAIN\$env:USERNAME" -Message "Provide Password for enabling service").GetNetworkCredential().Password
    Start-Service -Name "CyberNotifier" | Out-Null
} else{
    Write-Host "CyberNotifier already installed."
}