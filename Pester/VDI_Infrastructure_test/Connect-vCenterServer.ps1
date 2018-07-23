Function Connect-vCenterServer {
    <#
    .SYNOPSIS
    Connect to VMWare vCenter Server

    .DESCRIPTION
    Connect to VMWare vCenter Server

    .PARAMETER vCenterServer
    Select the vCenterServer to connect to
    Automatically appends the user's domain

    .EXAMPLE
    Connect-vCenterServer -vCenterServer VC01

    Description
    -----------
    Connects to the VC01.contoso.com VMWare vCenter server [if contoso.com is your local DNS Domain]

    .NOTES
    Name: Connect-vCenterServer.ps1
    Author: Robert Prüst
    DateCreated: 16-03-2018
    DateModified: 16-03-2018
    Blog: http://powershellpr0mpt.com

    .LINK
    http://powershellpr0mpt.com

#>
    [Cmdletbinding()]
    param(
        [Parameter(Position = 0, Mandatory = $true)]
        [string]$vCenterServer
    )
    $vCenterServerName = $vCenterServer + '.' + $Env:USERDNSDOMAIN

    if ($global:DefaultVIServer.Name -notcontains $vCenterServerName) {
        if ($Cred_ADM) {
            Write-Verbose "Connecting to vCenter server '$vCenterServerName' - using ADM credentials"
            Connect-VIServer -Server $vCenterServerName -Credential $Cred_ADM -ErrorAction Stop | Out-Null
        }
        else {
            Write-Verbose "Connecting to vCenter server '$vCenterServerName' - please enter credentials"
            Connect-VIServer -Server $vCenterServerName -Credential (Get-Credential) -ErrorAction Stop | Out-Null
        }
    }
}