[cmdletbinding()]
param(
    $OldSuffix = 'crown.local',
    $NewSuffix = 'cvg.nl'
)

$LocalUsers = Get-ADUser -Filter {UserPrincipalName -like "*$OldSuffix"} -Properties userPrincipalName -ResultSetSize $null
$LocalUsers | ForEach-Object {
    $newUpn = $_.UserPrincipalName.Replace("$OldSuffix", "$NewSuffix")
    $_ | Set-ADUser -UserPrincipalName $newUpn
}