<#  lab06-start.ps1  -  starting point for Lab 6: controller + two-member cluster 'web' running the sample app. #>
. "$PSScriptRoot\lab-env.ps1"
. "$PSScriptRoot\collective.ps1"
Stop-LabServer labServer
New-LabCollective -Cluster
foreach ($m in 'member1','member2') {
  Write-Host "  http://localhost:$($Ports[$m].http)/sample/" }
Write-Host 'Ready for Lab 6.' -ForegroundColor Green
