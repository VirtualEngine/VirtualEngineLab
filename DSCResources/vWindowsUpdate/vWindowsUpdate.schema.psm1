configuration vWindowsUpdate {
    param (
        ## Windows Update categories to install
        [Parameter(Mandatory)] [ValidateSet('Security', 'Important', 'Optional')]
        [System.String[]] $Category,

        ## Windows Update agent notification
        [Parameter(Mandatory)] [ValidateSet('Disabled', 'ScheduledInstallation')]
        [System.String] $Notifications,

        ## Configure Microsoft Update
        [Parameter()]
        [System.Boolean] $UseMicrosoftUpdate,

        ## Force an installation of Windows Updates during consistency check
        [Parameter()]
        [System.Boolean] $UpdateNow
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration, xWindowsUpdate;

    Service 'WindowsUpdate' {
        Name = 'WUAUServ'
        StartupType = 'Manual';
    }

    if ($UseMicrosoftUpdate) {

        $updateSource = 'MicrosoftUpdate';
        xMicrosoftUpdate 'MicrosoftUpdate' {
            Ensure = 'Present';
        }

    }
    else {

        $updateSource = 'WindowsUpdate';
        xMicrosoftUpdate 'MicrosoftUpdate' {
            Ensure = 'Absent';
        }

    }

    xWindowsUpdateAgent 'WindowsUpdateAgent' {
        IsSingleInstance = 'Yes';
        Category         = $Category;
        Notifications    = $Notifications;
        Source           = $updateSource;
        UpdateNow        = $UpdateNow;
        DependsOn        = '[Service]WindowsUpdate','[xMicrosoftUpdate]MicrosoftUpdate'
    }

} #end configuration vWindowsUpdate
