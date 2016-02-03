configuration vAdobeReader {
    param (
        ## Path to Adobe Reader DC installation exe
        [Parameter(Mandatory)] [ValidateNotNull()]
        [System.String] $Path,
        
        [Parameter(Mandatory)] [ValidateSet('XI','DC')]
        [System.String] $Version
    )
 
    # Import the module that defines custom resources
    Import-DscResource -Module PSDesiredStateConfiguration, xPSDesiredStateConfiguration;

    switch ($Version) {
        'XI' {
            $productName = 'Adobe Acrobat Reader XI';
            $versionString = '11.0';
        }
        'DC' {
            $productName = 'Adobe Acrobat Reader DC';
            $versionString = 'DC';
        }
    }

    xPackage AdoberReader {
        Name = $productName;
        ProductId = '';
        Path = $Path;
        Arguments = '/sAll /msi /norestart /quiet ALLUSERS=1 EULA_ACCEPT=YES';
        ReturnCode = 0;
        InstalledCheckRegKey = 'Software\Wow6432Node\Adobe\Acrobat Reader\{0}\Installer' -f $versionString;
        InstalledCheckRegValueName = 'Path';
        InstalledCheckRegValueData = 'C:\Program Files (x86)\Adobe\Reader {0}\' -f $versionString;
    }
    
    foreach ($valueName in 'bUpdater','bUsageMeasurement') {
        Registry $valueName {
            Key = 'HKEY_LOCAL_MACHINE\Software\Wow6432Node\Policies\Adobe\Acrobat Reader\{0}\FeatureLockdown' -f $versionString;
            ValueName = $valueName;
            ValueData = '0';
            ValueType = 'Dword';
            Ensure = 'Present';
            DependsOn = '[xPackage]AdoberReader';
        }
    } #end foreach \DC\FeatureLockdown
    
    if ($Version -eq 'DC') {
        foreach ($valueName in 'bToggleAdobeDocumentServices','bTogglePrefsSync') {
            Registry $valueName {
                Key = 'HKEY_LOCAL_MACHINE\Software\Wow6432Node\Policies\Adobe\Acrobat Reader\{0}\FeatureLockdown\cServices' -f $versionString;
                ValueName = $valueName;
                ValueData = '0';
                ValueType = 'Dword';
                Ensure = 'Present';
                DependsOn = '[xPackage]AdoberReader';
            }
        } #end foreach \DC\FeatureLockdown\cServices
    } #end if DC

} #end configuration vAdobeReader
