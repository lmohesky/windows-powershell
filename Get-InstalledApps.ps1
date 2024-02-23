<#
.SYNOPSIS
    Obtains a list of all installed applications.
.DESCRIPTION
    Retrieves a list of all installed applications for both 32-bit and 64-bit and separates the results.
.EXAMPLE
    Example usage of the script:
    -----------------------------
    Get-InstalledApps -computerName
.NOTES
    Author: Lance Mohesky
    Created: June 18, 2023
    Modified: Sept 06, 2023
    Version: 2.0
#>
function Get-InstalledApps {
    param (
      [Parameter(Mandatory=$true)]
      [string]$computerName
    )

     # Check if the WinRM service is running on the remote computer, start it if it's not
     $winrmService = Get-Service -Name WinRM -ComputerName $computerName
     if ($winrmService.Status -ne 'Running') {
       Write-Host "WinRM service is not running on $computerName, starting it now..." -ForegroundColor Yellow
       Get-Service -Name WinRM -ComputerName $computerName | Start-Service
     }
  
    # Script block for querying installed software
    $scriptBlock = {
      Write-Host "32-bit Applications:" -ForegroundColor Magenta
      Get-ChildItem 'HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall' |
        ForEach-Object { Get-ItemProperty $_.PsPath } |
        Select-Object DisplayName, DisplayVersion, Publisher, @{Name='InstallDate'; Expression={if ($_.InstallDate) {([datetime]::ParseExact($_.InstallDate, "yyyyMMdd", $null)).ToString('MM-dd-yyyy')}}} | Sort-Object DisplayName |
        Format-Table
  
      Write-Host "`n"  
      Write-Host "64-bit Applications:" -ForegroundColor Magenta
      Get-ChildItem 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall' |
        ForEach-Object { Get-ItemProperty $_.PsPath } |
        Select-Object DisplayName, DisplayVersion, Publisher, @{Name='InstallDate'; Expression={if ($_.InstallDate) {([datetime]::ParseExact($_.InstallDate, "yyyyMMdd", $null)).ToString('MM-dd-yyyy')}}} | Sort-Object DisplayName |
        Format-Table
    }
  
    # Execute the software query script block on the remote computer
    Invoke-Command -ComputerName $computerName -ScriptBlock $scriptBlock
  }