Function Show-AvailabilityGroup {
    <#
    .SYNOPSIS
    Show the settings for an SQL AlwaysOn AvailabilityGroup

    .DESCRIPTION
    Show the settings for an SQL AlwaysOn AvailabilityGroup
    Requires the SQLServer PSProvider to be available [provided by the SQLServer Module]

    .PARAMETER ServerName
    Provide the ServerName to query

    .PARAMETER InstanceName
    Provide the InstanceName to query

    .PARAMETER AGName
    Provide the Availability Group Name to query

    .NOTES
    Name: Show-AvailabilityGroup.ps1
    Author: Robert Prüst
    DateCreated: 02-11-2017
    DateModified: 12-11-2017
    Blog: http://powershellpr0mpt.com

    .LINK
    http://powershellpr0mpt.com

    .EXAMPLE
    Show-AvailabilityGroup -ServerName SQL01 -InstanceName Default -AGName AlwaysOn

    Description
    -----------
    Show the AvailabilityGroup information for server SQL01, Instance Default and AlwaysOn AvailabilityGroup AlwaysOn

    #>
    [Cmdletbinding()]
    Param(
        [Parameter(Position = 0)]
        [string[]]$ServerName,
        [string]$InstanceName,
        [string]$AGName
    )
    Import-Module SqlServer -ErrorAction SilentlyContinue
    foreach ($Server in $ServerName) {
        try {
            Get-ChildItem -Path "SQLServer:\SQL\$Server\$InstanceName\AvailabilityGroups\$AGName\AvailabilityReplicas" -ErrorAction Stop
        }
        catch {
            Write-Warning "Unable to find AvailabilityGroup '$AGName' on $Server"
        }
    }
}