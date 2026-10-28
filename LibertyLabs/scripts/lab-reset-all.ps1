<#  lab-reset-all.ps1  -  removes every lab server (and the labServer Windows service) so a machine
    can be reused for the next class. Run elevated. Asks before deleting. #>
. "$PSScriptRoot\lab-env.ps1"
$names = 'member3','member2','member1','controller','labServer','sslServer','cloudServer','payrollServer'
$found = $names | Where-Object { Test-ServerExists $_ }
if (-not $found) { Write-Host 'No lab servers found.'; return }
Write-Host "This deletes: $($found -join ', ') under $Servers"
if ((Read-Host 'Type YES to continue') -ne 'YES') { return }
foreach ($s in $found) { Remove-LabServer $s; Write-Host "removed $s" }
$tpl = Join-Path $WlpHome 'templates\servers\webMember'
if (Test-Path $tpl) { Remove-Item $tpl -Recurse -Force; Write-Host 'removed webMember template' }
