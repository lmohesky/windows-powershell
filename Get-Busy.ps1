<#
.SYNOPSIS
    Automatically presses an assigned key to prevent computer or application(s) from sleeping.
.DESCRIPTION
    Useful to keep your machine from sleeping or having the screensaver start.
.EXAMPLE
    Example usage of the script:
    -----------------------------
    .\Get-Busy.ps1

  Use CTRL+C to stop
  
.NOTES
    Author: Lance Mohesky
    Created: Feb 27, 2024
    Version: 1.0
#>

# Load the System.Windows.Forms assembly, which contains the SendKeys method
Add-Type -AssemblyName System.Windows.Forms

# Start an infinite loop
while ($true) {
    # Send the left Windows key '{LWIN}' using SendKeys. Modify the LWIN to another key if you want.
    [System.Windows.Forms.SendKeys]::SendWait('{LWIN}')
    
    # Pause the script for 60 seconds or modify integer to however long you want
    Start-Sleep -Seconds 60
}
