Function Connect-ExchangeOnline {
    <#
    .SYNOPSIS
    Connect to Microsoft's Exchange Online Server

    .DESCRIPTION
    Create a new PowerShell session to connect to Microsoft's Exchange Online environment

    .PARAMETER SessionName
    Provide the name you want your session to be called
    Default value = Exchange online

    .NOTES
    Name: Connect-ExchangeOnline.ps1
    Author: Robert Prüst
    DateCreated: 15-08-2017
    DateModified: 11-12-2017
    Blog: http://powershellpr0mpt.com

    .LINK
    http://powershellpr0mpt.com

    .EXAMPLE
    Connect-ExchangeOnline -SessionName Office365

    Description
    -----------
    Connect to Exchange Online under the session name Office365

    #>

    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [string]$SessionName = 'Exchange Online'
    )

    $Cred = Get-Credential -Message 'Enter Exchange Online credentials'
    $Uri = 'https://ps.outlook.com/powershell/'

    $Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri $Uri -Credential $Cred -Authentication Basic -AllowRedirection -Name $SessionName
    Import-Module (Import-PSSession $Session -AllowClobber) -Global
}