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
        [string]$vCenterServer,
        [ValidateNotNull()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential = (Get-Credential -Message 'Enter vCenter server credentials' -username $env:USERNAME)
    )
    $vCenterServerName = $vCenterServer + '.' + $Env:USERDNSDOMAIN
    Write-Verbose $vCenterServerName

    if ($global:DefaultVIServer.Name -notcontains $vCenterServerName) {
        Write-Verbose "Connecting to vCenter server '$vCenterServerName' "
        Connect-VIServer -Server $vCenterServerName -Credential $Credential
    }
    else {
        Write-Warning "Already connected to vCenter server '$vCenterServerName'"
    }
}