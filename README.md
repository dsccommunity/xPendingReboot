# **THIS MODULE HAS BEEN DEPRECATED**

It will no longer be released.
Please use the 'PendingReboot' resource in [ComputerManagementDsc](https://github.com/dsccommunity/ComputerManagementDsc)
instead.

# xPendingReboot

[![Build status](https://ci.appveyor.com/api/projects/status/25n3uaum4x6cv4dg/branch/master?svg=true)](https://ci.appveyor.com/project/PowerShell/xpendingreboot/branch/master)

The **xPendingReboot** contains the **xPendingReboot** DSC resource.
xPendingReboot examines three specific registry locations where a Windows Server might indicate that a reboot is pending and allows DSC to predictably handle the condition.

Note: The expectation is that this resource will be used in conjunction with knowledge of DSC Local Configuration Manager, which has the ability to manage whether reboots happen automatically using the RebootIfNeeded parameter.
For more information on configuring the LCM, please reference [this TechNet article](https://technet.microsoft.com/en-us/library/dn249922.aspx).

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

## Contributing

Please check out common DSC Resources [contributing guidelines](https://github.com/PowerShell/DscResources/blob/master/CONTRIBUTING.md).

## Description

The **xPendingReboot** module containes the **xPendingReboot** resource, which examines three specific registry locations where a Windows Server might indicate that a reboot is pending, and allows DSC to predictably handle the condition.
DSC determines how to handle pending reboot conditions using the Local Configuration Management (LCM) setting RebootNodeIfNeeded.
When DSC resources require reboot, within a Set statement in a DSC Resource the global variable DSCMachineStatus is set to value '1'.
When this condition occurs and RebootNodeIfNeeded is set to 'True', DSC reboots the machine after a successful Set.
Otherwise, the reboot is postponed.

## Resources

### xPendingReboot

Details for all read-only properties are returned by Get-DscConfiguration

* **Name**: Required parameter that must be unique per instance of the resource within a configuration.
* **ComponentBasedServicing**: (Read-only) One of the locations that are examined by the resource.
* **SkipComponentBasedServicing**: (Write) Skip reboots triggered by the Component-Based Servicing component.
* **WindowsUpdate**: (Read-only) One of the locations that are examined by the resource.
* **SkipWindowsUpdate**: (Write) Skip reboots triggered by Windows Update.
* **PendingFileRename**: (Read-only) One of the locations that are examined by the resource.
* **SkipPendingFileRename**: (Write) Skip pending file rename reboots.
* **PendingComputerRename**: (Read-only) One of the locations that are examined by the resource.
* **SkipCcmClientSDK**: (Write) Skip reboots triggered by the ConfigMgr client
* **CcmClientSDK**: (Read-only) One of the locations that are examined by the resource.

## Versions

### Unreleased

* THIS MODULE HAS BEEN DEPRECATED. It will no longer be released.
  Please use the 'PendingReboot' resource in ComputerManagementDsc instead.
* Correct path to ComputerManagementDsc resource in README.MD.
* Update appveyor.yml to use the default template.
* Added default template files .codecov.yml, .gitattributes, and .gitignore, and
  .vscode folder.

### 0.4.0.0

* Converted appveyor.yml to install Pester from PSGallery instead of from Chocolatey.
* Fixes registry not being evaluated correctly.
* Fixes failing tests introduced in changes to Pester 4.
* Change layout of parameters to compile with style guide.

### 0.3.0.0

* Suppresses warning output in Test-TargetResource when 'SkipCcmClientSDK' is specified.
* Fixes 'Null-valued expression' bug when 'Auto Update' or 'Component Based Servicing' registry keys are empty.

### 0.2.0.0

* Added parameters which allow you to skip reboots triggered by the individual components. For example, you can choose not to
    reboot if Windows Update requested a reboot.

### 0.1.0.2

* Documentation changes:
  * Added information on PendingComputerRename and CcmClientSdk.

### 0.1.0.1

* Update with improvements to the Test-TargetResource function and how pending reboots are detected.

### 0.1.0.0

* Initial release with the following resources
  * xPendingReboot

## Examples

### Identify if reboots are pending and, if so, reboot immediately (managed by DSC)

This configuration leverages xPendingReboot and sets the LCM setting to allow automatic reboots.

```powershell
Configuration CheckForPendingReboot
{
    Node 'NodeName'
    {
        xPendingReboot Reboot1
        {
            Name = 'BeforeSoftwareInstall'
        }
        LocalConfigurationManager
        {
            RebootNodeIfNeeded = $True
        }
    }
}
```

### Identify if reboots are pending but do not automatically reboot (managed by DSC)

This configuration leverages xPendingReboot and sets the LCM setting to disallow automatic reboots.

```powershell
Configuration CheckForPendingReboot
{
    Node 'NodeName'
    {
        xPendingReboot Reboot1
        {
            Name = 'BeforeSoftwareInstall'
        }
        LocalConfigurationManager
        {
            RebootNodeIfNeeded = 'False'
        }
    }
}
```
