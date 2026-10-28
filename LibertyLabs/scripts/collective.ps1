<#
  collective.ps1  -  builds the collective used by Labs 3-7. Dot-sourced by the lab start scripts.
  Requires lab-env.ps1 to be loaded first.
#>

function Get-RpcPassword {
  # The controller starts and stops members by logging on to this Windows host over SSH as $RpcUser.
  # The password is asked once per PowerShell session and never written to disk by these scripts.
  if (-not $script:RpcPasswordPlain) {
    $sec = Read-Host "Windows password for $RpcUser (used by the controller to start/stop members)" -AsSecureString
    $script:RpcPasswordPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
      [Runtime.InteropServices.Marshal]::SecureStringToBSTR($sec))
  }
  $script:RpcPasswordPlain
}

function Get-ControllerXml {
  param([string[]]$ExtraFeatures = @(), [string]$ExtraXml = '')
  $feats = (@('collectiveController-1.0','adminCenter-1.0','monitor-1.0') + $ExtraFeatures |
            ForEach-Object { "    <feature>$_</feature>" }) -join "`r`n"
@"
<?xml version="1.0" encoding="UTF-8"?>
<server description="Collective controller">
  <featureManager>
$feats
  </featureManager>

  <variable name="defaultHostName" value="$HostName"/>
  $(Get-Endpoint 'controller')

  <!-- Administrative user for the collective, the Admin Center and the REST/JMX connector -->
  <quickStartSecurity userName="$AdminUser" userPassword="$AdminPassword"/>

  <!-- Lets the Admin Center Server Config tool edit files under these folders -->
  <remoteFileAccess>
    <writeDir>`${server.config.dir}</writeDir>
    <writeDir>`${wlp.user.dir}</writeDir>
  </remoteFileAccess>

  <!-- Written by the collective create command (createConfigFile option) -->
  <include optional="true" location="`${server.config.dir}/collective-create-include.xml"/>
$ExtraXml
</server>
"@
}

function Get-MemberXml {
  param([string]$Name, [switch]$Cluster, [string[]]$ExtraFeatures = @(), [string]$ExtraXml = '')
  $list = @('pages-3.1','monitor-1.0','collectiveMember-1.0')
  if ($Cluster) { $list += 'clusterMember-1.0' }
  $feats = ($list + $ExtraFeatures | ForEach-Object { "    <feature>$_</feature>" }) -join "`r`n"
  $clusterXml = if ($Cluster) { "  <clusterMember name=`"$ClusterName`"/>" } else { '' }
@"
<?xml version="1.0" encoding="UTF-8"?>
<server description="Collective member $Name">
  <featureManager>
$feats
  </featureManager>

  <variable name="defaultHostName" value="$HostName"/>
  $(Get-Endpoint $Name)
$clusterXml

  <!-- Written by the collective join command (createConfigFile option) -->
  <include optional="true" location="`${server.config.dir}/collective-join-include.xml"/>
$ExtraXml
</server>
"@
}

function Register-LabHost {
  # Stores the Windows credentials for this host in the collective repository, so the controller
  # can start/stop any member on it (members join with --useHostCredentials).
  $pw = Get-RpcPassword
  Invoke-Wlp collective registerHost $HostName "--host=$HostName" "--port=$($Ports.controller.https)" `
    "--user=$AdminUser" "--password=$AdminPassword" "--rpcUser=$RpcUser" "--rpcUserPassword=$pw"
}

function New-LabController {
  param([string[]]$ExtraFeatures = @(), [string]$ExtraXml = '')
  Write-Step 'Creating and configuring the collective controller'
  New-LabServer controller
  Set-ServerXml controller (Get-ControllerXml -ExtraFeatures $ExtraFeatures -ExtraXml $ExtraXml)
  Invoke-Wlp collective create controller "--keystorePassword=$KsPassword" "--hostName=$HostName" `
    "--createConfigFile=$Servers\controller\collective-create-include.xml"
  Start-LabServer controller
  Register-LabHost
}

function Join-LabMember {
  param([string]$Name, [switch]$Cluster, [string[]]$ExtraFeatures = @(), [string]$ExtraXml = '', [switch]$NoStart)
  Write-Step "Creating and joining $Name"
  New-LabServer $Name
  Set-ServerXml $Name (Get-MemberXml -Name $Name -Cluster:$Cluster -ExtraFeatures $ExtraFeatures -ExtraXml $ExtraXml)
  Invoke-Wlp collective join $Name "--host=$HostName" "--port=$($Ports.controller.https)" `
    "--user=$AdminUser" "--password=$AdminPassword" "--keystorePassword=$KsPassword" `
    "--hostname=$HostName" '--useHostCredentials' '--autoAcceptCertificates' `
    "--createConfigFile=$Servers\$Name\collective-join-include.xml"
  if (-not $NoStart) { Start-LabServer $Name }
}

function New-LabCollective {
  # Controller + member1 + member2. -Cluster puts both members in cluster 'web' with the sample app.
  param([switch]$Cluster, [string[]]$ControllerFeatures = @(), [string]$ControllerXml = '',
        [string[]]$MemberFeatures = @(), [string]$MemberXml = '')
  foreach ($s in 'member3','member2','member1','controller') { Remove-LabServer $s }
  New-LabController -ExtraFeatures $ControllerFeatures -ExtraXml $ControllerXml
  foreach ($m in 'member1','member2') {
    Join-LabMember $m -Cluster:$Cluster -ExtraFeatures $MemberFeatures -ExtraXml $MemberXml
    if ($Cluster) { Copy-LabApp 'sample.war' $m }
  }
}
