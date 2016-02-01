configuration vRemoteDesktopAdmin {
    param (
        [Parameter()] [ValidateSet('Present','Absent')]
        [System.String] $Ensure = 'Present',
        
        [Parameter()] [ValidateSet('Secure','NonSecure')]
        [System.String] $UserAuthentication = 'Secure',
        
        [Parameter()]
        [System.Boolean] $EnableFirewallException = $true,
        
        [Parameter()] [AllowNull()]
        [System.String[]] $MembersToInclude = $null,
        
        [Parameter()] [AllowNull()]
        [System.Management.Automation.PSCredential] $Credential = $null
    )

    Import-DscResource -ModuleName xRemoteDesktopAdmin;
    Import-DscResource -ModuleName xNetworking;

    if ($MembersToInclude) {
        Group vRemoteDesktopAdmin_RemoteDesktopUsers {
            GroupName = 'Remote Desktop Users';
            Ensure = $Ensure;
            MembersToInclude = $MembersToInclude;
            Credential = $Credential;
        }
    }

    xRemoteDesktopAdmin vRemoteDesktopAdmin_RemoteDesktopAdmin {
        Ensure = $Ensure;
        UserAuthentication = $UserAuthentication;
    }

    if ($EnableFirewallException -eq $true) {
        xFirewall RemoteDesktopUserModeInTCP {
            Name = 'RemoteDesktop-UserMode-In-TCP';
            DisplayName = 'Remote Desktop - User Mode (TCP-In)';
            Action = 'Allow';
            Enabled = $true;
        }

        xFirewall RemoteDesktopUserModeInUDP {
            Name = 'RemoteDesktop-UserMode-In-UDP';
            DisplayName = 'Remote Desktop - User Mode (UDP-In)';
            Action = 'Allow';
            Enabled = $true;
        }
    } #end if Enable Firewall

}
