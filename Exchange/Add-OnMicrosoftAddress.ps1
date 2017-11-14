Function Add-OnMicrosoftAddress {
    <#
    .SYNOPSIS
    Adds mail.onmicrosoft.com aliases to mailboxes that not yet have this alias

    .DESCRIPTION
    Adds mail.onmicrosoft.com aliases to mailboxes that not yet have this alias
    This is to assist you when migrating to an Office365 environment
    Connection to an Exchange Server is required for this script to function

    .PARAMETER TenantName
    Enter your tenant's name

    .NOTES
    Name: Add-OnMicrosoftAddress.ps1
    Author: Robert Prüst
    DateCreated: 15-08-2017
    DateModified: 14-11-2017
    Blog: http://powershellpr0mpt.com

    .LINK
    http://powershellpr0mpt.com

    .EXAMPLE
    Add-OnMicrosoftAddress -TenantName Contoso

    Description
    -----------
    Adds the '<alias>@contoso.mail.onmicrosoft.com' email alias to each mailbox that does not yet have an onmicrosoft.com address in your environment

    #>


    [CmdletBinding()]
    param(
        [Parameter(Position = 0, Mandatory = $true)]
        [string]$TenantName
    )

    $TenantSuffix = $TenantName + '.mail.onmicrosoft.com'
    Write-Verbose "Tenant suffix to add is '$TenantSuffix'"

    try {
        $Mailboxes = Get-Mailbox -ResultSize Unlimited | Where-Object {!($_.EmailAddresses -like "*$TenantSuffix*")}
        foreach ($Mailbox in $Mailboxes) {

            $Alias = $Mailbox.alias

            $Email = $Alias + "@$TenantSuffix"

            Set-mailbox $Mailbox.Identity -EmailAddresses @{add = $Email}
        }
    }
    catch [System.Management.Automation.CommandNotFoundException] {
        Write-Warning "Unable to retrieve information, connect to an Exchange environment first"
    }

}