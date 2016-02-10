configuration vRemoteDesktopLicensing {
    param (
        [Parameter()]
        [System.Boolean] $InstallRDSLicensingUI = $true;
    )
    
    Import-DscResource -ModuleName PSDesiredStateConfiguration;
    
    WindowsFeature RDSLicensing {
        Name = 'RDS-Licensing';
    }
    
    if ($InstallRDSLicensingUI) {
        WindowsFeature RDSLicensingUI {
            Name = 'RDS-Licensing-UI';
        }
    }

} #end configuration vRemoteDesktopLicensing
