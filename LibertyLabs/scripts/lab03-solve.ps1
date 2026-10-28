<#  lab03-solve.ps1  -  does all of Lab 3: controller + two members, started. #>
. "$PSScriptRoot\lab-env.ps1"
. "$PSScriptRoot\collective.ps1"
Stop-LabServer labServer
New-LabCollective
Write-Host "Collective ready: https://localhost:$($Ports.controller.https)/adminCenter" -ForegroundColor Green
