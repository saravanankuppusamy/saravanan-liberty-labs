<#
  slow-requests.ps1  -  makes one member answer slowly so the health policy fires.
     powershell -File C:\LibertyLabs\labs\lab07\slow-requests.ps1 -Port 9181 -Minutes 4
#>
param([int]$Port = 9181, [int]$Minutes = 4, [int]$Workers = 4)
$until = (Get-Date).AddMinutes($Minutes)
1..$Workers | ForEach-Object {
  Start-Job -ArgumentList $Port, $until -ScriptBlock {
    param($port, $until)
    while ((Get-Date) -lt $until) {
      try { Invoke-WebRequest "http://localhost:$port/sample/slow.jsp?s=8" -UseBasicParsing -TimeoutSec 30 | Out-Null } catch { }
    }
  }
} | Out-Null
Write-Host "Sending 8-second requests to port $Port until $($until.ToString('HH:mm:ss')). Watch for the member restarting."
Get-Job | Wait-Job | Remove-Job
