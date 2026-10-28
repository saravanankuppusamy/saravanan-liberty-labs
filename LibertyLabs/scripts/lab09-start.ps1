<#  lab09-start.ps1  -  starting point for Lab 9: a clean copy of the container build folder, and the
    sample app next to it. Nothing is started. #>
. "$PSScriptRoot\lab-env.ps1"
foreach ($s in 'member3','member2','member1','controller','labServer','sslServer') { Stop-LabServer $s }
$work = Join-Path $LabRoot 'work\lab09'
if (Test-Path $work) { Remove-Item $work -Recurse -Force }
New-Item -ItemType Directory -Force $work | Out-Null
Copy-Item (Join-Path $LabRoot 'labs\lab09\*') $work -Recurse
Copy-Item (Join-Path $Apps 'sample.war') $work
Write-Host "Ready for Lab 9: work in $work" -ForegroundColor Green
