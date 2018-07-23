# Load function in memory
. .\Connect-vCenterServer.ps1
. .\Get-VMHostAlarms.ps1
. .\Get-VMInfo.ps1

Describe -Name "McAfee VMs on VC02 " -Tag 'AVVC02' {
    $Minute = 5
    $MaxCpu = 60
    $AvgCpu = 30
    $VMNAme = 'McAfee MOVE*'
    $vCenterServer = 'VC02'
    $VMs = Get-VMInfo -VMName $VMName -Minute $Minute -vCenterServer $vCenterServer
    foreach ($VM in $VMs) {
        Context -Name "McAfee MOVE VM: $($VM.VMName) running on $($VM.VMHost)" {

            It "$($VM.VMName) - should be PoweredOn" {
                $VM.PowerState | Should -Be 'PoweredOn'
            }
            It "$($VM.VMName) - CPU max should be < $MaxCpu % over $Minute minutes" {
                $VM.MaxCpu | Should -BeLessThan $MaxCpu
            }
            It "$($VM.VMName) - CPU Average should be < $AvgCpu % over $Minute minutes" {
                $VM.AvgCpu | Should -BeLessThan $AvgCpu
            }
            It "$($VM.VMName) - VMWare Tools status should be ok" {
                $VM.VMToolsStatus | Should -Be 'ToolsOk'
            }
        }
    }
    Disconnect-ViServer -Server * -Confirm:$False
}
Describe -Name "McAfee VMs on VC01 " -Tag 'AVVC01' {
    $Minute = 5
    $MaxCpu = 60
    $AvgCpu = 30
    $VMNAme = 'McAfee MOVE*'
    $vCenterServer = 'VC01'
    $VMs = Get-VMInfo -VMName $VMName -Minute $Minute -vCenterServer $vCenterServer
    foreach ($VM in $VMs) {
        Context -Name "McAfee MOVE VM: $($VM.VMName) running on $($VM.VMHost)" {
            It "$($VM.VMName) - should be PoweredOn" {
                $VM.PowerState | Should -Be 'PoweredOn'
            }
            It "$($VM.VMName) - CPU max should be < $MaxCpu % over $Minute minutes" {
                $VM.MaxCpu | Should -BeLessThan $MaxCpu
            }
            It "$($VM.VMName) - CPU Average should be < $AvgCpu % over $Minute minutes" {
                $VM.AvgCpu | Should -BeLessThan $AvgCpu
            }
            It "$($VM.VMName) - VMWare Tools status should be ok" {
                $VM.VMToolsStatus | Should -Be 'ToolsOk'
            }
        }
    }
    Disconnect-ViServer -Server * -Confirm:$False
}

Describe -Name "Citrix VMs on VC01 " -Tag 'Citrix' {
    $Minute = 30
    $MaxCpu = 80
    $AvgCpu = 50
    $MaxMem = 85
    $AvgMem = 70
    $MinDiskFree = 15
    $VMName = 'CX-*'
    $vCenterServer = 'VC01'
    $VMs = Get-VMInfo -VMName $VMName -Minute $Minute -vCenterServer $vCenterServer | Where-Object {$_.VMName -notmatch "Netscaler"}
    foreach ($VM in $VMs) {
        Context -Name "Citrix VM: $($VM.VMName)" {
            It "$($VM.VMName) - should be PoweredOn" {
                $VM.PowerState | Should -Be 'PoweredOn'
            }
            It "$($VM.VMName) - CPU max should be < $MaxCpu % over $Minute minutes" {
                $VM.MaxCpu | Should -BeLessThan $MaxCpu
            }
            It "$($VM.VMName) - CPU Average should be < $AvgCpu % over $Minute minutes" {
                $VM.AvgCpu | Should -BeLessThan $AvgCpu
            }
            It "$($VM.VMName) - Memory max should be < $MaxMem % over $Minute minutes" {
                $VM.MaxMem | Should -BeLessThan $MaxMem
            }
            It "$($VM.VMName) - Memory Average should be < $AvgMem % over $Minute minutes" {
                $VM.AvgMem | Should -BeLessThan $AvgMem
            }
            It "$($VM.VMName) - VMWare Tools status should be ok" {
                $VM.VMToolsStatus | Should -Be 'ToolsOk'
            }
            foreach ($disk in $VM.Disks) {
                $DiskFree = [math]::round((($disk.FreeSpaceGB / $disk.CapacityGB) * 100), 2)
                It "$($VM.VMName) - $($Disk.Path) should have > $MinDiskFree % available" {
                    $DiskFree | Should -BeGreaterOrEqual $MinDiskFree
                }
            }
        }
    }
    Disconnect-ViServer -Server * -Confirm:$False
}

