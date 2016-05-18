configuration vWindowsHelpTips {
<#
    .SYNOPSIS
        Enables or disables Windows 8/10 help tips/animations
#>
    param (
        [Parameter(Mandatory)] [ValidateSet('Enable','Disable')]
        [System.String] $State
    )
    
    Import-DSCResource -ModuleName PSDesiredStateConfiguration;
    
    Registry 'DisableHelpSticker' {
        Key = 'HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\EdgeUI';
        ValueName = 'DisableHelpSticker';
        ValueData = (($State -eq 'Disabled') -as [int]) -as [string];
        ValueType = 'Dword';
        Ensure = 'Present';
    }
    
} #end configuration vWindowsHelpTips
