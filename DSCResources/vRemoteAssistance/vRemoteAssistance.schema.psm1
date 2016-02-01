configuration vRemoteAssistance {
    param (
        [Parameter()] [ValidateSet('Present','Absent')] [System.String] $Ensure = 'Present',
        [Parameter()] [System.Boolean] $EnableFirewallException = $true
    )

    Import-DscResource -ModuleName xNetworking;

    WindowsFeature RemoteAssistance {
        Name = 'Remote-Assistance';
        Ensure = 'Present';
    }

    if ($EnableFirewallException -eq $true) {
        xFirewall RemoteDesktopShadowInTCP {
            Name = 'RemoteDesktop-Shadow-In-TCP';
            DisplayName = 'Remote Desktop - Shadow (TCP-In)';
            Action = 'Allow';
            Profile = 'Any';
            Enabled = $true;
        }
    }

}