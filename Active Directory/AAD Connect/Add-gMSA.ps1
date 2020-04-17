#Link Group Managed Service Account to local machine

$gMsaName = 'gMSA1'

Import-Module -Name ActiveDirectory
Install-ADServiceAccount -Identity $gMsaName