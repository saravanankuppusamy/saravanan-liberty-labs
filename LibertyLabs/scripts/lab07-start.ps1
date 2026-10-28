<#  lab07-start.ps1  -  starting point for Lab 7: controller is also the scaling controller (no policy
    yet - the default policy is switched off), and member1/member2 are scaling members in cluster 'web'. #>
. "$PSScriptRoot\lab-env.ps1"
. "$PSScriptRoot\collective.ps1"
Stop-LabServer labServer
$ctrlXml = @'
  <!-- Lab 7 starts with auto scaling switched off. You add a policy in Part 1. -->
  <scalingDefinitions>
    <defaultScalingPolicy enabled="false"/>
  </scalingDefinitions>
'@
$memberXml = "  <hostSingleton name=`"ScalingMemberSingletonService`" port=`"$HostSingletonPort`"/>"
New-LabCollective -Cluster -ControllerFeatures 'scalingController-1.0' -ControllerXml $ctrlXml `
                  -MemberFeatures 'scalingMember-1.0' -MemberXml $memberXml
Write-Host 'Ready for Lab 7.' -ForegroundColor Green
