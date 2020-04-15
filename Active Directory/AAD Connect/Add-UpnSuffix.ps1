[cmdletbinding()]
param(
    $OldSuffix = 'contoso.local',
    $NewSuffix = 'contoso.com'
)

$LocalUsers = Get-ADUser -Filter {UserPrincipalName -like "*$OldSuffix"} -Properties userPrincipalName -ResultSetSize $null
$LocalUsers | ForEach-Object {
    $newUpn = $_.UserPrincipalName.Replace("$OldSuffix", "$NewSuffix")
    $_ | Set-ADUser -UserPrincipalName $newUpn
}