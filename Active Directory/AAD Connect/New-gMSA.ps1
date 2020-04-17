#Create Group Managed Service Account in Active Directory

$gMsaName = 'gMSA1'
$Description = 'Service account for Azure AD Connect'
$gMsaDnsName = "{0}.{1}" -f $gMsaName, $env:USERDNSDOMAIN
$AllowedServers = 'Enter Server Name Here'

$ServiceAccountProperties = @{
    Name                                       = $gMsaName
    Description                                = $Description
    DNSHostName                                = $gMsaDnsName
    PrincipalsAllowedToRetrieveManagedPassword = "{0}$" -f $AllowedServers
    Passthru                                   = $true
}

try {
    Import-Module -Name ActiveDirectory -ErrorAction Stop
    try {
        Add-KdsRootKey -EffectiveImmediately -ErrorAction Stop
        try {
            New-ADServiceAccount @ServiceAccountProperties -ErrorAction Stop
            Get-ADServiceAccount -Identity $gMsaName
        } catch {
            Write-Warning "Unable to create gMSA account '$gMsaName'`n$_"
        }
    } catch {
        Write-Warning "Unable to add Kds Root Key`n$_"
    }
} catch {
    Write-Warning "Unable to import module ActiveDirectory`n$_"
}