<#
  cluster-metrics.ps1  -  Lab 4, Part 5. Pulls JVM metrics for every member of cluster 'web'
  through the collective controller only. The script never talks to a member directly:
  the three routing headers tell the controller which member to forward each call to.

  Usage:  powershell -ExecutionPolicy Bypass -File C:\LibertyLabs\labs\lab04\cluster-metrics.ps1
#>
param([string[]]$Members = @('member1','member2','member3'))
. 'C:\LibertyLabs\scripts\lab-env.ps1'

$userDir = ((Join-Path $WlpHome 'usr') -replace '\\','/')
$jvm = [uri]::EscapeDataString('WebSphere:type=JvmStats')
$rows = foreach ($m in $Members) {
  # Members created from a packaged server in another install have their own user directory.
  $dir = $userDir
  if ($m -eq 'member3' -and (Test-Path 'C:\LibertyLabs\work\wlp3\wlp\usr\servers\member3')) {
    $dir = 'C:/LibertyLabs/work/wlp3/wlp/usr'
  }
  $route = @{
    'com.ibm.websphere.jmx.connector.rest.routing.hostName'      = $HostName
    'com.ibm.websphere.jmx.connector.rest.routing.serverUserDir' = $dir
    'com.ibm.websphere.jmx.connector.rest.routing.serverName'    = $m
  }
  try {
    $attrs = Invoke-ControllerRest -Path "/IBMJMXConnectorREST/mbeans/$jvm/attributes" -Headers $route
    $v = @{}; foreach ($a in $attrs) { $v[$a.name] = $a.value.value }
    [pscustomobject]@{
      Member      = $m
      HeapUsedMB  = [math]::Round([double]$v['UsedMemory'] / 1MB, 1)
      HeapSizeMB  = [math]::Round([double]$v['Heap'] / 1MB, 1)
      'CPU%'      = [math]::Round([double]$v['ProcessCPU'], 1)
      GcCount     = $v['GcCount']
      UpTimeMin   = [math]::Round([double]$v['UpTime'] / 60000, 1)
    }
  } catch {
    [pscustomobject]@{ Member = $m; HeapUsedMB = 'n/a'; HeapSizeMB = ''; 'CPU%' = ''; GcCount = ''; UpTimeMin = "unreachable: $($_.Exception.Message)" }
  }
}
$rows | Format-Table -AutoSize
