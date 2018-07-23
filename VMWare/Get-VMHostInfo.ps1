Function Get-VMHostInfo {
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

