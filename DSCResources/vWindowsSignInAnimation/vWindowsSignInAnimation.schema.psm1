configuration vWindowsSignInAnimation {
<#
    .SYNOPSIS
        Enables or disables Windows 8/10 sign-in animations
#>
    param (
        [Parameter(Mandatory)] [ValidateSet('Enabled','Disabled')]
        [System.String] $State
    )
    
    Import-DSCResource -ModuleName PSDesiredStateConfiguration;
    
    Registry 'EnableFirstLogonAnimation' {
        Key = 'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System';
        ValueName = 'EnableFirstLogonAnimation';
        ValueData = (($State -eq 'Enabled') -as [int]) -as [string];
        ValueType = 'Dword';
        Ensure = 'Present';
    }
    
} #end configuration vWindowsSignInAnimation
