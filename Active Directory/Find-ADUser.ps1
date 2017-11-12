Function Find-ADUser {
    <#
    .SYNOPSIS
    Easily find AD Users

    .DESCRIPTION
    Easily find AD Users based on Name and SamAccountName
    Does a filter search with wildcards and displays extra information, such as LockedOut information

    .PARAMETER UserName
    Provide part of the name you want to search.

    .NOTES
    Name: Find-ADUser.ps1
    Author: Robert Prüst
    DateCreated: 15-08-2017
    DateModified: 12-11-2017
    Blog: http://powershellpr0mpt.com

    .LINK
    http://powershellpr0mpt.com

    .EXAMPLE
    Find-ADUser -UserName ministrat

    Description
    -----------
    Find all AD Users with Name or SamAccountName like *ministrat*

    #>
    param (
        [Parameter(
            Position = 0,
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [string]$UserName
    )

    $Account = Get-ADUser -Filter "(Name -like '*$UserName*') -OR (SamAccountName -like '*$UserName*')" -Properties CanonicalName, LockedOut -ErrorAction SilentlyContinue | Select-Object Name, SamAccountName, GivenName, SurName, CanonicalName, Enabled, LockedOut
    if ($Account) {
        $Account
    }
    else {
        throw "Unable to find a user like $UserName"
    }
}