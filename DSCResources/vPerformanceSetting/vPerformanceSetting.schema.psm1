configuration vPerformanceSetting {
    param (
        ## System Power Plan to configure
        [Parameter()] [ValidateNotNull()]
        [System.String] $PowerPlan,

        ## Drives to disable system restore upon
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String[]] $DisabledSystemRestoreDrive,

        ## Disables default Windows Explorer visual effects
        [Parameter()]
        [System.Boolean] $DisableVisualEffects,

        ## Disables Windows login animations
        [Parameter()]
        [System.Boolean] $DisableLogonAnimation,

        ## Disables Windows 8 help tips
        [Parameter()]
        [System.Boolean] $DisableHelpTips,

        ## Disable Server Manager on logon
        [Parameter()]
        [System.Boolean] $DisableServerManager,

        ## Disables lock screen and lock screen background images
        [Parameter()]
        [System.Boolean] $DisableLockScreenBackground,

        ## Disables network discovery location wizard
        [Parameter()]
        [System.Boolean] $DisableNetworkLocationWizard
    )
 
    # Import the module that defines custom resources
    Import-DscResource -ModuleName xWindowsRestore, ComputerManagementDsc, PSDesiredStateConfiguration;

    if ($PSBoundParameters.ContainsKey('PowerPlan')) {
        PowerPlan 'PowerPlan' {
            IsSingleInstance = 'Yes';
            Name             = $PowerPlan;
        }
    }

    if ($PSBoundParameters.ContainsKey('DisabledSystemRestoreDrive')) {
        xSystemRestore 'SystemRestore' {
            Drive  = $DisabledSystemRestoreDrive;
            Ensure = 'Absent';
        }
    }

    if ($PSBoundParameters.ContainsKey('DisableHelpTips')) {
        Registry 'DisableHelpSticker' {
            Key       = 'HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\EdgeUI';
            ValueName = 'DisableHelpSticker';
            ValueData = $DisableHelpTips -as [System.Int32];
            ValueType = 'Dword';
            Ensure    = 'Present';
        }
    }

    if ($PSBoundParameters.ContainsKey('DisableLogonAnimation')) {
        Registry 'EnableFirstLogonAnimation' {
            Key       = 'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System';
            ValueName = 'EnableFirstLogonAnimation';
            ValueData = (-not $DisableLogonAnimation) -as [System.Int32];
            ValueType = 'Dword';
            Ensure    = 'Present';
        }
    }

    if ($PSBoundParameters.ContainsKey('DisableServerManager')) {
        Registry 'ServerManager' {
            Key       = 'HKEY_LOCAL_MACHINE\Software\Microsoft\ServerManager';
            ValueName = 'DoNotOpenServerManagerAtLogon';
            ValueData =  $DisableServerManager -as [System.Int32];
            ValueType = 'Dword';
            Ensure    = 'Present';
        }
    }

    if ($DisableVisualEffects) {

        $visualEffects = @(
            @{ Key = 'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects'; ValueName = 'VisualFXSetting'; ValueType = 'DWORD'; ValueData = '3'; }
            @{ Key = 'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\AnimateMinMax'; ValueName = 'DefaultValue'; ValueType = 'DWORD'; ValueData = '0'; }
            @{ Key = 'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\ComboBoxAnimation'; ValueName = 'DefaultValue'; ValueType = 'DWORD'; ValueData = '0'; }
            @{ Key = 'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\ControlAnimations'; ValueName = 'DefaultValue'; ValueType = 'DWORD'; ValueData = '0'; }
            @{ Key = 'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\CursorShadow'; ValueName = 'DefaultValue'; ValueType = 'DWORD'; ValueData = '0'; }
            @{ Key = 'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\DragFullWindows'; ValueName = 'DefaultValue'; ValueType = 'DWORD'; ValueData = '0'; }
            @{ Key = 'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\DropShadow'; ValueName = 'DefaultValue'; ValueType = 'DWORD'; ValueData = '0'; }
            @{ Key = 'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\DWMAeroPeekEnabled'; ValueName = 'DefaultValue'; ValueType = 'DWORD'; ValueData = '0'; }
            @{ Key = 'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\DWMEnabled'; ValueName = 'DefaultValue'; ValueType = 'DWORD'; ValueData = '0'; }
            @{ Key = 'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\DWMSaveThumbnailEnabled'; ValueName = 'DefaultValue'; ValueType = 'DWORD'; ValueData = '0'; }
            @{ Key = 'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\FontSmoothing'; ValueName = 'DefaultValue'; ValueType = 'DWORD'; ValueData = '1'; }
            @{ Key = 'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\ListBoxSmoothScrolling'; ValueName = 'DefaultValue'; ValueType = 'DWORD'; ValueData = '0'; }
            @{ Key = 'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\ListviewAlphaSelect'; ValueName = 'DefaultValue'; ValueType = 'DWORD'; ValueData = '0'; }
            @{ Key = 'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\ListviewShadow'; ValueName = 'DefaultValue'; ValueType = 'DWORD'; ValueData = '1'; }
            @{ Key = 'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\MenuAnimation'; ValueName = 'DefaultValue'; ValueType = 'DWORD'; ValueData = '0'; }
            @{ Key = 'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\SelectionFade'; ValueName = 'DefaultValue'; ValueType = 'DWORD'; ValueData = '0'; }
            @{ Key = 'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\TaskbarAnimations'; ValueName = 'DefaultValue'; ValueType = 'DWORD'; ValueData = '0'; }
            @{ Key = 'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\Themes'; ValueName = 'DefaultValue'; ValueType = 'DWORD'; ValueData = '1'; }
            @{ Key = 'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\ThumbnailsOrIcon'; ValueName = 'DefaultValue'; ValueType = 'DWORD'; ValueData = '0'; }
            @{ Key = 'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\TooltipAnimation'; ValueName = 'DefaultValue'; ValueType = 'DWORD'; ValueData = '0'; }
            @{ Key = 'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\TransparentGlass'; ValueName = 'DefaultValue'; ValueType = 'DWORD'; ValueData = '0'; }
        )

        foreach ($registrySetting in $visualEffects) {
            $resourceId = ($registrySetting.Key).Split('\')[-1];
            Registry $resourceId {
                Key       = $registrySetting.Key;
                ValueName = $registrySetting.ValueName;
                ValueType = $registrySetting.ValueType;
                ValueData = $registrySetting.ValueData;
                Ensure    = 'Present';
            }
        } #end foreach registry setting

    } #end if Disable Visual Effects

    if ($DisableLockScreenBackground) {
        Registry 'NoLockScreen' {
            Key       = 'HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Personalization';
            ValueName = 'NoLockScreen';
            ValueData = $DisableLockScreenBackground -as [System.Int32];
            ValueType = 'Dword';
            Ensure    = 'Present';
        }

        Registry 'DisableLogonBackgroundImage' {
            Key       = 'HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\System';
            ValueName = 'DisableLogonBackgroundImage';
            ValueData = $DisableLockScreenBackground -as [System.Int32];
            ValueType = 'Dword';
            Ensure    = 'Present';
        }
    }

    if ($DisableNetworkLocationWizard) {
        Registry 'NewNetworkWindowOff' {
            Key       = 'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Network\NetworkLocationWizard';
            ValueName = 'HideWizard';
            ValueData = -not $DisableNetworkLocationWizard -as [System.Int32];
            ValueType = 'Dword';
        }
    }

} #end configuration vPerformanceSettings
