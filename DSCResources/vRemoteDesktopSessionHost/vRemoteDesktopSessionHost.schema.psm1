configuration vRemoteDesktopSessionHost {
    param (
        ## RDS license server
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()]
        [System.String] $RDSLicenseServer,
        
        ## Users/groups to add to the local Remote Desktop Users group
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String[]] $RemoteDesktopUsers = 'S-1-5-11', # Authenticated Users
        
         ## Credential to access Active Directory for user/group enumeration
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential] $Credential,
        
        [Parameter()]
        [System.Boolean] $InstallRemoteAssistance = $true,
        
        [Parameter()]
        [System.Boolean] $InstallDesktopExperience = $true
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration;

    WindowsFeature 'RDS-RD-Server' {
        Name = 'RDS-RD-Server';
        Ensure = 'Present';
    }
    
    if ($InstallRemoteAssistance) {
        WindowsFeature 'Remote-Assistance' {
            Name = 'Remote-Assistance';
            Ensure = 'Present';
        }
    }
    
    if ($InstallDesktopExperience) {
        WindowsFeature 'Desktop-Experience' {
            Name = 'Desktop-Experience';
            Ensure = 'Present';
        }
    }
        
    if ($PSBoundParameters.ContainsKey('Credential')) {
        Group 'RemoteDesktopUsers' {
            GroupName = 'Remote Desktop Users';
            MembersToInclude = $RemoteDesktopUsers;
            Ensure = 'Present';
            Credential = $Credential;
        }
    }
    else {
        Group 'RemoteDesktopUsers' {
            GroupName = 'Remote Desktop Users';
            MembersToInclude = $RemoteDesktopUsers;
            Ensure = 'Present';
        }
    }

    Registry 'RDSLicenseServer' {
        Key = 'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\TermService\Parameters\LicenseServers';
        ValueName = 'SpecifiedLicenseServers';
        ValueData = $RDSLicenseServer;
        ValueType = 'MultiString';
    }

    Registry 'RDSLicensingMode' {
        Key = 'HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Terminal Server\RCM\Licensing Core';
        ValueName = 'LicensingMode';
        ValueData = '4'; # 2 = Per Device, 4 = Per User
        ValueType = 'Dword';
    }

} #end configuratino vRemoteDesktopSessionHost
