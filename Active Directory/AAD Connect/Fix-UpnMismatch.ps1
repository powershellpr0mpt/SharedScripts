[cmdletbinding()]
param (
    $OUs = @()
)
#Get All AD Users in OUs
$Users = foreach ($OU in $OUs){
    Get-ADUser -Filter * -Properties DisplayName, EmailAddress, UserPrincipalName, Enabled, DistinguishedName -ResultSetSize $null -SearchBase $OU
}
$Users.Count

#Get All users with non-matching mail/UPN
$IncorrectUPNs = $Users | Where-Object {$null -ne $_.EmailAddress -AND $_.EmailAddress -ne $_.UserprincipalName -AND $_.Enabled -eq $true}
$IncorrectUPNs | ForEach-Object {
    Write-Host -ForegroundColor Yellow "[User] - Setting UPN from '$($_.UserPrincipalName)' to '$($_.Emailaddress)'"
    $_ | Set-ADUser -UserPrincipalName $_.Emailaddress
}