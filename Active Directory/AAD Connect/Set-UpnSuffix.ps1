[cmdletbinding()]
param(
    $AddUpnSuffix = 'cvg.nl'
)

#Add UPN to AD
Get-ADForest | Set-ADForest -UPNSuffixes @{add = $AddUpnSuffix}