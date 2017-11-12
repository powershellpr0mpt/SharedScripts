Function Get-AutoStartService {
    <#
    .SYNOPSIS
    Display all the services which should start automatically, but have incorrectly stopped

    .DESCRIPTION
    Using WMI display all the services on a computer which have a StartMode of Auto, but are currently Stopped with an error code

    .PARAMETER ComputerName
    Provide the computer name of the machine[s] you would like to query.
    Default value is the local machine

    .PARAMETER ShowStopped
    A switch parameter, if included will show the actual services stopped on the machine that's being checked.

    .PARAMETER Restart
    A switch parameter, if included will try and automatically restart the services which are incorrectly stopped
    Do note that this requires Admin privileges on the machine you are accessing

    .NOTES
    Name: Get-AutostartService.ps1
    Author: Robert Prüst
    DateCreated: 02-07-2015
    DateModified: 12-11-2017
    Blog: http://powershellpr0mpt.com

    .LINK
    http://powershellpr0mpt.com

    .EXAMPLE
    Get-AutoStartService -ShowStopped

    Description
    -----------
    Display all services on the local machine that have no correctly started

    #>
    [CmdletBinding()]
    Param (
        [Parameter(Position = 0 , ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)]
        [string[]]$ComputerName = $env:COMPUTERNAME,
        [switch]$ShowStopped,
        [switch]$Restart
    )
    foreach ($Computer in $ComputerName) {
        $AllOK = $false
        try {
            $StoppedServices = Get-WmiObject -Class Win32_Service -ComputerName $Computer -Filter "StartMode = 'Auto' AND State = 'Stopped' AND ExitCode != 0" -ErrorAction Stop
            if (!($StoppedServices)) {
                $AllOK = $True
            }
            if ($ShowStopped) {
                $StoppedServices
            }
            if ($Restart) {
                foreach ($StoppedService in $StoppedServices) {
                    try {
                        Get-Service $StoppedService.Name -ComputerName $Computer -ErrorAction Stop | Set-Service -Status Running -ErrorAction Stop
                    }
                    catch {
                        Write-Warning "Unable to start service '$($StoppedService.Name)' on '$Computer'"
                    }
                    Write-Warning "Please re-run Get-AutoStartService again for $Computer"
                }
            }
        }
        catch [System.Runtime.InteropServices.COMException] {
            Write-Warning "Unable to access computer '$Computer'"
        }
        [PSCustomObject]@{
            ComputerName = $Computer
            State        = $AllOK
        }
    }
}