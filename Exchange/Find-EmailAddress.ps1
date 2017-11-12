Function Find-EmailAddress {
    <#
    .SYNOPSIS
    Find a specific email address in your environment

    .DESCRIPTION
    Find a specific email address in your environment
    Requires you to be connected to an Exchange Server

    .PARAMETER EmailAddress
    The email address you want to find

    .NOTES
    Name: Find-EmailAddress.ps1
    Author: Robert Prüst
    DateCreated: 15-06-2015
    DateModified: 12-11-2017
    Blog: http://powershellpr0mpt.com

    .LINK
    http://powershellpr0mpt.com

    .EXAMPLE
    Find-EmailAddress -EmailAddress b.gates@microsoft.com

    Description
    -----------
    Try and find the email address b.gates@microsoft.com in your environment

    #>
    [cmdletbinding()]
    param (
        [Parameter(Position = 0,
            Mandatory = $true
        )]
        [string]$EmailAddress
    )

    try {
        Get-Recipient -ResultSize Unlimited -Filter {
            EmailAddresses -like "*$EmailAddress*"
        } | Select-Object Name, EmailAddresses, RecipientType
    }
    catch [System.Management.Automation.CommandNotFoundException] {
        Write-Warning "Unable to find email address, you don't seem to be connected to an Exchange server"
    }
}