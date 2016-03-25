configuration vCitrixReceiver {
    param (
        ## Path to Citrix Receiver installation exe
        [Parameter(Mandatory)] [ValidateNotNull()]
        [System.String] $Path,
        
        ## Path to Citrix Receiver installation exe
        [Parameter()] [ValidateNotNull()]
        [System.Boolean] $AllowUnsecureTraffic
        
    )
 
    # Import the module that defines custom resources
    Import-DscResource -ModuleName xPSDesiredStateConfiguration;

    xPackage 'CitrixReceiver' {
        Name = 'Citrix Receiver';
        ProductId = '';
        Path = $Path;
        Arguments = '/noreboot /silent';
        ReturnCode = 0;
        InstalledCheckRegKey = 'Software\Citrix\Install\ICA Client';
        InstalledCheckRegValueName = 'InstallFolder';
        InstalledCheckRegValueData = 'C:\Program Files (x86)\Citrix\ICA Client\';
    }
    
    if ($AllowUnsecureTraffic) {
        
        Registry 'AllowSavePwd' {
            Key = 'HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Citrix\Dazzle'
            ValueName = 'AllowAddStore';
            ValueData = 'A';
            ValueType = 'String';
            Ensure = 'Present';
            DependsOn = '[xPackage]CitrixReceiver';
        }
        
        Registry 'ConnectionSecurityMode' {
            Key = 'HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Citrix\AuthManager';
            ValueName = $valueName;
            ValueData = 'Any';
            ValueType = 'String';
            Ensure = 'Present';
            DependsOn = '[xPackage]CitrixReceiver';
        }
        
    }

} #end configuration vCitrixReceiver
