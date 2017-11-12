Function Find-UninstallString {
    <#
    .SYNOPSIS
    Find Uninstall information for specific applications

    .DESCRIPTION
    Using the Windows Registry to find the Uninstall information for the application you want

    .PARAMETER ApplicationName
    Enter the Application's Name for which you'd like to find Uninstall information

    .NOTES
    Name: Find-UninstallString.ps1
    Author: Robert Prüst
    DateCreated: 07-09-2016
    DateModified: 12-11-2017
    Blog: http://powershellpr0mpt.com

    .LINK
    http://powershellpr0mpt.com

    .EXAMPLE
    Find-UninstallString -ApplicationName Skype

    Description
    -----------
    Gets the uninstall information for the application Skype or anything related to the name Skype

    #>
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true)]
        $ApplicationName
    )

    begin {
        Write-Verbose "Running $($MyInvocation.MyCommand)"
        Write-Verbose "Application is '$ApplicationName'"

        Write-Verbose 'Getting current uninstall info from Registry'
        $RegPath32 = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"
        $RegPath64 = "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall"

    }

    process {
        Write-Verbose 'Creating new empty array'
        $AllApps = @()
        $AllApps32 = Get-ChildItem -Path $Regpath32
        $AllApps64 = Get-ChildItem -Path $RegPath64

        $AllApps += $AllApps32
        $AllApps += $AllApps64

        foreach ($App in $AllApps) {
            $AppReg = Get-ItemProperty $App.PSPath -ErrorAction SilentlyContinue | Where-Object {$_.DisplayName -like "*$ApplicationName*"}
            foreach ($wantedApp in $AppReg) {
                $properties = [ordered]@{
                    'DisplayName'     = $WantedApp.DisplayName ;
                    'DisplayVersion'  = $WantedApp.DisplayVersion ;
                    'UninstallString' = $WantedApp.UninstallString ;
                    'RegKey'          = ($WantedApp.PSPath).TrimStart('Microsoft.PowerShell.Core\Registry::')
                }
                $obj = New-Object -TypeName PSObject -Property $properties
                $obj
            }
        }
    }
}