Function Disconnect-ExchangeOnline {
    <#
    .SYNOPSIS
    Disconnect a session to Exchange Online

    .DESCRIPTION
    Disconnect a PowerShell session called 'Exchange Online'

    .PARAMETER SessionName
    The PowerShell session's name you want to disconnect
    Default value is 'Exchange Online'

    .NOTES
    Name: Disconnect-ExchangeOnline.ps1
    Author: Robert Prüst
    DateCreated: 15-08-2017
    DateModified: 03-11-2017
    Blog: http://powershellpr0mpt.com

    .LINK
    http://powershellpr0mpt.com

    .EXAMPLE
    Disconnect-ExchangeOnline -SessionName O365

    Description
    -----------
    Disconnects the PowerShell session called 'O365'

    #>
    [cmdletbinding()]
    param(
        [Parameter(Position = 0)]
        [string]$SessionName = 'Exchange Online'
    )
    try {
        Remove-PSSession -Name $SessionName -ErrorAction Stop
    }
    catch [System.ArgumentException] {
        Write-Warning "No PSSession available with name '$SessionName' "
    }
}