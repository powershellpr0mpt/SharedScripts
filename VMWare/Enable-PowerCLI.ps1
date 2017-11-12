Function Enable-PowerCLI {
    <#
    .SYNOPSIS
    Load the VMWare PowerCLI Module

    .DESCRIPTION
    Load the VMWare PowerCLI Module into your current session

    .NOTES
    Name: Enable-PowerCLI
    Author: Robert Prüst
    DateCreated: 15-08-2017
    DateModified: <datemodified>
    Blog: http://powershellpr0mpt.com

    .LINK
    http://powershellpr0mpt.com

    .EXAMPLE
    Enable-PowerCLI

    #>
    try {
        Get-Module -Name VMware* -ListAvailable -ErrorAction Stop | Import-Module -Global -ErrorAction Stop
    }
    catch {
        throw 'Unable to load VMWare modules, check if they are properly installed'
    }
}