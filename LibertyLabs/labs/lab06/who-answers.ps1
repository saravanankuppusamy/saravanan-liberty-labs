<#
  who-answers.ps1  -  sends N requests through IBM HTTP Server and counts which member answered.
  Each request is a new session (no cookie kept), so the plug-in spreads them over the members.
     powershell -File C:\LibertyLabs\labs\lab06\who-answers.ps1 -Count 20
#>
param([int]$Count = 20, [string]$Url = 'http://localhost/sample/')
$tally = @{}
1..$Count | ForEach-Object {
  try {
    $html = (Invoke-WebRequest -Uri $Url -UseBasicParsing -TimeoutSec 15).Content
    $who = if ($html -match 'Served by ([\w-]+)') { $Matches[1] } else { 'unrecognised page' }
  } catch { $who = "error: $($_.Exception.Message)" }
  $tally[$who] = 1 + [int]$tally[$who]
}
$tally.GetEnumerator() | Sort-Object Name | Format-Table @{n='Answered by';e={$_.Name}}, @{n='Requests';e={$_.Value}} -AutoSize
