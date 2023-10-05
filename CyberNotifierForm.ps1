# Project       : CyberNotifier
# Supported OS  : Windows
# Author        : Gurmukhnishan Singh
# Version       : 1.0
# Description   : This tools help you track the cyber communitiies with new contents and show you as notification on you desktop

# Bell icon embeded
$presentlocation = split-path -parent $MyInvocation.MyCommand.Definition
$cyberconfig = Get-Content (join-path $presentlocation "etc\CyberNotifier.json") | ConvertFrom-Json
$bellicon = 'iVBORw0KGgoAAAANSUhEUgAAADAAAAAwCAYAAABXAvmHAAAAAXNSR0IArs4c6QAAApdJREFUaEPtmU3ITVEUhp/PTzJjYCDJp5goAyEjJT/1SclAiqlISZGMlN+ZhPpSGJiZYCQpCRkppBRFRCgDIzJQ8tdb+0a345y11tn73j6dNbmTtd53vXudvfZe+44wwW1kgudPJ2DYFewq8D9XYCdwLAk8ApwrIbbUJzQHeAtMTkn/BBYCr3OLyC1gCbARWAOs7Ev2PnALuA48zCUkl4BVwElgqTGxJ8CBJMgYUu3WVsAk4AywJ5jFeWA38CMY3+ogk/hLwNYoeYq7CmwBfkVw2lRgL3A6QloRsx84FcGKCpgLvASmRUgrYr4BC4D3XryogBNpE3r56vzVBLSxXRYRMAX4CMx0MTU7fwJmAd+bXf94RAQsy9nH+5JdDjwqLWBfdMMZEhO22rLZIhVQ79Y9p4QJe5cHOCLgCrDZQ+LwFbbOBLNFBNwGVpsZfI7CXusJiQjQRUwbuYRpA2sjmy0i4BmwyMzgc3wKLPaERAToTj/fQ+LwfZXmBnNIRMAHYLaZwecobA1DZvMK0Cn8FdBvCdMpPN1zGnsFjAJvSmT+F+Y84J2VwytA7VOtrqRpHL1jJfAKOAQctYIH/cRx3BrrFXAX0Pxb0u55ODwCNHC8ADQHlzSNljpnnltIPAIuADssoBl8LgLbLThWAeuAm9DqEcCST89HVVifOGvjLAL0WKWuMMOTQQbfz+nS+LgOq0mAVv7yEJLv5fwF2JZe8yp11AnQ934WmJphNdtA6NFLk9p4FUhTBdoQDyS2E9C3zHp53tCw9O6pq80m9n4GY8CNmnar9rgJuOYF/pd/iU/oYLrLVGHrH5vDuZIXTgkBwtWfG0p0ReJ4kETpLpXVSgnImuQg98DAEu8RdRUY+JL3EXYVGHYFfgM9xVQxt5AARgAAAABJRU5ErkJggg=='
$iconimageBytes = [Convert]::FromBase64String($bellicon)
$ims = New-Object IO.MemoryStream($iconimageBytes, 0, $iconimageBytes.Length)
$ims.Write($iconimageBytes, 0, $iconimageBytes.Length);
# Cyber notifier form code
Add-Type -AssemblyName System.Windows.Forms
$NotifyForm = New-Object System.Windows.Forms.Form
$NotifyForm.Text = "Cyber Notifier"
$NotifyForm.Icon = [System.Drawing.Icon]::FromHandle((new-object System.Drawing.Bitmap -argument $ims).GetHIcon())
$NotifyForm.Size = [System.Drawing.Size]::new(320, 200)
$NotifyForm.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::Fixed3D
$NotifyForm.MaximizeBox = $false
$NotifyForm.AutoSize = $true
# form menustrip
$notmenu = New-Object System.Windows.Forms.MenuStrip
$notmenuitem1 = New-Object System.Windows.Forms.ToolStripMenuItem
$notmenuitem1.Text = "Help"
# form menu about item
$about = New-Object System.Windows.Forms.ToolStripMenuItem
$about.Text = "About"
$about.add_click({
        $version = Get-Content "$presentlocation\About.json" | ConvertFrom-Json
        [System.Windows.Forms.MessageBox]::Show(@"
CyberNotifier
This Tool help you enable windows notification with cybersecurity communitiy news.

Version   : $($version.Version)
Author    : Gurmukhnishan Singh
Email     : info@gurmukhnishansingh.me
"@, "CyberNotifier", "OK", "Information") | Out-Null
    })
# form menu update check item
$chkup = New-Object System.Windows.Forms.ToolStripMenuItem
$chkup.Text = "Check for Update"
# existing configuration group
$gp1 = New-Object System.Windows.Forms.GroupBox
$gp1.Text = "Existing Configuration"
$gp1.Location = [System.Drawing.Point]::new(5, 25)
$gp1.Size = [System.Drawing.Size]::new(200, 70)
# Cyber Notifier Existing Configuration
$notifydd = New-Object System.Windows.Forms.ComboBox
$notifydd.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
if ($cyberconfig.NotifyConfig.count -gt 0) {
    $cyberconfig.NotifyConfig | ForEach-Object { $notifydd.Items.Add($_.Name) | Out-Null }
}
else {
    $notifydd.Items.Add("None") | Out-Null
}
$notifydd.SelectedIndex = 0
$notifydd.Location = [System.Drawing.Point]::new(5, 20)
$notifydd.Size = [System.Drawing.Size]::new(190, 20)
$notifydd.add_TextChanged({
    $lab1value.Text = ": "+ $cyberconfig.NotifyConfig.Count
    $del.Enabled = $cyberconfig.NotifyConfig.Count -gt 0
    $edit.Enabled = $cyberconfig.NotifyConfig.Count -gt 0
})

$edit = New-Object System.Windows.Forms.Button
$edit.Text = "Edit"
$edit.Location = [System.Drawing.Point]::new(5, 45)
$edit.size = [System.Drawing.Size]::new(95, 20)
$edit.Enabled = $cyberconfig.NotifyConfig.Count -gt 0
$edit.add_click({
    $notadd.PerformClick()
    $sel = $cyberconfig.NotifyConfig | Where-Object {$_.Name -eq $notifydd.SelectedItem}
    $gp4lab1dd.SelectedItem = $sel.type
    $gp4lab2but.Text = $sel.Name
    $gp4lab3but.Text = $sel.URL
    $save.Text = "Update"
})

$del = New-Object System.Windows.Forms.Button
$del.Text = "Delete"
$del.Location = [System.Drawing.Point]::new(100, 45)
$del.Size = [System.Drawing.Size]::new(95, 20)
$del.Enabled = $cyberconfig.NotifyConfig.Count -gt 0
$del.add_click({
    if ([System.Windows.Forms.MessageBox]::Show('Are you sure ?' , "CyberNotifier" , 4) -eq "Yes"){
        if (($cyberconfig.NotifyConfig | Where-Object { $_.Name -ne $notifydd.SelectedItem }).count -gt 0) { $cyberconfig.NotifyConfig = $cyberconfig.NotifyConfig | Where-Object { $_.Name -ne $notifydd.SelectedItem } } else { $cyberconfig.NotifyConfig = @() }
        $cyberconfig | ConvertTo-Json | Out-File "$presentlocation\CyberNotifier.json"
        $notifydd.Items.Remove($notifydd.SelectedItem)
        if (!$notifydd.Items.Count) { $notifydd.Items.Add("None") }
        $notifydd.SelectedIndex = 0
    }
    })

$notadd = New-Object System.Windows.Forms.Button
$notadd.Text = "Add"
$notadd.Location = [System.Drawing.Point]::new(205, 30)
$notadd.Size = [System.Drawing.Size]::new(100, 65)
$notadd.add_click({
        $gp1.Visible = $false
        $gp2.Visible = $false
        $notadd.Visible = $false
        $gp3.Visible = $true
        $gp4.Visible = $true
        $gp4lab2but.Text = $null
        $gp4lab3but.Text = $null
        $save.Text = "Save"
    })

$gp2 = New-Object System.Windows.Forms.GroupBox
$gp2.Location = [System.Drawing.Point]::new(5, 90)
$gp2.Size = [System.Drawing.Size]::new(300, 70)

$lab1 = New-Object System.Windows.forms.label
$lab1.Text = "Distinct Source Configured"
$lab1.AutoSize = $true
$lab1.TextAlign = [System.Drawing.ContentAlignment]::MiddleRight
$lab1.Size = [System.Drawing.Size]::new(250,20)
$lab1.Location = [System.Drawing.Point]::new(5, 20)

$lab1value = New-Object System.Windows.forms.label
$lab1value.Text = ": " + [string]$cyberconfig.NotifyConfig.Count
$lab1value.Location = [System.Drawing.Point]::new(200, 20)
$lab1value.AutoSize = $true

$gp3 = New-Object System.Windows.Forms.GroupBox
$gp3.Location = [System.Drawing.Point]::new(5, 120)
$gp3.Size = [System.Drawing.Size]::new(300, 40)
$gp3.Visible = $false

$cancel = New-Object System.Windows.Forms.Button
$cancel.Location = [System.Drawing.Point]::new(5, 10)
$cancel.Size = [System.Drawing.Size]::new(145, 25)
$cancel.Text = "Cancel"
$cancel.add_click({
        $gp3.Visible = $false
        $gp1.Visible = $true
        $gp2.Visible = $true
        $gp4.Visible = $false
        $notadd.Visible = $true
    })

$save = New-Object System.Windows.Forms.Button
$save.Location = [System.Drawing.Point]::new(150, 10)
$save.Size = [System.Drawing.Size]::new(145, 25)
$save.Text = "Save"
$save.Enabled = $false
$save.add_click({
    if ($save.Text -eq "Save"){
        if (!($cyberconfig.NotifyConfig | Where-Object { ($_.Name -eq $gp4lab2but.Text) -or ($_.URL -eq $gp4lab3but.text) })) {
            $cyberconfig.NotifyConfig += [psobject]@{Name = $gp4lab2but.Text; URL = $gp4lab3but.text; Type = $gp4lab1dd.SelectedItem }
            [System.Windows.Forms.MessageBox]::Show("Configuration Saved Successfully.", "CyberNotifier", "OK", "Information") | Out-Null
            $notifydd.Items.Add($gp4lab2but.Text) | Out-Null
            $notifydd.Items.Remove("None")
            $notifydd.selectedindex = 0
            $cancel.PerformClick()
        }
        else {
            [System.Windows.Forms.MessageBox]::Show(@"
Name or URL already exists
"@, "CyberNotifier", "OK", "Error")
        }
    }else{
        ($cyberconfig.NotifyConfig | Where-Object {$_.Name -eq $notifydd.SelectedItem}).URL = $gp4lab3but.Text
        ($cyberconfig.NotifyConfig | Where-Object {$_.Name -eq $notifydd.SelectedItem}).Type = $gp4lab1dd.SelectedItem
        ($cyberconfig.NotifyConfig | Where-Object {$_.Name -eq $notifydd.SelectedItem}).Name = $gp4lab2but.Text
        [System.Windows.Forms.MessageBox]::Show("Configuration Saved Successfully.", "CyberNotifier", "OK", "Information") | Out-Null
        $notifydd.Items.Remove($notifydd.SelectedItem)
        $notifydd.Items.Add($gp4lab2but.Text)|Out-Null
        $notifydd.SelectedIndex = 0
        $cancel.PerformClick()
    }
        $cyberconfig | convertto-json | Out-File "$presentlocation\etc\CyberNotifier.json"
    })

$gp4 = New-Object System.Windows.Forms.GroupBox
$gp4.Location = [System.Drawing.Point]::new(5, 25)
$gp4.Size = [System.Drawing.Size]::new(300, 95)
$gp4.Text = "Add Source"
$gp4.Visible = $false

$gp4lab1 = New-Object System.Windows.Forms.Label
$gp4lab1.Text = "Select Type"
$gp4lab1.TextAlign = [System.Drawing.ContentAlignment]::MiddleRight
$gp4lab1.size = [System.Drawing.Size]::new(90, 20)
$gp4lab1.Location = [System.Drawing.Point]::new(5, 15)

$gp4lab1dd = New-Object System.Windows.Forms.ComboBox
$gp4lab1dd.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
$gp4lab1dd.Location = [System.Drawing.Point]::new(100, 15)
$gp4lab1dd.size = [System.Drawing.Size]::new(150, 20)
$cyberconfig.SupportedType | ForEach-Object { $gp4lab1dd.Items.Add($_.Name) | Out-Null }
$gp4lab1dd.SelectedIndex = 0

$gp4lab2 = New-Object System.Windows.Forms.Label
$gp4lab2.Text = "Name"
$gp4lab2.TextAlign = [System.Drawing.ContentAlignment]::MiddleRight
$gp4lab2.size = [System.Drawing.Size]::new(90, 20)
$gp4lab2.Location = [System.Drawing.Point]::new(5, 40)

$gp4lab2but = New-Object System.Windows.Forms.TextBox
$gp4lab2but.Location = [System.Drawing.Point]::new(100, 40)
$gp4lab2but.size = [System.Drawing.Size]::new(150, 20)
$gp4lab2but.Add_TextChanged({
        if (![string]::IsNullOrWhiteSpace($gp4lab2but.Text) -and ![string]::IsNullOrWhiteSpace($gp4lab3but.Text)) { $save.Enabled = $true } else { $save.Enabled = $false }
    })

$gp4lab3 = New-Object System.Windows.Forms.Label
$gp4lab3.Text = "URL"
$gp4lab3.TextAlign = [System.Drawing.ContentAlignment]::MiddleRight
$gp4lab3.size = [System.Drawing.Size]::new(90, 20)
$gp4lab3.Location = [System.Drawing.Point]::new(5, 65)

$gp4lab3but = New-Object System.Windows.Forms.TextBox
$gp4lab3but.Location = [System.Drawing.Point]::new(100, 65)
$gp4lab3but.size = [System.Drawing.Size]::new(150, 20)
$gp4lab3but.Add_TextChanged({
        if (![string]::IsNullOrWhiteSpace($gp4lab2but.Text) -and ![string]::IsNullOrWhiteSpace($gp4lab3but.Text)) { $save.Enabled = $true } else { $save.Enabled = $false }
    })

$gp1.Controls.AddRange(@($notifydd, $edit, $del)) | Out-Null
$notmenuitem1.DropDownItems.AddRange(@($about, $chkup)) | Out-Null
$notmenu.Items.Add($notmenuitem1) | Out-Null
$NotifyForm.Controls.AddRange(@($notmenu, $gp1, $notadd, $gp2, $gp3, $gp4)) | Out-Null
$gp2.Controls.AddRange(@($lab1, $lab1value))
$gp3.Controls.AddRange(@($cancel, $save))
$gp4.Controls.AddRange(@($gp4lab1, $gp4lab1dd, $gp4lab2, $gp4lab2but, $gp4lab3, $gp4lab3but))

$tooltip = New-Object System.Windows.Forms.ToolTip
$tooltip.SetToolTip($notadd, "Add Source")
$tooltip.SetToolTip($notifydd, "Existing Sources")

$NotifyForm.showdialog() | Out-Null