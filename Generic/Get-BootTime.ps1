Function Get-BootTime {
    <#
    .SYNOPSIS
    Get a machine's boot time and uptime

    .DESCRIPTION
    Get a machine's boot time and uptime using WMI

    .PARAMETER Computername
    Provide the computer's name you'd like to query.
    Default value = localhost

    .NOTES
    Name: Get-BootTime.ps1
    Author: Robert Prüst
    DateCreated: 03-06-2015
    DateModified: 12-11-2017
    Blog: http://powershellpr0mpt.com

    .LINK
    http://powershellpr0mpt.com

    .EXAMPLE
    Get-BootTime -ComputerName DC01,EX01

    Description
    -----------
    Get the boot information for machines DC01 and EX01

    #>
    [cmdletbinding()]
    param(
        [Parameter(
            Position = 0,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [string[]]$Computername = $env:COMPUTERNAME
    )
    process {
        foreach ($Computer in $ComputerName) {
            $OK = $true
            try {
                $OS = Get-WmiObject -Class Win32_OperatingSystem -ComputerName $Computer -ErrorAction Stop
            }
            catch {
                Write-Warning "Unable to get WMI information from '$Computer'"
                $OK = $false
            }
            if ($OK) {
                #Server Last boot Time
                $Lastboot = $OS.ConvertToDateTime($OS.LastBootUpTime).ToString()

                #UpTime
                $UpTime = New-TimeSpan -Start $Lastboot -End (Get-Date)
                [PSCustomObject]@{
                    ComputerName = $Computer
                    BootTime     = $Lastboot
                    UpTime       = "{0:dd} days {0:hh} hours {0:mm} minutes" -f $UpTime
                }
            }
        }
    }
}