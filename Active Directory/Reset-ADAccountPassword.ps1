function Reset-ADAccountPassword {
    <#
    .SYNOPSIS
    Reset the password for an Active Directory account

    .DESCRIPTION
    Reset the password for an Active Directory account

    .PARAMETER UserName
    Provide the UserName of the account you'd like to reset
    Search is based on the AD account's Name value
    Uses Out-Gridview to display the possible matches

    .PARAMETER NewPassword
    Provide the new password you'd like to give the account

    .PARAMETER ForceReset
    Set's the AD account to ChangePasswordAtLogon
    Switch parameter

    .NOTES
    Name: Reset-ADAccountPassword.ps1
    Author: Robert Prüst
    DateCreated: <datecreated>
    DateModified: <datemodified>
    Blog: http://powershellpr0mpt.com

    .LINK
    http://powershellpr0mpt.com

    .EXAMPLE
    Reset-ADAccountPassword -UserName b.gates -NewPassword M1cro$0ft! -ForceReset

    Description
    -----------
    Resets the password of the account b.gates to 'M1cro$0ft!' and forces the account to change its password at next logon

    #>
    [cmdletbinding()]
    param(
        [Parameter(
            Position = 0,
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [Alias('Name')]
        [string]$UserName,
        [Parameter(
            Position = 1,
            Mandatory = $true
        )]
        [Alias('Password')]
        [string]$NewPassword,
        [Parameter(
            Position = 2
        )]
        [switch]$ForceReset
    )

    Write-Verbose "username = $username"
    Write-Verbose "password = $newpassword"
    Write-Verbose "forcereset is = $forcereset"
    $AllOk = $false
    try {
        $Account = Get-ADUser -Filter "Name -like '*$UserName*'" -Properties LockedOut, LastBadPasswordAttempt, BadLogonCount, CanonicalName -ErrorAction Stop |
            Select-Object Name, SamAccountName, GivenName, SurName, Enabled, LockedOut, LastBadPasswordAttempt, BadLogonCount, CanonicalName  |
            Sort-Object Name |
            Out-GridView -PassThru -Title "Select the user who's password you'd like to change"
        $AllOk = $true
    }
    catch {
        Write-Warning "Unable to find a user like $UserName. Please verify."
    }
    if ($AllOk) {
        Write-Verbose "account = $($Account.SamAccountName)"

        $SecurePassword = ConvertTo-SecureString -String $NewPassword -AsPlainText -Force

        Write-Verbose "Resetting password for $($Account.Name)"
        Set-ADAccountPassword -Identity $($Account.SamAccountName) -NewPassword $SecurePassword
        Unlock-ADAccount -Identity $($Account.SamAccountName)
        if ($ForceReset) {
            Set-ADUser -Identity $($Account.SamAccountName) -ChangePasswordAtLogon $true
        }
    }
}