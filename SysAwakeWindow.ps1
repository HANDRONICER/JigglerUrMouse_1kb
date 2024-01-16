
[System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')       | out-null
[System.Reflection.Assembly]::LoadWithPartialName('presentationframework')      | out-null
[System.Reflection.Assembly]::LoadWithPartialName('System.Drawing')          | out-null
[System.Reflection.Assembly]::LoadWithPartialName('WindowsFormsIntegration') | out-null
$icon = (".\IMG.png")    

$Main_Tool_Icon = New-Object System.Windows.Forms.NotifyIcon
$Main_Tool_Icon.Text = "SysAwakeWindow"
$Main_Tool_Icon.Icon = $icon
$Main_Tool_Icon.Visible = $true

$Menu_Normal = New-Object System.Windows.Forms.MenuItem
$Menu_Normal.Enabled = $false
$Menu_Normal.Text = "ACTIVAR"

$Menu_Zen = New-Object System.Windows.Forms.MenuItem
$Menu_Zen.Enabled = $true
$Menu_Zen.Text = "ACTIVAR ZEN"

$Menu_Stop = New-Object System.Windows.Forms.MenuItem
$Menu_Stop.Enabled = $true
$Menu_Stop.Text = "DESACTIVAR"

$Menu_Exit = New-Object System.Windows.Forms.MenuItem
$Menu_Exit.Text = "SALIR_DE_LA_APP"

$contextmenu = New-Object System.Windows.Forms.ContextMenu
$Main_Tool_Icon.ContextMenu = $contextmenu
$Main_Tool_Icon.contextMenu.MenuItems.AddRange($Menu_Normal)
$Main_Tool_Icon.contextMenu.MenuItems.AddRange($Menu_Zen)
$Main_Tool_Icon.contextMenu.MenuItems.AddRange($Menu_Stop)
$Main_Tool_Icon.contextMenu.MenuItems.AddRange($Menu_Exit)

$LetterScript = {
    while (1) {
      $wsh = New-Object -ComObject WScript.Shell
      $wsh.SendKeys('+{F15}')
      $wsh.SendKeys('{SCROLLLOCK}')
      Start-Sleep -seconds 16
      $wsh.SendKeys('+{F15}')
      Start-Sleep -seconds 12
    }
}

$MarkerScriptZEN = {
    while (1) {
        Add-Type -AssemblyName System.Windows.Forms
        $X = [System.Windows.Forms.Cursor]::Position.X
        $Y = [System.Windows.Forms.Cursor]::Position.Y
        (Add-Type '[DllImport("user32.dll")]public static extern bool SetCursorPos(int X, int Y);' -Name a -Pas)::SetCursorPos($X + 40, $Y + 40)
        (Add-Type '[DllImport("user32.dll")]public static extern bool SetCursorPos(int X, int Y);' -Name a -Pas)::SetCursorPos($X, $Y)
        Start-Sleep -Milliseconds 900
    }
}

$MarkerScriptNORMAL = {
    $Z = 0
    while (1) {
        Add-Type -AssemblyName System.Windows.Forms
        $X = [System.Windows.Forms.Cursor]::Position.X
        $Y = [System.Windows.Forms.Cursor]::Position.Y
        (Add-Type '[DllImport("user32.dll")]public static extern bool SetCursorPos(int X, int Y);' -Name a -Pas)::SetCursorPos($X + 40, $Y + 40)
        if($Z % 2 -eq 0) {(Add-Type '[DllImport("user32.dll")]public static extern bool SetCursorPos(int X, int Y);' -Name a -Pas)::SetCursorPos($X-1, $Y-1)}
        if($Z % 2 -eq 1) {(Add-Type '[DllImport("user32.dll")]public static extern bool SetCursorPos(int X, int Y);' -Name a -Pas)::SetCursorPos($X+1, $Y+1)}
        $Z = $Z+1
        Start-Sleep -Milliseconds 900
    }
}


function Kill-Tree {
    Param([int]$ppid)
    Get-CimInstance Win32_Process | Where-Object { $_.ParentProcessId -eq $ppid } | ForEach-Object { Kill-Tree $_.ProcessId }
    Stop-Process -Id $ppid
}

Start-Job -ScriptBlock $LetterScript -Name "Letter"
Start-Job -ScriptBlock $MarkerScriptNORMAL -Name "MarkerNORMAL"

$Main_Tool_Icon.Add_Click({                    
    If ($_.Button -eq [Windows.Forms.MouseButtons]::Left) {
        $Main_Tool_Icon.GetType().GetMethod("ShowContextMenu",[System.Reflection.BindingFlags]::Instance -bor [System.Reflection.BindingFlags]::NonPublic).Invoke($Main_Tool_Icon,$null)
    }
})

$Menu_Normal.add_Click({
    $Menu_Stop.Enabled = $true
    $Menu_Zen.Enabled = $true
    $Menu_Normal.Enabled = $false
    Stop-Job -Name "letter"
    Stop-Job -Name "MarkerNORMAL"
    Stop-Job -Name "MarkerZEN"
    Start-Job -ScriptBlock $LetterScript -Name "Letter"
    Start-Job -ScriptBlock $MarkerScriptNORMAL -Name "MarkerNORMAL"
 })

 $Menu_Zen.add_Click({
    $Menu_Stop.Enabled = $true
    $Menu_Zen.Enabled = $false
    $Menu_Normal.Enabled = $true
    Stop-Job -Name "letter"
    Stop-Job -Name "MarkerNORMAL"
    Stop-Job -Name "MarkerZEN"
    Start-Job -ScriptBlock $LetterScript -Name "Letter"
    Start-Job -ScriptBlock $MarkerScriptZEN -Name "MarkerZEN"
 })

$Menu_Stop.add_Click({
    $Menu_Stop.Enabled = $true
    $Menu_Zen.Enabled = $false
    $Menu_Normal.Enabled = $true
    Stop-Job -Name "Letter"
    Stop-Job -Name "MarkerNORMAL"
    Stop-Job -Name "MarkerZEN"
 })


$Menu_Exit.add_Click({
    $Main_Tool_Icon.Visible = $false
    $window.Close()
    Stop-Job -Name "Letter"
    Stop-Process $pid
    Stop-Job -Name "MarkerNORMAL"
    Stop-Process $pid
    Stop-Job -Name "MarkerZEN"
    Stop-Process $pid
 })

$windowcode = '[DllImport("user32.dll")] public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);'
$asyncwindow = Add-Type -MemberDefinition $windowcode -name Win32ShowWindowAsync -namespace Win32Functions -PassThru
$null = $asyncwindow::ShowWindowAsync((Get-Process -PID $pid).MainWindowHandle, 0)

[System.GC]::Collect()

$appContext = New-Object System.Windows.Forms.ApplicationContext
[void][System.Windows.Forms.Application]::Run($appContext)