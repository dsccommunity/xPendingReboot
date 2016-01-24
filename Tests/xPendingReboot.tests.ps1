<# 
.summary
    Test suite for MSFT_xPendingReboot.psm1
#>
[CmdletBinding()]
param()


Import-Module $PSScriptRoot\..\DSCResources\MSFT_xPendingReboot\MSFT_xPendingReboot.psm1 -Force

$ErrorActionPreference = 'stop'
Set-StrictMode -Version latest

Describe 'Get-TargetResource' {
    Context "All Reboots Are Required" {
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
            return @{ ComputerName = "box2" }
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

        It "All methods should have returned pending reboots" {
            $value = Get-TargetResource -Name "Test"
            
            $value.ComponentBasedServicing | Should Be $true
            $value.WindowsUpdate | Should Be $true
            $value.PendingFileRename | Should Be $true
            $value.PendingComputerRename | Should Be $true
            $value.CcmClientSDK | Should Be $true
        }
    }
    
    Context "No Reboots Are Required" {
        # Used by ComponentBasedServicing
        Mock Get-ChildItem {
            return @{ }
        } -ParameterFilter { $Path -eq 'hklm:SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\' }

        # Used by WindowsUpdate
        Mock Get-ChildItem {
            return @{ } 
        } -ParameterFilter { $Path -eq 'hklm:SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\' }

        # Used by PendingFileRename
        Mock Get-ItemProperty {
            return @{ }
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

        It "All methods should have returned pending reboots" {
            $value = Get-TargetResource -Name "Test"

            $value.ComponentBasedServicing | Should Be $false
            $value.WindowsUpdate | Should Be $false
            $value.PendingFileRename | Should Be $false
            $value.PendingComputerRename | Should Be $false
            $value.CcmClientSDK | Should Be $false
        }
    }
}

Describe 'Test-TargetResource' {
    Context "All Reboots Are Required" {
        # Used by ComponentBasedServicing
        Mock Get-TargetResource -ModuleName "MSFT_xPendingReboot" {
            return @{
            Name = $Name
            ComponentBasedServicing = $true
            WindowsUpdate = $true
            PendingFileRename = $true
            PendingComputerRename = $true
            CcmClientSDK = $true
            }
        }

        It "All Reboots are Skipped" {
            $result = Test-TargetResource -Name "Test" -SkipComponentBasedServicing $true -SkipWindowsUpdate $true -SkipPendingFileRename $true -SkipPendingComputerRename $true -SkipCcmClientSDK $true

            $result | Should Be $true
        }

        It "No Reboots are Skipped" {
            $result = Test-TargetResource -Name "Test" -SkipComponentBasedServicing $false -SkipWindowsUpdate $false -SkipPendingFileRename $false -SkipPendingComputerRename $false -SkipCcmClientSDK $false

            $result | Should Be $false
        }
    }
}
