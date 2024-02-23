<#
.SYNOPSIS
    Queries the requested machine for uptime.
.DESCRIPTION
    Useful to see how long a machine has been online and last reboot time.
.EXAMPLE
    Example usage of the script:
    -----------------------------
    Get-Uptime -computerName
.NOTES
    Author: Lance Mohesky
    Created: July 20, 2022
    Modified: Sept 08, 2023
    Version: 2.0
#>
function Get-Uptime {
   param (
      [Parameter(Mandatory = $true)]
      [string]$computerName
   )

   $os = Get-WmiObject win32_operatingsystem -ComputerName $PC
   $uptime = (Get-Date) - ($os.ConvertToDateTime($os.lastbootuptime))
   $Display = "Uptime: " + $Uptime.Days + " days, " + $Uptime.Hours + " hours, " + $Uptime.Minutes + " minutes" 
   Write-Output $Display
}