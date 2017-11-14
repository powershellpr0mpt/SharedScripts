Function Connect-ExchangeLocal {
    <#
    .SYNOPSIS
    Connect to your local Exchange Server

    .DESCRIPTION
    Create a new PowerShell session to connect to your local Exchange Server

    .PARAMETER ServerFQDN
    Provide the FQDN for your local Exchange Server

    .PARAMETER SessionName
    Provide the name you want your session to be called
    Default value = Exchange local

    .NOTES
    Name: Connect-ExchangeLocal.ps1
    Author: Robert Prüst
    DateCreated: 15-08-2017
    DateModified: 11-12-2017
    Blog: http://powershellpr0mpt.com

    .LINK
    http://powershellpr0mpt.com

    .EXAMPLE
    Connect-ExchangeLocal -ServerFQDN MS-EX01.contoso.local -SessionName EX01

    Description
    -----------
    Connect to Exchange Server MS-EX01.contoso.local under the session name EX01

    #>
    [cmdletbinding()]
    param (
        [Parameter(Position = 0)]
        [string]$ServerFQDN = 'MS-EX03.eigenhaard.nl',
        [Parameter(Position = 1)]
        [string]$SessionName = 'Exchange Local'
    )
    $ExchangeSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri "http://$ServerFQDN/PowerShell/" -Authentication Kerberos -Name $SessionName
    Import-Module (Import-PSSession $ExchangeSession -AllowClobber -DisableNameChecking) -Global -DisableNameChecking
}