<#
.SYNOPSIS
    Retrieves the Windows Update Build Revision (UBR) value from a remote computer.

.DESCRIPTION
    This function retrieves the Windows Update Build Revision (UBR) value from the registry of a remote computer.
    It ensures that the WinRM service is running on the remote computer before retrieving the UBR value and stops
    the WinRM service at the end if it was running.

.PARAMETER ComputerName
    The name or IP address of the remote computer.

.EXAMPLE
    Get-RemoteUBR -ComputerName "RemoteComputerName"

.NOTES
    Author: Lance Mohesky
    Date: April 19, 2024
#>
function Get-RemoteUBR {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$ComputerName
    )

    # Check if the WinRM service is running on the remote computer, start it if it's not
    $winrmService = Get-Service -Name WinRM -ComputerName $computerName
    if ($winrmService.Status -ne 'Running') {
      Write-Host "WinRM service is not running on $computerName, starting it now..." -ForegroundColor Yellow
      Get-Service -Name WinRM -ComputerName $computerName | Start-Service
    }

    # Retrieve the UBR value from the remote computer's registry
    $ubrValue = Invoke-Command -ComputerName $ComputerName -ScriptBlock {
        (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name UBR).UBR
    }

    Write-Host "The Windows Revision value on $ComputerName is $ubrValue" -ForegroundColor Green

    # Check if the WinRM service is running on the remote computer, stop it if it is
    $winrmService = Get-Service -Name WinRM -ComputerName $computerName
    if ($winrmService.Status -eq 'Running') {
      Write-Host "Stopping the WinRM service on $computerName..." -ForegroundColor Yellow
      Get-Service -Name WinRM -ComputerName $computerName | Stop-Service
    }
}