Describe -Name "RES VMs on VC01 " -Tag 'RES' {
    $Minute = 30
    $MaxCpu = 80
    $AvgCpu = 50
    $MaxMem = 85
    $AvgMem = 70
    $MinDiskFree = 15
    $VMName = 'RS-*'
    $vCenterServer = 'VC01'
    $VMs = Get-VMInfo -VMName $VMName -Minute $Minute -vCenterServer $vCenterServer
    foreach ($VM in $VMs) {
        Context -Name "RES VM: $($VM.VMName)" {
            It "$($VM.VMName) - should be PoweredOn" {
                $VM.PowerState | Should -Be 'PoweredOn'
            }
            It "$($VM.VMName) - CPU max should be < $MaxCpu % over $Minute minutes" {
                $VM.MaxCpu | Should -BeLessThan $MaxCpu
            }
            It "$($VM.VMName) - CPU Average should be < $AvgCpu % over $Minute minutes" {
                $VM.AvgCpu | Should -BeLessThan $AvgCpu
            }
            It "$($VM.VMName) - Memory max should be < $MaxMem % over $Minute minutes" {
                $VM.MaxMem | Should -BeLessThan $MaxMem
            }
            It "$($VM.VMName) - Memory Average should be < $AvgMem % over $Minute minutes" {
                $VM.AvgMem | Should -BeLessThan $AvgMem
            }
            It "$($VM.VMName) - VMWare Tools status should be ok" {
                $VM.VMToolsStatus | Should -Be 'ToolsOk'
            }
            foreach ($disk in $VM.Disks) {
                $DiskFree = [math]::round((($disk.FreeSpaceGB / $disk.CapacityGB) * 100), 2)
                It "$($VM.VMName) - $($Disk.Path) should have > $MinDiskFree % available" {
                    $DiskFree | Should -BeGreaterOrEqual $MinDiskFree
                }
            }
        }
    }
    Disconnect-ViServer -Server * -Confirm:$False
}

Describe "Check VM Hosts VC01" -Tag 'HostVC1' {
    $vCenterServer = 'VC01'
    $vHosts = Get-VMHostAlarms -VMHost 'ESX*' -vCenterServer $vCenterServer
    foreach ($vHost in $vHosts) {
        Context "Check health for : $($vHost.HostName) on $vCenterServer" {
            It "Version should be 6.5.0" {
                $vHost.Version | Should -Be '6.5.0'
            }
            It "CPU usage should be < 75%" {
                $vHost.CpuUsage | Should -BeLessThan 75
            }
            It "Memory Usage should be < 85%" {
                $vHost.MemoryUsage | Should -BeLessThan 85
            }
            It "Overall Health should be green" {
                $vHost.OverallHealth | Should -Be 'green'
            }
            It "There shouldn't be any alarms" {
                $vHost.Alarms | Should -BeNullOrEmpty
            }
            It "Config Health should be green" {
                $vHost.ConfigHealth | Should -Match "green|gray"
            }
            It "There shouldn't be any configuration issues" {
                $vHost.ConfigIssues | Should -BeNullOrEmpty
            }
        }
    }
}

Describe "Check VM Hosts VC02" -Tag 'HostVC2' {
    $vCenterServer = 'VC02'
    $vHosts = Get-VMHostAlarms -VMHost 'ESX*' -vCenterServer $vCenterServer
    foreach ($vHost in $vHosts) {
        Context "Check health for : $($vHost.HostName) on $vCenterServer" {
            It "Version should be 6.5.0" {
                $vHost.Version | Should -Be '6.5.0'
            }
            It "CPU usage should be < 75%" {
                $vHost.CpuUsage | Should -BeLessThan 75
            }
            It "Memory Usage should be < 85%" {
                $vHost.MemoryUsage | Should -BeLessThan 85
            }
            It "Overall Health should be green" {
                $vHost.OverallHealth | Should -Be 'green'
            }
            It "There shouldn't be any alarms" {
                $vHost.Alarms | Should -BeNullOrEmpty
            }
            It "Config Health should be green" {
                $vHost.ConfigHealth | Should -Match "green|gray"
            }
            It "There shouldn't be any configuration issues" {
                $vHost.ConfigIssues | Should -BeNullOrEmpty
            }
        }
    }
}
