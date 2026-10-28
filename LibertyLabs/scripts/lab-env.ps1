<#
  lab-env.ps1  -  shared settings and helper functions for the Liberty labs.
  Every labNN-*.ps1 script dot-sources this file:   . "$PSScriptRoot\lab-env.ps1"

  EDIT THE FIRST BLOCK to match the classroom machines, then leave the rest alone.
#>

# ------------------------------------------------------------------ edit me
$JavaHome      = 'C:\IBM\semeru-21'          # JDK (not JRE) - Semeru/OpenJ9 recommended (Lab 7 health data needs OpenJ9)
$WlpHome       = 'C:\IBM\wlp'                # Liberty install root (contains bin\, lib\, usr\)
$LabRoot       = 'C:\LibertyLabs'            # where this kit was unzipped
$AdminUser     = 'admin'
$AdminPassword = 'adminpwd'                  # avoid ! ^ & | in passwords on Windows command lines
$KsPassword    = 'LabKeys2026'               # collective / member keystore password
$RpcUser       = $env:USERNAME               # Windows account the controller uses (over SSH) to start/stop members
$IhsHome       = 'C:\IBM\HTTPServer'         # IBM HTTP Server install root (Lab 6)
$PluginHome    = 'C:\IBM\WebServer\Plugins'  # Web Server Plug-ins install root (Lab 6)
$WebServerName = 'webserver1'                # plug-in config\<name> folder (Lab 6)
# -------------------------------------------------------------------------

$ClusterName   = 'web'
$HostName      = 'localhost'                 # single-machine class; every server registers as localhost
$HostSingletonPort = 20020                   # Lab 7 scaling members on one host must share this port

# One port pair per server so nothing collides when several run at once.
$Ports = @{
  labServer     = @{ http = 9080; https = 9443 }   # Labs 1-2
  controller    = @{ http = 9180; https = 9543 }   # Labs 3-7
  member1       = @{ http = 9181; https = 9544 }
  member2       = @{ http = 9182; https = 9545 }
  member3       = @{ http = 9183; https = 9546 }   # Lab 4 (packaged) and Lab 7 (template)
  sslServer     = @{ http = 9280; https = 9643 }   # Lab 8
  cloudServer   = @{ http = 9380; https = 9743 }   # Lab 9 (outside a container)
  payrollServer = @{ http = 9480; https = 9843 }   # Lab 10
}

$env:JAVA_HOME = $JavaHome
$env:WLP_USER_DIR = $null                    # use the default usr\ under $WlpHome
if ($env:Path -notlike "*$JavaHome\bin*") { $env:Path = "$JavaHome\bin;$WlpHome\bin;$env:Path" }
# Lets collective/dynamicRouting commands accept the controller certificate without a y/n prompt.
$env:JVM_ARGS = '-Dcom.ibm.websphere.collective.utility.autoAcceptCertificates=true -Dcom.ibm.websphere.dynamicRouting.utility.autoAcceptCertificates=true'

$Bin     = Join-Path $WlpHome 'bin'
$Servers = Join-Path $WlpHome 'usr\servers'
$Apps    = Join-Path $LabRoot 'apps'

function Write-Step([string]$msg) { Write-Host "`n==> $msg" -ForegroundColor Cyan }

function Invoke-Wlp {
  # Runs a Liberty command (server, collective, securityUtility...) and stops on failure.
  param([Parameter(Mandatory)][string]$Tool, [Parameter(ValueFromRemainingArguments)][string[]]$ToolArgs)
  $shown = ($ToolArgs -join ' ') -replace '(?i)(password=)\S+', '$1****'
  Write-Host "   $Tool $shown" -ForegroundColor DarkGray
  & (Join-Path $Bin "$Tool.bat") @ToolArgs
  if ($LASTEXITCODE -ne 0 -and -not ($Tool -eq 'server' -and $ToolArgs[0] -in 'stop','status')) {
    throw "$Tool $($ToolArgs[0]) failed with exit code $LASTEXITCODE"
  }
}

