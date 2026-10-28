<#
  lab01-solve.ps1  -  does all of Lab 1 in one go (instructor demo, or catch-up for a student).
  Run from an ELEVATED PowerShell (registering a Windows service needs admin rights):
     powershell -ExecutionPolicy Bypass -File C:\LibertyLabs\scripts\lab01-solve.ps1
#>
param([switch]$NoService)
. "$PSScriptRoot\lab-env.ps1"

Write-Step 'Java and Liberty versions'
& "$JavaHome\bin\java.exe" -version
Invoke-Wlp productInfo version

Write-Step 'Creating labServer'
New-LabServer labServer
Set-ServerXml labServer @"
<?xml version="1.0" encoding="UTF-8"?>
<server description="Lab 1 - first Liberty server">
  <featureManager>
    <feature>pages-3.1</feature>
    <feature>adminCenter-1.0</feature>
  </featureManager>

  $(Get-Endpoint 'labServer')

  <!-- One administrator for the Admin Center. Lab 10 replaces this with a real registry. -->
  <quickStartSecurity userName="$AdminUser" userPassword="$AdminPassword"/>

  <!-- Lets the Admin Center Server Config tool save changes to this folder -->
  <remoteFileAccess>
    <writeDir>`${server.config.dir}</writeDir>
  </remoteFileAccess>
</server>
"@

if ($NoService) {
  Start-LabServer labServer
} else {
  Write-Step 'Registering labServer as a Windows service that starts at boot'
  Invoke-Wlp server registerWinService labServer
  Set-Service -Name labServer -StartupType Automatic
  Start-Service -Name labServer
  Wait-ServerStarted labServer
  Get-Service labServer | Format-Table Name, Status, StartType
}
Write-Host "`nAdmin Center: https://localhost:$($Ports.labServer.https)/adminCenter  (user $AdminUser)" -ForegroundColor Green
