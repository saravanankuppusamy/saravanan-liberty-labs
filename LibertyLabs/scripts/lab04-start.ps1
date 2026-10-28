<#  lab04-start.ps1  -  starting point for Lab 4: the Lab 3 collective, running (no cluster yet). #>
. "$PSScriptRoot\lab-env.ps1"
. "$PSScriptRoot\collective.ps1"
Stop-LabServer labServer
New-LabCollective
Write-Host "Ready for Lab 4: https://localhost:$($Ports.controller.https)/adminCenter" -ForegroundColor Green
