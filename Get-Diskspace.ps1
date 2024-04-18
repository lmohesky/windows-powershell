<#
    .SYNOPSIS
    Produces total disk size and free space.

    .DESCRIPTION
    This function retrieves disk space information using WMI and calculates the total disk size and free space for each logical disk on the specified computer.

    .PARAMETER Computer
    The name of the computer for which to retrieve disk space information.

    .EXAMPLE
    Get-Diskspace -Computer "Server01"
    Retrieves disk space information for the computer named "Server01".

    .NOTES
    Author: Lance Mohesky
    Created on: 08/20/2023
#>

function Get-Diskspace {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Computer
    )

    $Diskspace = Get-WmiObject -Class "Win32_LogicalDisk" -Namespace "root\CIMV2" -ComputerName $Computer
    $Output = foreach ($Disk in $Diskspace) {
        if ($Disk.Size -gt 0) {
            $Size = [math]::Round($Disk.Size / 1GB, 0)
            $Free = [math]::Round($Disk.FreeSpace / 1GB, 0)
            [PSCustomObject]@{
                Drive              = $Disk.Name
                Name               = $Disk.VolumeName
                "Total Disk Space" = $Size
                "Free Disk Size"   = "{0:N0} ({1:P0})" -f $free, ($free / $size)
            }
        }
    }

    $Output
}
