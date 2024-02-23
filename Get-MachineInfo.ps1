<#
    .SYNOPSIS
    Obtains useful information for a workstation.

    .DESCRIPTION
    Provideds Name, Logged in users, hardware info, update, printers, shared drives, and network info.

    .AUTHOR
    Lance Mohesky

    .DATE
    15th June 2023

    .EXAMPLE
    Get-MachineInfo
#>
function Start-WinRMService {
    try {
        $service = Get-Service -Name WinRM -ErrorAction Stop
        if ($service.Status -ne 'Running') {
            Write-Host "Starting Windows Remote Management (WinRM) service..." -ForegroundColor Yellow
            Start-Service -Name WinRM -ErrorAction Stop
            Write-Host "Windows Remote Management (WinRM) service started." -ForegroundColor Green
        }
    }
    catch {
        Write-Host "Error starting Windows Remote Management (WinRM) service: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Call the function at the beginning of your script
Start-WinRMService
Function Get-MachineInfo {
    param([string]$pc)

    function Get-LoggedUsers {
        Write-Host "Logged On Users" -ForegroundColor Cyan
        quser.exe /SERVER:$pc
    }

    function Get-SystemInfo {
        Write-Host "`nSystem Information" -ForegroundColor Cyan
        try {
            $sysInfo = Get-CimInstance -ClassName Win32_ComputerSystem -ComputerName $pc
            $osInfo = Get-CimInstance -ClassName Win32_OperatingSystem -ComputerName $pc
            $biosInfo = Get-CimInstance -ClassName Win32_BIOS -ComputerName $pc

            Write-Host "Name: " $sysInfo.Name
            Write-Host "Domain: " $sysInfo.Domain
            Write-Host "Date of Install: " $osInfo.InstallDate
            Write-Host "Manufacturer: " $sysInfo.Manufacturer
            Write-Host "Model: " $sysInfo.Model
            Write-Host "OS Type: " $osInfo.Caption
            Write-Host "OS Version: " $osInfo.Version
            Write-Host "Serial Number: " $biosInfo.SerialNumber
            Write-Host "BIOS version: " $biosInfo.SMBIOSBIOSVersion
        }
        catch {
            Write-Host $_.Exception.Message
        }
    }

    function Get-NetworkInfo {
        Write-Host "`nNetwork Information" -ForegroundColor Cyan
        try {
            $netAdapters = Get-CimInstance -ClassName Win32_NetworkAdapterConfiguration -Filter "IPEnabled = True" -ComputerName $pc
            foreach ($adapter in $netAdapters) {
                Write-Host "Adapter: " $adapter.Description -ForegroundColor Magenta
                Write-Host "IP Address: " $adapter.IPAddress
                Write-Host "Subnet Mask: " $adapter.IPSubnet
                Write-Host "Gateway: " $adapter.DefaultIPGateway
                Write-Host "MAC Address: " $adapter.MACAddress
                Write-Host "DHCP Enabled: " $adapter.DHCPEnabled
            }
        }
        catch {
            Write-Host $_.Exception.Message
        }
    }

    function Get-CpuInfo {
        Write-Host "`nCPU Information" -ForegroundColor Cyan
        try {
            $cpu = Get-CimInstance -ClassName Win32_Processor -ComputerName $pc
            Write-Host "Type: " $cpu.Name
            Write-Host "Cores: " $cpu.NumberOfLogicalProcessors
            Write-Host "Family: " $cpu.Caption
            Write-Host "Speed: " $cpu.CurrentClockSpeed "MHz"
        }
        catch {
            Write-Host $_.Exception.Message
        }
    }

    function Get-MemoryInfo {
        Write-Host "`nMemory Information" -ForegroundColor Cyan
        try {
            $sysInfo = Get-CimInstance -ClassName Win32_ComputerSystem -ComputerName $pc
            $displayGB = [math]::round($sysInfo.TotalPhysicalMemory / 1024 / 1024 / 1024, 0)
            Write-Host "Total Physical Memory: " $displayGB "GB"
        }
        catch {
            Write-Host $_.Exception.Message
        }
    }

    function Get-DiskInfo {
        Write-Host "`nDisk Information" -ForegroundColor Cyan
        try {
            $disks = Get-CimInstance -ClassName Win32_LogicalDisk -ComputerName $pc
            foreach ($disk in $disks) {
                $totalGB = [math]::round($disk.Size / 1024 / 1024 / 1024, 0)
                $freeGB = [math]::round($disk.FreeSpace / 1024 / 1024 / 1024, 0)
                Write-Host "Drive: " $disk.Name
                Write-Host "Name: " $disk.VolumeName
                Write-Host "Total disk size: " $totalGB "GB"
                Write-Host "Free disk size: " $freeGB "GB"
                Write-Host "*******************" -ForegroundColor Yellow
            }
        }
        catch {
            Write-Host $_.Exception.Message
        }
    }

    function Get-PrinterInfo {
        Write-Host "`nPrinter Information" -ForegroundColor Cyan
        try {
            $printers = Get-CimInstance -ClassName Win32_Printer -ComputerName $pc
            foreach ($printer in $printers) {
                Write-Host "Printer Name: " $printer.Name
                Write-Host "Comment: " $printer.Comment
                Write-Host "Location: " $printer.Location
                Write-Host "Shared: " $printer.Shared
                Write-Host "*******************" -ForegroundColor Yellow
            }
        }
        catch {
            Write-Host $_.Exception.Message
        }
    }

    function Get-UptimeInfo {
        Write-Host "`nUptime Information" -ForegroundColor Cyan
        try {
            $osInfo = Get-CimInstance -ClassName Win32_OperatingSystem -ComputerName $pc
            $uptime = (Get-Date) - $osInfo.LastBootUpTime
            $display = "Last Boot: " + $osInfo.LastBootUpTime.ToString("MM/dd/yyyy hh:mm:ss tt")
            $display += "`nUptime: " + $uptime.Days + " days, " + $uptime.Hours + " hours, " + $uptime.Minutes + " minutes"
            Write-Host $display
        }
        catch {
            Write-Host $_.Exception.Message
        }
    }
    
    if (-not $pc) {
        $pc = Read-Host -Prompt "Type the machine's name or IP address: "
    }

    Clear-Host
    Write-Host "`n"

    Get-LoggedUsers
    Get-SystemInfo
    Get-NetworkInfo
    Get-CpuInfo
    Get-MemoryInfo
    Get-DiskInfo
    Get-PrinterInfo
    Get-UptimeInfo
}
