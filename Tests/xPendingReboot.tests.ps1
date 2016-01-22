<# 
.summary
    Test suite for MSFT_xPendingReboot.psm1
#>
[CmdletBinding()]
param()


Import-Module $PSScriptRoot\..\DSCResources\MSFT_xPendingReboot\MSFT_xPendingReboot.psm1

$ErrorActionPreference = 'stop'
Set-StrictMode -Version latest

Describe 'Test-TargetResource' {
    Context "All Reboots Are Required; None Are Skipped" {
    
        # Used by ComponentBasedServicing
        Mock Get-ChildItem {
            return @{ Name = 'RebootPending' }
        } -ParameterFilter { $Path -eq 'hklm:SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\' }

        # Used by WindowsUpdate
        Mock Get-ChildItem {
            return @{ Name = 'RebootRequired' } 
        } -ParameterFilter { $Path -eq 'hklm:SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\' }

        # Used by PendingFileRename
        Mock Get-ItemProperty {
            return @{ PendingFileRenameOperations= @("File1", "File2") }
        } -ParameterFilter { $Path -eq 'hklm:\SYSTEM\CurrentControlSet\Control\Session Manager\' }

         # Used by PendingComputerRename
        Mock Get-ItemProperty {
            return @{ ComputerName = "box" }
        } -ParameterFilter { $Path -eq 'hklm:\SYSTEM\CurrentControlSet\Control\ComputerName\ActiveComputerName' }

        Mock Get-ItemProperty {
            return @{ ComputerName = "box" }
        } -ParameterFilter { $Path -eq 'hklm:\SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName' }

        Mock Invoke-WmiMethod {
            return New-Object PSObject -Property
                @{
                    ReturnValue = 0
                    IsHardRebootPending = $false
                    RebootPending = $true
                }
        }

        It "A reboot should have been triggered" {
            $result = Test-TargetResource -Name "Test"

            $result | Should Be $false
        }
    }
}
