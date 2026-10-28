<#  lab02-start.ps1  -  starting point for Lab 2: labServer running with the Admin Center.
    Reuses Lab 1's server if it is there; otherwise builds it (without the Windows service). #>
. "$PSScriptRoot\lab-env.ps1"
if (-not (Test-ServerExists labServer)) { & "$PSScriptRoot\lab01-solve.ps1" -NoService; return }
$svc = Get-Service labServer -ErrorAction SilentlyContinue
if ($svc) { if ($svc.Status -ne 'Running') { Start-Service labServer; Wait-ServerStarted labServer } }
else { Start-LabServer labServer }
Write-Host "Ready: https://localhost:$($Ports.labServer.https)/adminCenter" -ForegroundColor Green
