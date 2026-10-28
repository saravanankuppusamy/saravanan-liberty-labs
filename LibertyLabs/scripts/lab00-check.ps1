<#
  lab00-check.ps1  -  run on every classroom machine the day before class.
  Prints PASS / FAIL / WARN for each prerequisite. Run from an elevated PowerShell:
     powershell -ExecutionPolicy Bypass -File C:\LibertyLabs\scripts\lab00-check.ps1
#>
. "$PSScriptRoot\lab-env.ps1"
$fail = 0
function Pass($m) { Write-Host "PASS  $m" -ForegroundColor Green }
function Fail($m) { Write-Host "FAIL  $m" -ForegroundColor Red; $script:fail++ }
function Warn($m) { Write-Host "WARN  $m" -ForegroundColor Yellow }

# Java -----------------------------------------------------------------
$java = Join-Path $JavaHome 'bin\java.exe'
if (Test-Path $java) {
  $v = (& $java -version 2>&1 | Out-String)
  Pass "Java found at $JavaHome"
  if ($v -notmatch 'OpenJ9') { Warn 'JVM is not OpenJ9 (IBM Semeru). Lab 7 memory health conditions rely on OpenJ9 Health Center data.' }
  foreach ($t in 'keytool.exe','jar.exe') {
    if (-not (Test-Path (Join-Path $JavaHome "bin\$t"))) { Fail "$t missing - install a JDK, not a JRE" }
  }
} else { Fail "No java.exe under $JavaHome - edit `$JavaHome in lab-env.ps1" }

# Liberty --------------------------------------------------------------
if (Test-Path "$Bin\server.bat") {
  Pass "Liberty found at $WlpHome"
  & "$Bin\productInfo.bat" version
} else { Fail "No bin\server.bat under $WlpHome - edit `$WlpHome in lab-env.ps1" }

# Features needed by Labs 3-7 (Network Deployment) ----------------------
$featDir = Join-Path $WlpHome 'lib\features'
$nd = 'collectiveController-1.0','clusterMember-1.0','dynamicRouting-1.0','scalingController-1.0',
      'scalingMember-1.0','healthManager-1.0','healthAnalyzer-1.0'
$other = 'adminCenter-1.0','collectiveMember-1.0','monitor-1.0','pages-3.1','appSecurity-5.0',
         'transportSecurity-1.0','ldapRegistry-3.0','mpHealth-4.0','mpMetrics-5.1','restConnector-2.0'
foreach ($f in $nd + $other) {
  $hit = Get-ChildItem $featDir -Filter '*.mf' -ErrorAction SilentlyContinue |
         Select-String -Pattern "IBM-ShortName: $([regex]::Escape($f))\s*$" -List
  if (-not $hit) {
    $hit = Get-ChildItem (Join-Path $WlpHome 'lib\features'), (Join-Path $WlpHome 'usr\extension\lib\features') `
             -Recurse -Filter '*.mf' -ErrorAction SilentlyContinue |
           Select-String -Pattern "IBM-ShortName: $([regex]::Escape($f))\s*$" -List
  }
  if ($hit) { Pass "feature $f installed" }
  elseif ($f -in $nd) { Fail "feature $f missing (Network Deployment) - run: installUtility install $f" }
  else { Fail "feature $f missing - run: installUtility install $f" }
}

# Ports ----------------------------------------------------------------
foreach ($k in $Ports.Keys) {
  foreach ($p in $Ports[$k].Values) {
    if (Get-NetTCPConnection -LocalPort $p -State Listen -ErrorAction SilentlyContinue) {
      Warn "port $p ($k) already in use - fine if that Liberty server is running, otherwise free it"
    }
  }
}

# OpenSSH Server (controller starts/stops members through it, Labs 3-7) ---
$sshd = Get-Service sshd -ErrorAction SilentlyContinue
if ($sshd -and $sshd.Status -eq 'Running') { Pass 'OpenSSH Server (sshd) running' }
else {
  Fail 'OpenSSH Server not running. As admin: Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0; Set-Service sshd -StartupType Automatic; Start-Service sshd'
}

# IBM HTTP Server + plug-in (Lab 6) -------------------------------------
if (Test-Path "$IhsHome\bin\httpd.exe") { Pass "IBM HTTP Server at $IhsHome" } else { Fail "IBM HTTP Server not found at $IhsHome (Lab 6)" }
if (Test-Path "$PluginHome\bin") { Pass "Web Server Plug-ins at $PluginHome" } else { Fail "Web Server Plug-ins not found at $PluginHome (Lab 6)" }
$gsk = Get-ChildItem "$IhsHome\bin", "$PluginHome\bin" -Filter 'gskcmd.bat' -ErrorAction SilentlyContinue | Select-Object -First 1
if ($gsk) { Pass "gskcmd found: $($gsk.FullName)" } else { Warn 'gskcmd.bat not found - needed to convert plugin-key.jks to .kdb in Lab 6' }

# LDAP (Lab 10) --------------------------------------------------------
if (Test-NetConnection -ComputerName localhost -Port 389 -InformationLevel Quiet -WarningAction SilentlyContinue) {
  Pass 'LDAP listening on localhost:389'
} else { Fail 'Nothing listening on localhost:389 - start OpenLDAP before Lab 10' }

# Container runtime (Lab 9, optional) ------------------------------------
$ctr = Get-Command docker -ErrorAction SilentlyContinue | Select-Object -First 1
if ($ctr) { Pass "container runtime: $($ctr.Name)" } else { Fail 'Docker not found - install Docker Desktop (Linux containers, WSL 2 backend) for Lab 9' }

# Jython (Lab 5) -------------------------------------------------------
if (Get-ChildItem "$LabRoot\jython" -Filter 'jython-standalone-*.jar' -ErrorAction SilentlyContinue) { Pass 'Jython standalone jar present' }
else { Fail "Put jython-standalone-2.7.4.jar in $LabRoot\jython (Lab 5)" }

Write-Host ''
if ($fail) { Write-Host "$fail check(s) failed." -ForegroundColor Red; exit 1 } else { Write-Host 'All required checks passed.' -ForegroundColor Green }
