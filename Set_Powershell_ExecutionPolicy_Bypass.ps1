
Push-Location
Set-Location HKLM:\Software\Policies\Microsoft\Windows\PowerShell
Set-ItemProperty . ExecutionPolicy "Bypass"
Pop-Location
