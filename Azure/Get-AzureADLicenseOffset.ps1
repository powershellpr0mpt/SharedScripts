Function Get-AzureADLicenseOffset {
<#
    .SYNOPSIS
    Check your tenant for accounts that aren't licensed through the AD Group method

    .DESCRIPTION
    Check your tenant for accounts that aren't licensed through the AD Group method

    .PARAMETER ADGroupName
    Enter the group name under which Azure AD Licenses are automatically provisioned

    .NOTES
    Name: Get-AzureADLicenseOffset.ps1
    Author: Robert Prüst
    DateCreated: 27-11-2017
    DateModified: 29-11-2017
    Blog: http://powershellpr0mpt.com

    .LINK
    http://powershellpr0mpt.com

    .EXAMPLE
    Get-AzureADLicenseOffset -GroupName 'Office365 - E1'

    Description
    -----------
    Finds all users which are licensed under Azure AD, but are not provisioned through the AD Group 'Office365 - E1'

    #>
    [Cmdletbinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [string]$ADGroupName
    )
    begin {
        Import-Module AzureAD -ErrorAction SilentlyContinue
        Import-Module ActiveDirectory -ErrorAction SilentlyContinue
        try {
            $null = Connect-AzureAd -Credential (Get-Credential) -ErrorAction Stop
        }
        catch {
            Write-Warning "Unable to connect to Azure AD, aborting script"
            throw
        }
    }
    process {

        $SKUs = Get-AzureADSubscribedSku
        $LicensedAzureUsers = Get-AzureADUser -All:$true | Where-Object {$_.AssignedLicenses -ne $null}
        $ADGroupMembers = Get-ADGroupMember $ADGroupName
        $ADGroupMembers | ForEach-Object {
            Add-Member -InputObject $_ -MemberType NoteProperty -Name UPN -Value (($_ | Get-ADuser).UserPrincipalName) -Force
        }

        $AllLicensedUsers = foreach ($License in $LicensedAzureUsers) {
            $User = [PSCustomObject]@{
                DisplayName = $License.DisplayName
                UPN         = $License.UserPrincipalName
                Enabled     = $License.AccountEnabled
                ObjectId    = $License.ObjectId
                ObjectType  = $License.ObjectType
                DirSync     = $License.DirSyncEnabled
                UserType    = $License.UserType
            }
            if ($ADGroupMembers.UPN -contains $User.UPN) {
                Add-Member -InputObject $User -MemberType NoteProperty -Name AssignmentType -Value AD
            }
            else {
                Add-Member -InputObject $User -MemberType NoteProperty -Name AssignmentType -Value Unknown
            }
            $User
        }

        $NonADLicenses = $AllLicensedUsers | Where-Object {$_.AssignmentType -eq 'Unknown'}
        $Licenses = $NonADLicenses | ForEach-Object {
            $SkuParts = (Get-AzureADUser -ObjectId $_.ObjectId).AssignedLicenses.SkuId
            $LicenseName = foreach ($Part in $SkuParts) {
                $SKUs | Where-Object {$_.SkuId -eq $Part} | Select-Object -ExpandProperty SkuPartNumber
            }
            Add-Member -InputObject $_ -MemberType NoteProperty -Name LicenseName -Value $LicenseName -Force
            $_
        }
        $Licenses
    }
    end {
        Disconnect-AzureAD
    }
}
