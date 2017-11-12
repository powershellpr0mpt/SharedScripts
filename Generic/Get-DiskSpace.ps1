Function Get-DiskSpace {
    <#
    .SYNOPSIS
    Get the diskspace for a specific computer

    .DESCRIPTION
    Get the diskspace for all volumes specific computer using WMI

    .PARAMETER ComputerName
    Provide the computer's name to query

    .NOTES
    Name: Get-DiskSpace.ps1
    Author: Robert Prüst
    DateCreated: 02-07-2015
    DateModified: 12-11-2017
    Blog: http://powershellpr0mpt.com

    .LINK
    http://powershellpr0mpt.com

    .EXAMPLE
    Get-DiskSpace -ComputerName DC01

    Description
    -----------
    Query DC01's diskspace

    #>
    [cmdletbinding()]
    param (
        [Parameter(
            Position = 0,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [string[]]$ComputerName = $env:COMPUTERNAME
    )

    foreach ($Computer in $ComputerName) {
        try {
            $disks = Get-WmiObject Win32_LogicalDisk -Filter "drivetype='3'" -ComputerName $Computer -ErrorAction Stop

            $disks  | Select-Object PSComputerName, DeviceID, VolumeName, @{L = 'SizeGB'; E = {$_.Size / 1GB -as [int]}}, @{L = 'FreeGB'; E = {[math]::Round($_.FreeSpace / 1GB, 2)}} | Sort-Object DeviceID
        }
        catch {
            Write-Warning "Unable to access information from '$computer'. $($_.Exception.Message)"
        }
    }
}