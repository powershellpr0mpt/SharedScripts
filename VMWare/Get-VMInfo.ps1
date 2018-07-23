Function Get-VMInfo {
    <#
    .SYNOPSIS
    Get realtime performance info of VM's

    .DESCRIPTION
    Log into VMWare vCenters to check the realtime performance of the current VM's
    Some checks performed are:
        - Is the VM running?
        - Is the Max CPU value higher than <MaxCpu> over the period of <Minute> minutes
        - Is the Average CPU value higher than <AvgCpu> over the period of <Minute> minutes


    .PARAMETER VMName
    Enter part of the VMName you want to check for information
    Default value is *, meaning all VM's

    .PARAMETER vCenterServer
    Enter the vCenterServer name to which you'd like to connect and collect information from

    .PARAMETER Minute
    Enter the amount of minutes your sample size should be
    Default value is 5 minutes

    .EXAMPLE
    Get-VMInfo -vCenterServer VC01.contoso.com

    Description
    -----------
    Gets the information for all VM's managed by VC01.contoso.com using default values

    .NOTES
    Name: Get-VMInfo.ps1
    Author: Robert Prüst
    DateCreated: 27-02-2018
    DateModified: 28-02-2018
    Blog: http://powershellpr0mpt.com

    .LINK
    http://powershellpr0mpt.com
#>
    [Cmdletbinding()]
    param (
        [Parameter(Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [string[]]$VMName = '*',
        [Parameter(Position = 1)]
        [string]$vCenterServer,
        [Parameter(Position = 2)]
        [int]$Minute = 5
    )
    begin {
        $Samples = $Minute * 3 + 1 # Every minute has 3 interval periods [x:00/x:20/x:40] + 1 for starting interval

        Connect-vCenterServer -vCenterServer $vCenterServer
    }
    process {

        $VMs = Get-VM $VMName -Server $vCenterServer | Where-Object {$_.PowerState -eq 'PoweredOn'} | Sort-Object Name
        foreach ($VM in $VMs) {
            $VMStats = $VM | Get-Stat -Stat cpu.usage.average, mem.usage.average -Realtime -MaxSamples $Samples
            $Output = [PSCustomObject]@{
                VMName               = $VM.Name
                PowerState           = $VM.PowerState
                MaxCpu               = [math]::round((($VMStats | Where-Object {$_.MetricId -eq 'cpu.usage.average'} | Measure-Object -Maximum Value).Maximum), 2)
                MaxMem               = [math]::round((($VMStats |  Where-Object {$_.MetricId -eq 'mem.usage.average'} | Measure-Object -Maximum Value).Maximum), 2)
                AvgCpu               = [math]::round((($VMStats | Where-Object {$_.MetricId -eq 'cpu.usage.average'} | Measure-Object -Average Value).Average), 2)
                AvgMem               = [math]::round((($VMStats | Where-Object {$_.MetricId -eq 'mem.usage.average'} | Measure-Object -Average Value).Average), 2)
                Disks                = ($VM.Guest.Disks | Sort-Object Path)
                VMHost               = $VM.VMHost
                Notes                = $VM.Notes
                HWVersion            = $VM.Version
                VMToolsStatus        = $VM.ExtensionData.guest.ToolsStatus
                VMToolsRunningStatus = $VM.ExtensionData.guest.ToolsRunningStatus
                VMToolsVersion       = $VM.ExtensionData.guest.ToolsVersion
                IPAddress            = $VM.Guest.IPAddress
                StatIntervalMinutes  = $Minute
            }

            # Create default limited output
            $DefaultProperties = @(($Output.psobject.properties | Select-Object Name).Name[0..3])
            $DefaultPropertySet = New-Object System.Management.Automation.PSPropertySet('DefaultDisplayPropertySet', [string[]]$DefaultProperties)
            $PSStandardMembers = [System.Management.Automation.PSMemberInfo[]]@($DefaultPropertySet)
            $Output | Add-Member -Name PSStandardMembers -MemberType MemberSet -Value $PSStandardMembers

            $Output
        }
    }
}