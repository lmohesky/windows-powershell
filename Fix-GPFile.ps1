<#
.SYNOPSIS
    Deletes stale/corrupted Registry.pol file(s)
.DESCRIPTION
    If a workstation is having issues obtaining group policies, this will delete the corrupted Registry.pol file and run 'gpupdate /force'.
.EXAMPLE
    Example usage of the script:
    -----------------------------
    Fix-GPfile -ComputerName "RemotePCName"
.NOTES
    Author: Lance Mohesky
    Created: June 20, 2023
    Version: 1.0
#>
function Fix-GPFile {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ComputerName
    )

    $files = @("C:\Windows\System32\GroupPolicy\Machine\Registry.pol", "C:\Windows\System32\GroupPolicy\User\Registry.pol")
    
    # Use Invoke-Command for executing commands on the remote computer
    Invoke-Command -ComputerName $ComputerName -ScriptBlock {
        foreach ($file in $using:files) {
            if (Test-Path $file) {
                Remove-Item $file -ErrorAction SilentlyContinue
                if ($?) {
                    Write-Host "Deleted $file." -ForegroundColor Green
                }
                else {
                    Write-Host "Failed to delete $file." -ForegroundColor Red
                }
            }
            else {
                Write-Host "File $file does not exist." -ForegroundColor Yellow
            }
        }

        Write-Host "Running 'gpupdate /force'..." -ForegroundColor Green
        # Start gpupdate in a new process, wait for it, and print its output
        Start-Process -FilePath "gpupdate" -ArgumentList "/force" -NoNewWindow -Wait -PassThru
        Write-Host "'gpupdate /force' has finished." -ForegroundColor Green
    }
}
