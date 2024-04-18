<#
.SYNOPSIS
   Retrieves the Windows Updates installed in the past 3 months.

.DESCRIPTION
   The Get-RecentWindowsUpdates function retrieves the Windows Updates installed in the past 3 months using the Win32_QuickFixEngineering WMI class.
   It filters the updates based on the installation date and selects the HotFixID, Description, and InstalledOn properties for each update.
   The function then formats the output as a table displaying the selected properties.

.AUTHOR
   Lance Mohesky

.DATE
   04/18/2024

.EXAMPLE
   Get-RecentWindowsUpdates

   HotFixID  Description                                             InstalledOn
   --------  -----------                                             -----------
   KB4565351 Security Update                                         5/12/2024 12:00:00 AM
   KB4566782 Update                                                  5/13/2024 12:00:00 AM
   KB4567523 Security Update                                         5/15/2024 12:00:00 AM
#>

function Get-RecentWindowsUpdates {
    # Calculate the date 3 months ago from the current date
    $startDate = (Get-Date).AddMonths(-3)

    # Retrieve the Windows Updates using the Win32_QuickFixEngineering WMI class
    # Filter the updates to include only those installed on or after the $startDate
    $updates = Get-WmiObject -Class "Win32_QuickFixEngineering" | 
               Where-Object { $_.InstalledOn -ge $startDate }

    # Create a custom object for each update, selecting the desired properties
    $updateList = foreach ($update in $updates) {
        [PSCustomObject]@{
            HotFixID = $update.HotFixID
            Description = $update.Description
            InstalledOn = $update.InstalledOn
        }
    }

    # Format the output as a table with automatically adjusted column widths
    $updateList | Format-Table -AutoSize
}
