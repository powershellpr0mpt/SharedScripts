#Get All AD Users
$Users = Get-ADUser -Filter * -Properties DisplayName, EmailAddress, UserPrincipalName, Enabled, DistinguishedName -ResultSetSize $null
$Users.Count

#Get All users with non-matching mail/UPN
$IncorrectUPN = $Users | Where-Object {$null -ne $_.EmailAddress -AND $_.EmailAddress -ne $_.UserprincipalName -AND $_.Enabled -eq $true}
$IncorrectUPN.count
$IncorrectUPN | Select-Object DisplayName, EmailAddress, UserPrincipalName, Enabled, DistinguishedName | Format-Table