Function Disconnect-ExchangeLocal {
    <#
    .SYNOPSIS
    Disconnect a session to a local Exchange server

    .DESCRIPTION
    Disconnect a PowerShell session called 'Exchange Local'

    .PARAMETER SessionName
    The PowerShell session's name you want to disconnect
    Default value is 'Exchange Local'

    .NOTES
    Name: Disconnect-ExchangeLocal.ps1
    Author: Robert Prüst
    DateCreated: 15-08-2017
    DateModified: 03-11-2017
    Blog: http://powershellpr0mpt.com

    .LINK
    http://powershellpr0mpt.com

    .EXAMPLE
    Disconnect-ExchangeLocal

    Description
    -----------
    Disconnects the default PowerShell session called 'Exchange Local'

    #>
    [cmdletbinding()]
    param(
        [Parameter(Position = 0)]
        [string]$SessionName = 'Exchange Local'
    )
    try {
        Remove-PSSession -Name $SessionName -ErrorAction Stop
    }
    catch [System.ArgumentException] {
        Write-Warning "No PSSession available with name '$SessionName' "
    }
}