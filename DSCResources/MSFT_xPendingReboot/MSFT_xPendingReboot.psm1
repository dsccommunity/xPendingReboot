[DscResource()]

class xPendingReboot {
    [DscProperty(Key)]
    [string]$Name

    [DscProperty()]
    [boolean]$SkipComponentBasedServicing
    [DscProperty(NotConfigurable)]
    [boolean]$ComponentBasedServicing

    [DscProperty()]
    [boolean]$SkipWindowsUpdate
    [DscProperty(NotConfigurable)]
    [boolean]$WindowsUpdate

    [DscProperty()]
    [boolean]$SkipPendingFileRename
    [DscProperty(NotConfigurable)]
    [boolean]$PendingFileRename

    [DscProperty()]
    [boolean]$SkipPendingComputerRename
    [DscProperty(NotConfigurable)]
    [boolean]$PendingComputerRename

    [DscProperty()]
    [boolean]$SkipCcmClientSDK
    [DscProperty(NotConfigurable)]
    [boolean]$CcmClientSDK

    [xPendingReboot] Get() {
        $ComponentBasedServicingKeys = (Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\').Name

        $this.ComponentBasedServicing = $ComponentBasedServicingKeys -Split "\\" -contains "RebootPending"

        $WindowsUpdateKeys = (Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\').Name

        $this.WindowsUpdate = $WindowsUpdateKeys -Split "\\" -contains "RebootRequired"

        $this.PendingFileRename = (Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\').PendingFileRenameOperations.Length -gt 0
        $ActiveComputerName = (Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\ComputerName\ActiveComputerName').ComputerName
        $PendingComputerName = (Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName').ComputerName
        $this.PendingComputerRename = $ActiveComputerName -ne $PendingComputerName

        if (-not $this.SkipCcmClientSDK) {
            $CCMSplat = @{
                NameSpace   = 'ROOT\ccm\ClientSDK'
                Class       = 'CCM_ClientUtilities'
                Name        = 'DetermineIfRebootPending'
                ErrorAction = 'Stop'
            }
            $this.CcmClientSDK = $(
                Try {
                    Invoke-WmiMethod @CCMSplat
                }
                Catch {
                    Write-Warning "Unable to query CCM_ClientUtilities: $_"
                }
            ) | ForEach-Object {(($_.ReturnValue -eq 0) -and ($_.IsHardRebootPending -or $_.RebootPending))}
        } #CCM_ClientUtilities querey

        return $this
    }
    Set() {
        Set-Variable -Name DSCMachineStatus -Scope Global -Value 1
    }
    [bool] Test() {
        $status = $this.Get()
        $Now = [datetime]::Now
        $RebootsFound = $false

        @(
            @('ComponentBasedServicing', 'Pending component based servicing reboot found.'),
            @('WindowsUpdate', 'Pending Windows Update reboot found.'),
            @('PendingFileRename', 'Pending file rename found.'),
            @('PendingComputerRename', 'Pending computer rename found.')
        ) | ForEach-Object {
            if (-not ($this[( -join ('Skip', $_[0]))]) -and $Status[$_[0]]) {
                Write-Verbose $_[1]
                Set-Variable -Name RebootsFound -Value $true
            }
        }
        if (-not $RebootsFound) {
            Write-Verbose 'No pending reboots found.'
            return $true
        }
        else {
            Write-Verbose 'Initiating Pending Reboots'
            return $false
        }
    }
}