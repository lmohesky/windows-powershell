<#
.SYNOPSIS
   Displays the system uptime and last boot time.

.DESCRIPTION
   The Show-Uptime function retrieves the last boot time of the system using the Win32_OperatingSystem WMI class.
   It then calculates the uptime by subtracting the last boot time from the current time.
   The function formats the uptime as a string with days, hours, and minutes, and displays the last boot time and uptime.

.AUTHOR
   Lance Mohesky

.DATE
   04/16/2024

.EXAMPLE
   Show-Uptime -ComputerName localhost
   Last Boot Time: Monday 04/15/2024 08:30 AM
   System Uptime: 01 days, 03 hours, 30 minutes
#>

# Function to display the system uptime
Function Show-Uptime {
    param (
        [Parameter(Mandatory = $true)]
        [string]$computerName
    )
   
    # Retrieve the last boot time using the Win32_OperatingSystem WMI class
    $lastBootTime = (Get-CimInstance -ClassName Win32_OperatingSystem).LastBootUpTime
 
    # Calculate the uptime by subtracting the last boot time from the current time
    $uptime = (Get-Date) - $lastBootTime
 
    # Format the uptime as a string with days, hours, and minutes
    $uptimeString = "{0:dd} days, {0:hh} hours, {0:mm} minutes" -f $uptime
 
    # Display the last boot time
    Write-Host "Last Boot Time: " -ForegroundColor Blue -NoNewline
    Write-Host "$($lastBootTime.ToString('dddd MM/dd/yyyy hh:mm tt'))"
 
    # Display the system uptime
    Write-Host "System Uptime: " -ForegroundColor Blue -NoNewline
    Write-Host "$uptimeString"
}
