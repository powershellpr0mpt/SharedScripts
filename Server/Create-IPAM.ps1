## SCRIPT TO BE RUN ON THE IPAM SERVER

#Install IPAM features
Install-WindowsFeature -Name IPAM -IncludeAllSubFeature -IncludeManagementTools -Verbose

#Install AD PowerShell management tools
Install-WindowsFeature -Name RSAT-AD-PowerShell -Verbose

#Create folder to store IPAM database files
$Drive = 'E:\'
$Folder = 'IPAM_Database'
$IPAM_DBFolder = Join-Path -Path $Drive -ChildPath $Folder

New-Item -Path $Drive -Name $Folder -ItemType Directory

#Check for existing GPOs
$OldGPOs = Get-GPO -All | Where-Object {$_.DisplayName -like '*OLD_IPAM*'}
foreach ($OldGPO in $OldGPOs) {
    Rename-GPO -Name $OldGPO.DisplayName -TargetName "Old_$($OldGPO.DisplayName)"
}

#Provision IPAM server
$GpoPrefix = 'IPAM'
Invoke-IpamServerProvisioning -WidSchemaPath $IPAM_DBFolder -ProvisioningMethod Automatic -GpoPrefix $GpoPrefix -Verbose

#Create IPAM GPOs
$Domain = $env:USERDNSDOMAIN
Invoke-IpamGpoProvisioning -Domain $Domain -GpoPrefixName $GpoPrefix -DelegatedGpoGroup 'Server Administrators' -PassThru -Force

#Configure GPOs
#Get Computer objects
$DNSServers = Get-ADComputer -Filter "Name -like 'MS-DNS*'"
$DCServers = Get-ADComputer -Filter "Name -like 'MS-DC*'"
$DHCPServers = Get-ADComputer -Filter "Name -like 'MS-DHCP*'"
$NPSServers = Get-ADComputer -Filter "Name -like 'MS-NPS*'"

#Set GPO permissions, force GPUpdate and Add local access to Event Log Readers group
foreach ($DNSServer in $DNSServers) {
    Set-GPPermissions -Name "$($GpoPrefix)_DNS" -PermissionLevel GpoApply -TargetType Computer -TargetName $DNSServer.Name
    Invoke-Command -ComputerName $DNSServer.Name -ScriptBlock {gpupdate /force}
}
foreach ($DHCPServer in $DHCPServers) {
    Set-GPPermissions -Name "$($GpoPrefix)_DHCP" -PermissionLevel GpoApply -TargetType Computer -TargetName $DHCPServer.Name
    Invoke-Command -ComputerName $DHCPServer.Name -ScriptBlock {net localgroup "event log readers" "HAARD\IPAMUG" /add ; gpupdate /force}
}
foreach ($DCServer in $DCServers) {
    Set-GPPermissions -Name "$($GpoPrefix)_DC_NPS" -PermissionLevel GpoApply -TargetType Computer -TargetName $DCServer.Name
    Invoke-Command -ComputerName $DCServer.Name -ScriptBlock {gpupdate /force}
}
foreach ($NPSServer in $NPSServers) {
    Set-GPPermissions -Name "$($GpoPrefix)_DC_NPS" -PermissionLevel GpoApply -TargetType Computer -TargetName $NPSServer.Name
    Invoke-Command -ComputerName $NPSServer.Name -ScriptBlock {net localgroup "event log readers" "$env:USERDOMAIN\IPAMUG" /add ; gpupdate /force}
}

#Configure Server Discovery
Add-IpamDiscoveryDomain -Name $Domain -DiscoverDc $true -DiscoverDns $true -DiscoverDhcp $true -PassThru


#Set IPAM Server access to Event Log Readers
Get-ADGroup "Event Log Readers"| Add-ADGroupMember -Members $env:COMPUTERNAME

#Confirm SMB Shares on DHCP Servers have been correctly created
Invoke-Command -ComputerName $DHCPServers.Name {Get-SmbShare -Name DhcpAudit}

#Get IPAM Server SID
$SID = ((Get-ADComputer $env:COMPUTERNAME).SID).Value

#MANUALLY REQUIRED STEPS!
#========================
#ADD THE LOCAL IPAM SERVER COMPUTER OBJECT TO THE DNS SERVER'S SECURITY ACL WITH READ PROPERTIES
#Open dnsmgmt.msc on DNS Server
#Select DNS Server, right click and choose Properties
#Go to the Security Tab
#Add -> Select Object Types -> Computer Objects -> Add the IPAM Server -> Select Read Properties only

#Set correct Registry key DNS Servers [re-run if changes have been made to confirm]
foreach ($DNSServer in $DNSServers) {
    Invoke-Command -ComputerName $DNSServer.Name -ScriptBlock {
        $KeyPath = 'HKLM:\SYSTEM\CurrentControlSet\Services\eventlog\DNS Server'
        $Key = 'CustomSD'
        $CurrentCustomSD = (Get-ItemProperty -Path $KeyPath -Name $Key).$Key
        $NewCustomSD = "{0}{1}{2}{3}" -f $CurrentCustomSD, '(A;;0x1;;;', $using:SID, ')'
        if ($CurrentCustomSD.Split(')')[-2].split(';')[-1] -eq $Using:SID) {
            Write-Host -ForegroundColor Green "$env:COMPUTERNAME : $Key already correctly entered"
        }
        else {
            Write-Host -ForegroundColor Yellow "$env:COMPUTERNAME : Setting $Key to correct value"
            Set-ItemProperty -Path $KeyPath -Name $Key -Value $NewCustomSD
        }
    }
}

#Checking DNS Server Service [re-run if changes have been made to confirm]
foreach ($DNSServer in $DNSServers) {
    Invoke-Command -ComputerName $DNSServer.Name -ScriptBlock {
        $CurrentSC = sc.exe sdshow dns
        $NewSC = $CurrentSC.replace('D:(', "D:(A;;CCLCSWLOCRRC;;;$Using:SID)(")
        if ($CurrentSC.split('(')[2].split(';')[-1] -eq "$Using:SID)") {
            Write-Host -ForegroundColor Green "$env:COMPUTERNAME : Service already set correctly"
        }
        else {
            Write-Host -ForegroundColor Yellow "$env:COMPUTERNAME : Setting service permissions"
            sc.exe sdset dns "$NewSC"
        }
    }
}

#Start Server Discovery
Get-ScheduledTask -Taskpath '\Microsoft\Windows\IPAM\' -TaskName 'ServerDiscovery' | Start-ScheduledTask

#Set all discovered servers as Managed
Get-IpamServerInventory | Set-IpamServerInventory -ManageabilityStatus Managed -PassThru

#Start Server Discovery
Get-ScheduledTask -Taskpath '\Microsoft\Windows\IPAM\' -TaskName 'ServerDiscovery' | Start-ScheduledTask

#Start Full management Discovery
if ((Get-ScheduledTask -Taskpath '\Microsoft\Windows\IPAM\' -TaskName 'ServerDiscovery').State -eq 'Ready') {
    Write-Host -ForegroundColor Yellow "Server discovery ready, starting full management discovery"
    Get-ScheduledTask -Taskpath '\Microsoft\Windows\IPAM\' | Where-Object {$_.TaskName -ne 'ServerDiscovery'} | Start-ScheduledTask
}
else {
    Write-Host -ForegroundColor Red "Server discovery still running, re-run when completed"
}
