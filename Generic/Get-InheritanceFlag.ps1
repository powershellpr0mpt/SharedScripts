function Get-InheritanceFlag {
    <#
    .SYNOPSIS
    Display the InheritanceFlag of a file or folder

    .DESCRIPTION
    Display the InheritanceFlag of a file or folder
    Do note that a False InheritanceFlag means that Inheritance is turned ON

    .PARAMETER Path
    Provide the Path to display the information for

    .NOTES
    Name: Get-InheritanceFlag.ps1
    Author: Robert Prüst
    DateCreated: 02-11-2017
    DateModified: 12-11-2017
    Blog: http://powershellpr0mpt.com

    .LINK
    http://powershellpr0mpt.com

    .EXAMPLE
    Get-InheritanceFlag -Path E:\DFS\Share1

    Description
    -----------
    Get the InheritanceFlag information for folder E:\DFS\Share1

    #>
    [Cmdletbinding()]
    param (
        [Parameter(Position = 0)]
        [ValidateScript( {Test-Path $_})]
        [string]$Path
    )

    $Items = Get-ChildItem -Path $Path -Directory
    foreach ($Item in $Items) {
        try {
            $Item | Get-ACL -ErrorAction Stop | Select-Object @{Name = 'Path'; E = {Convert-Path $_.Path}}, @{Name = 'InheritanceFlag'; E = {$_.AreAccessRulesProtected}}
        }
        catch [System.UnauthorizedAccessException] {
            $Path = $Item.FullName
            [pscustomobject]@{
                Path            = $Path
                InheritanceFlag = 'Unable to access'
            }
        }
    }
}