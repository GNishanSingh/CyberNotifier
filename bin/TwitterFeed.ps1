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