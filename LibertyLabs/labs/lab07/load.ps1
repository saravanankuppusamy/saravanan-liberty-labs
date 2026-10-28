<#
  load.ps1  -  keeps the cluster busy so the scaling controller sees high CPU.
  Starts one background job per worker; each loops calling load.jsp on every running member.
     powershell -File C:\LibertyLabs\labs\lab07\load.ps1 -Workers 6 -Minutes 5
  Stop early with Ctrl+C, then:  Get-Job | Stop-Job; Get-Job | Remove-Job
#>
param([int]$Workers = 6, [int]$Minutes = 5, [int[]]$HttpPorts = @(9181, 9182, 9183))
$until = (Get-Date).AddMinutes($Minutes)
$jobs = 1..$Workers | ForEach-Object {
  Start-Job -ArgumentList $HttpPorts, $until -ScriptBlock {
    param($ports, $until)
    while ((Get-Date) -lt $until) {
      foreach ($p in $ports) {
        try { Invoke-WebRequest "http://localhost:$p/sample/load.jsp?ms=1500" -UseBasicParsing -TimeoutSec 10 | Out-Null } catch { }
      }
    }
  }
}
Write-Host "$Workers workers generating load until $($until.ToString('HH:mm:ss')). Watch the controller's messages.log and the Admin Center."
$jobs | Wait-Job | Remove-Job
Write-Host 'Load finished. Within a few minutes the controller should stop the extra member again.'
