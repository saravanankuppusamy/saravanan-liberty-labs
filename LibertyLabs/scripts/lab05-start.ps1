<#  lab05-start.ps1  -  starting point for Lab 5: controller + two clustered members running the sample app. #>
. "$PSScriptRoot\lab-env.ps1"
. "$PSScriptRoot\collective.ps1"
Stop-LabServer labServer
New-LabCollective -Cluster
Write-Host 'Ready for Lab 5.' -ForegroundColor Green
