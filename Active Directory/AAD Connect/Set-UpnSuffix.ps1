[cmdletbinding()]
param(
    $AddUpnSuffix = 'contoso.com'
)

#Add UPN to AD
Get-ADForest | Set-ADForest -UPNSuffixes @{add = $AddUpnSuffix}