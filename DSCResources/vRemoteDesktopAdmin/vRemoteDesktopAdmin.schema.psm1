configuration vRemoteDesktopAdmin {
    param (
        [Parameter()]
        [ValidateSet('Present','Absent')]
        [System.String] $Ensure = 'Present',

        ## Configuration Network Level Authentication
        [Parameter()]
        [ValidateSet('Secure','NonSecure')]
        [System.String] $UserAuthentication = 'Secure',

        ## Not supported on Windows 7 (use LegacyNetworking module)
        [Parameter()]
        [System.Boolean] $EnableFirewallException = $true,

        ## Members to include in the 'Remote Desktop Users; group
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String[]] $MembersToInclude,

        ## Domain credentials to enumerate domain groups
        [Parameter()]
        [ValidateNotNull()]
        [System.Management.Automation.PSCredential] $Credential
    )

    Import-DscResource -ModuleName xRemoteDesktopAdmin, xPSDesiredStateConfiguration, NetworkingDsc;

    if ($PSBoundParameters.ContainsKey('MembersToInclude')) {

        if ($PSBoundParameters.ContainsKey('Credential')) {

            xGroup 'RemoteDesktopUsers' {
                GroupName        = 'Remote Desktop Users';
                MembersToInclude = $MembersToInclude;
                Credential       = $Credential;
                Ensure           = $Ensure;
            }
        }
        else {

            xGroup 'RemoteDesktopUsers' {
                GroupName        = 'Remote Desktop Users';
                MembersToInclude = $MembersToInclude;
                Ensure           = $Ensure;
            }
        }
    }

    xRemoteDesktopAdmin 'RemoteDesktopAdmin' {
        UserAuthentication = $UserAuthentication;
        Ensure             = $Ensure;
    }

    if ($EnableFirewallException -eq $true) {

        Firewall 'RemoteDesktopUserModeInTCP' {
            Name        = 'RemoteDesktop-UserMode-In-TCP';
            DisplayName = 'Remote Desktop - User Mode (TCP-In)';
            Action      = 'Allow';
            Enabled     = ($Ensure -eq 'Present');
        }

        Firewall 'RemoteDesktopUserModeInUDP' {
            Name        = 'RemoteDesktop-UserMode-In-UDP';
            DisplayName = 'Remote Desktop - User Mode (UDP-In)';
            Action      = 'Allow';
            Enabled     = ($Ensure -eq 'Present');
        }
    } #end if Enable Firewall

} #end configuration vRemoteDesktopAdmin
