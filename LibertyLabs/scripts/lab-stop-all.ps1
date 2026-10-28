<#  lab-stop-all.ps1  -  stops every lab server (end of day, or before switching labs by hand). #>
. "$PSScriptRoot\lab-env.ps1"
foreach ($s in 'member3','member2','member1','controller','labServer','sslServer','cloudServer','payrollServer') {
  if (Test-ServerExists $s) { Write-Host "stopping $s"; Stop-LabServer $s }
}
