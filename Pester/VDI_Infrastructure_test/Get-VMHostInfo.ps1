Function Get-VMHostInfo {
    <#
    .SYNOPSIS
    Get realtime performance and configuration info of vSphere hosts

    .DESCRIPTION
    Log into VMWare vCenters to check the realtime performance of the current vSphere hosts
    Some of the checks performed are:
        - What version is the host(s)
        - What is the current CPU usage of the host(s)
        - What is the current memory usage of the host(s)
        - What is the current Configuration status of the host(s)


    .PARAMETER VMHost
    Enter part of the host name you want to check for information

    .PARAMETER vCenterServer
    Enter the vCenterServer name to which you'd like to connect and collect information from

    .EXAMPLE
    Get-VMHostInfo -vCenterServer VC01.contoso.com

    Description
    -----------
    Gets the information for all vsphere hosts connected to  VC01.contoso.com

    .NOTES
    Name: Get-VMHostInfo.ps1
    Author: Robert Prüst
    DateCreated: 27-02-2018
    DateModified: 28-02-2018
    Blog: http://powershellpr0mpt.com

    .LINK
    http://powershellpr0mpt.com
#>
    [Cmdletbinding(DefaultParameterSetName = 'Hosts')]
    param(
        [Parameter(Position = 0)]
        [string]$vCenterServer,
        [Parameter(Position = 1, ParameterSetName = 'Hosts')]
        [string[]]$VMHost = '*'

    )
    $VC = Connect-vCenterServer -vCenterServer $vCenterServer

    try {
        $Hosts = Get-VMHost $VMHost -ErrorAction Stop | Sort-Object Name
        foreach ($vHost in $Hosts) {
            $Esx = $vHost.ExtensionData
            $Output = [PSCustomObject]@{
                HostName        = $vHost.name
                OverallHealth   = $Esx.OverallStatus
                ConfigHealth    = $Esx.ConfigStatus
                ConnectionState = $vHost.ConnectionState
                PowerState      = $vHost.PowerState
                CpuUsage        = [math]::round((($vHost.CpuUsageMhz / $vHost.CpuTotalMhz) * 100), 2)
                MemoryUsage     = [math]::round((($vHost.MemoryUsageGB / $vHost.MemoryTotalGB) * 100), 2)
                Version         = $vHost.Version
                Build           = $vHost.Build
                Parent          = $vHost.Parent
            }
            $Configs = foreach ($ConfigIssue in $Esx.ConfigIssue) {
                [PSCustomObject]@{
                    ConfigIssue = $ConfigIssue.FullFormattedMessage
                    Time        = $ConfigIssue.CreatedTime
                }
            }
            $Alarms = foreach ($AlarmIssue in $Esx.TriggeredAlarmState) {
                $Alarm = (Get-View -Server $VC -Id $AlarmIssue.Alarm).Info.Name
                [PSCustomObject] @{
                    AlarmIssue   = $Alarm
                    Time         = $AlarmIssue.Time
                    Acknowledged = $AlarmIssue.Acknowledged
                }
            }
            $Output | Add-Member -MemberType NoteProperty -Name ConfigIssues -Value $Configs
            $Output | Add-Member -MemberType NoteProperty -Name Alarms -Value $Alarms

            # Create default limited output
            $DefaultProperties = @(($Output.psobject.properties | Select-Object Name).Name[0..3])
            $DefaultPropertySet = New-Object System.Management.Automation.PSPropertySet('DefaultDisplayPropertySet', [string[]]$DefaultProperties)
            $PSStandardMembers = [System.Management.Automation.PSMemberInfo[]]@($DefaultPropertySet)
            $Output | Add-Member -Name PSStandardMembers -MemberType MemberSet -Value $PSStandardMembers

            $Output
        }
    }
    catch [VMware.VimAutomation.Sdk.Types.V1.ErrorHandling.VimException.VimException] {
        Write-Warning "Unable to find VMHost with name $VM"
    }
}

