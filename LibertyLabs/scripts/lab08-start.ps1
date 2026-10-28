<#  lab08-start.ps1  -  starting point for Lab 8: sslServer with the sample app and the Admin Center,
    using the default keystore Liberty generates. Stops the collective to free memory. #>
. "$PSScriptRoot\lab-env.ps1"
foreach ($s in 'member3','member2','member1','controller','labServer') { Stop-LabServer $s }
New-LabServer sslServer
Set-ServerXml sslServer @"
<?xml version="1.0" encoding="UTF-8"?>
<server description="Lab 8 - SSL">
  <featureManager>
    <feature>pages-3.1</feature>
    <feature>adminCenter-1.0</feature>
  </featureManager>
  $(Get-Endpoint 'sslServer')
  <quickStartSecurity userName="$AdminUser" userPassword="$AdminPassword"/>
  <remoteFileAccess><writeDir>`${server.config.dir}</writeDir></remoteFileAccess>
</server>
"@
Copy-LabApp 'sample.war' sslServer
Start-LabServer sslServer
Write-Host "Ready for Lab 8: https://localhost:$($Ports.sslServer.https)/sample/" -ForegroundColor Green
