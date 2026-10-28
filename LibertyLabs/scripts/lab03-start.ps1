<#  lab03-start.ps1  -  starting point for Lab 3: three bare servers (controller, member1, member2),
    stopped, each with its own ports. Removes any collective left from an earlier run. #>
. "$PSScriptRoot\lab-env.ps1"
Write-Step 'Stopping labServer so the machine has headroom'
Stop-LabServer labServer
foreach ($s in 'member3','member2','member1','controller') { Remove-LabServer $s }
foreach ($s in 'controller','member1','member2') {
  New-LabServer $s
  Set-ServerXml $s @"
<?xml version="1.0" encoding="UTF-8"?>
<server description="$s - bare server for Lab 3">
  <featureManager>
    <feature>pages-3.1</feature>
  </featureManager>
  <variable name="defaultHostName" value="$HostName"/>
  $(Get-Endpoint $s)
</server>
"@
}
Invoke-Wlp server list
Write-Host 'Ready for Lab 3: three bare servers, none started.' -ForegroundColor Green
