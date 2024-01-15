@echo off
Title JiggleUrMouse_Lex
MODE 50,8
COLOR 09

@Start "" "%__AppDir__%WindowsPowerShell\v1.0\powershell.exe" -NoLogo -NoProfile -Command "$Host.UI.RawUI.WindowTitle = 'JiggleUrMouse_Lex';$Host.UI.RawUI.WindowSize = New-Object System.Management.Automation.Host.Size(30, 2);while ($true) {(Add-Type -AssemblyName System.Windows.Forms);$X = [System.Windows.Forms.Cursor]::Position.X; $Y = [System.Windows.Forms.Cursor]::Position.Y;(Add-Type '[DllImport(\"user32.dll\")]public static extern bool SetCursorPos(int X, int Y);' -Name a -Pas)::SetCursorPos($X+40, $Y+40);(Add-Type '[DllImport(\"user32.dll\")]public static extern bool SetCursorPos(int X, int Y);' -Name a -Pas)::SetCursorPos($X, $Y);Start-Sleep -Milliseconds 900;}"