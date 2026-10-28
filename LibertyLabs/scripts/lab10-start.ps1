<#  lab10-start.ps1  -  starting point for Lab 10: payrollServer with the Admin Center and the payroll
    app, protected only by quickStartSecurity (one admin user). #>
. "$PSScriptRoot\lab-env.ps1"
foreach ($s in 'member3','member2','member1','controller','labServer','sslServer','cloudServer') { Stop-LabServer $s }
New-LabServer payrollServer
Set-ServerXml payrollServer @"
<?xml version="1.0" encoding="UTF-8"?>
<server description="Lab 10 - users, roles and LDAP">
  <featureManager>
    <feature>pages-3.1</feature>
    <feature>appSecurity-5.0</feature>
    <feature>adminCenter-1.0</feature>
  </featureManager>
  $(Get-Endpoint 'payrollServer')
  <remoteFileAccess><writeDir>`${server.config.dir}</writeDir></remoteFileAccess>

  <!-- STARTING POINT: one user, no groups. Part 1 replaces this with a basicRegistry. -->
  <quickStartSecurity userName="$AdminUser" userPassword="$AdminPassword"/>

  <application id="payroll" name="payroll" type="war" location="`${server.config.dir}/apps/payroll.war"/>
</server>
"@
New-Item -ItemType Directory -Force (Join-Path $Servers 'payrollServer\apps') | Out-Null
Copy-Item (Join-Path $Apps 'payroll.war') (Join-Path $Servers 'payrollServer\apps') -Force
Start-LabServer payrollServer
Write-Host "Ready for Lab 10: https://localhost:$($Ports.payrollServer.https)/payroll/" -ForegroundColor Green
