$presentlocation = split-path -parent $MyInvocation.MyCommand.Definition
function Show-Notification {
    [cmdletbinding()]
    Param (
        [string]$ToastTitle,
        [string][parameter(ValueFromPipeline)]$ToastText,
        [string]$ToastNotify
    )
    if ($PSVersionTable.PSEdition -ne "Core") {
        [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] > $null
    }
    else {
        [System.Reflection.Assembly]::LoadFrom("$presentlocation\WinRT.Runtime.dll") | Out-Null
        [System.Reflection.Assembly]::LoadFrom("$presentlocation\Microsoft.Windows.SDK.NET.dll") | Out-Null
    }
    $RawXml = [xml]@"
<toast Scanerio="CyberNotifier">
    <visual>
        <binding template="ToastText02">
            <text id="1"></text>
        </binding>
    </visual>
    <actions>
        <action arguments="" content="Open Blog" activationType="protocol"></action>
    </actions>
</toast>
"@
    ($RawXml.toast.visual.binding.text | Where-Object { $_.id -eq "1" }).AppendChild($RawXml.CreateTextNode($ToastTitle)) > $null
    $RawXml.toast.actions.action.arguments = $ToastText
    $SerializedXml = New-Object Windows.Data.Xml.Dom.XmlDocument
    $SerializedXml.LoadXml($RawXml.OuterXml)
    $Toast = [Windows.UI.Notifications.ToastNotification]::new($SerializedXml)
    $Toast.Tag = "CyberNotifier"
    $Toast.Group = "CyberNotifier"
    $Toast.ExpirationTime = [DateTimeOffset]::Now.AddMinutes(1)
    $Notifier = [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier($ToastNotify)
    $Notifier.Show($Toast);
}
if (!(Test-Path "$presentlocation/RSSFeed")){
    New-Item -Path $presentlocation/RSSFeed -ItemType Directory | Out-Null
}
$cyberconfig = Get-Content "$presentlocation/../etc/CyberNotifier.json" | ConvertFrom-Json
while($true){
$cyberconfig.NotifyConfig | Where-Object { $_.Type -eq "RSS" } | ForEach-Object {
    $conf = $_
    $i = 0
    $lastDate = get-date (Import-Clixml -Path "$presentlocation/RSSFeed/$($conf.Name).xml")
    Invoke-RestMethod -Uri $_.URL | Where-Object {(get-date $_.pubDate) -gt $lastDate} | ForEach-Object {
        Show-Notification -ToastTitle $_.title -ToastText $_.link -ToastNotify $conf.Name
        if ($i -eq 0){
        $_.pubDate | Export-Clixml -Path "$presentlocation/RSSFeed/$($conf.Name).xml"
        } 
        $i =$i+1
    }
}
Start-Sleep -Seconds 30
}