function Test-ServerExists([string]$Name) { Test-Path (Join-Path $Servers "$Name\server.xml") }

function Stop-LabServer([string]$Name) {
  if (Test-ServerExists $Name) { & (Join-Path $Bin 'server.bat') stop $Name *> $null }
  $svc = Get-Service -Name $Name -ErrorAction SilentlyContinue
  if ($svc -and $svc.Status -eq 'Running') { Stop-Service $Name -Force }
}

function Remove-LabServer([string]$Name) {
  Stop-LabServer $Name
  $svc = Get-Service -Name $Name -ErrorAction SilentlyContinue
  if ($svc) { & (Join-Path $Bin 'server.bat') unregisterWinService $Name *> $null }
  $dir = Join-Path $Servers $Name
  if (Test-Path $dir) { Remove-Item $dir -Recurse -Force }
}

function New-LabServer([string]$Name) {
  if (Test-ServerExists $Name) { Remove-LabServer $Name }
  Invoke-Wlp server create $Name
}

function Set-ServerXml([string]$Name, [string]$Xml) {
  # Writes server.xml as UTF-8 without BOM (Liberty is fine with either; editors behave better without).
  $path = Join-Path $Servers "$Name\server.xml"
  [IO.File]::WriteAllText($path, $Xml, (New-Object Text.UTF8Encoding $false))
}

function Wait-ServerStarted([string]$Name, [int]$TimeoutSec = 180) {
  $log = Join-Path $Servers "$Name\logs\messages.log"
  $deadline = (Get-Date).AddSeconds($TimeoutSec)
  while ((Get-Date) -lt $deadline) {
    if ((Test-Path $log) -and (Select-String -Path $log -Pattern 'CWWKF0011I' -Quiet)) { return }
    Start-Sleep -Seconds 3
  }
  throw "$Name did not log CWWKF0011I (server ready) within $TimeoutSec s - open $log"
}

function Start-LabServer([string]$Name) {
  $log = Join-Path $Servers "$Name\logs\messages.log"
  if (Test-Path $log) { Remove-Item $log -Force }
  Invoke-Wlp server start $Name
  Wait-ServerStarted $Name
}

function Get-Endpoint([string]$Name) {
  "<httpEndpoint id=`"defaultHttpEndpoint`" host=`"*`" httpPort=`"$($Ports[$Name].http)`" httpsPort=`"$($Ports[$Name].https)`"/>"
}

function Copy-LabApp([string]$War, [string]$Server) {
  $dropins = Join-Path $Servers "$Server\dropins"
  New-Item -ItemType Directory -Force $dropins | Out-Null
  Copy-Item (Join-Path $Apps $War) $dropins -Force
}

function Invoke-ControllerRest {
  # Calls the controller's REST APIs with basic auth, ignoring the self-signed certificate.
  param([string]$Path, [string]$Method = 'GET', [hashtable]$Headers = @{}, $Body = $null)
  $pair = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("${AdminUser}:${AdminPassword}"))
  $Headers['Authorization'] = "Basic $pair"
  $uri = "https://${HostName}:$($Ports.controller.https)$Path"
  $req = @{ Uri = $uri; Method = $Method; Headers = $Headers }
  if ($PSVersionTable.PSVersion.Major -ge 7) { $req['SkipCertificateCheck'] = $true }
  else {
    if (-not ([System.Management.Automation.PSTypeName]'TrustAll').Type) {
      Add-Type 'using System.Net; using System.Security.Cryptography.X509Certificates;
        public class TrustAll : ICertificatePolicy { public bool CheckValidationResult(ServicePoint s, X509Certificate c, WebRequest r, int p) { return true; } }'
    }
    [Net.ServicePointManager]::CertificatePolicy = New-Object TrustAll
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
  }
  if ($Body) { $req['Body'] = ($Body | ConvertTo-Json -Depth 6); $req['ContentType'] = 'application/json' }
  Invoke-RestMethod @req
}
