Function New-Credential {
    <#
    .SYNOPSIS
    Creates an encrypted .XML file which contains a set of credentials.

    .DESCRIPTION
    New-Credential asks you for a set of credentials, which it then stores in an encrypted XML file.
    It will create a seperate folder to store the credentials in and can if required force overwrite current XML file.

    .PARAMETER Credentials
    The credential set (username/password) you want to store.

    .PARAMETER Force
    Specify this switch to force an overwrite of XML files if required.

    .NOTES
    Name: New-Credential.ps1
    Author: Robert Prüst
    DateCreated: 03-02-2015
    DateModified: 12-11-2017
    Blog: http://powershellpr0mpt.com

    .LINK
    http://powershellpr0mpt.com

    .EXAMPLE
    New-Credential -Credentials Contoso

    Description
    -----------
    Create a new credential file called Contoso

    .EXAMPLE
    New-Credential -Credentials ACME -Force

    Description
    -----------
    Create a new credential file for ACME, overwriting a current file if it exists

#>

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true,
            HelpMessage = 'Enter the environment name for which you want to store the credentials')]
        [string]$Credentials,

        [Parameter(HelpMessage = 'Switch to force overwrite credentials if they already exist')]
        [switch]$Force
    )
    $CredentialStore = Join-Path -Path $env:USERPROFILE -ChildPath PSCredentials
    $EnvCredentials = Join-Path -Path $CredentialStore -ChildPath $Credentials

    if (-Not (Test-Path $CredentialStore)) {
        $null = New-Item -ItemType Directory -Path $env:USERPROFILE -Name PSCredentials
    }

    if ($Force) {
        if (-not (Test-Path $EnvCredentials)) {
            $null = New-Item -ItemType Directory -Path $CredentialStore -Name $Credentials
            Get-Credential | Export-Clixml -Path "$EnvCredentials\$Credentials.xml" -Force
            Write-Host -ForegroundColor Green "Credentials for $Credentials stored at '$EnvCredentials\$Credentials.xml'"
        }
        else {
            Get-Credential | Export-Clixml -Path "$EnvCredentials\$Credentials.xml" -Force
            Write-Host -ForegroundColor Green "Credentials for $Credentials stored at '$EnvCredentials\$Credentials.xml'"
        }
    }
    else {
        if (Test-Path $EnvCredentials) {
            do {
                $UserInput = Read-Host -Prompt "$EnvCredentials already exists, do you wish to overwrite? [Y]es, [N]o, E[x]it?"
                if (('y', 'yes', 'n', 'no', 'x', 'exit') -notcontains $UserInput) {
                    $UserInput = $null
                    Write-Warning -Message 'Please enter a valid response'
                }
                if (('n', 'no', 'x', 'exit') -contains $UserInput) {
                    Write-Warning -Message 'No changes made, exiting script.'
                    exit
                }
                if (('y', 'yes') -contains $UserInput) {
                    Write-Warning -Message 'Overwriting currently stored credentials'
                    Get-Credential | Export-Clixml -Path "$EnvCredentials\$Credentials.xml" -Force
                    Write-Host -ForegroundColor Green "Credentials for $Credentials stored at '$EnvCredentials\$Credentials.xml'"
                }
            }
            until ($UserInput -ne $null)
        }
        else {
            $null = New-Item -ItemType Directory -Path $CredentialStore -Name $Credentials
            Get-Credential | Export-Clixml -Path "$EnvCredentials\$Credentials.xml" -Force
            Write-Host -ForegroundColor Green "Credentials for $Credentials stored at '$EnvCredentials\$Credentials.xml'"
        }
    }
}