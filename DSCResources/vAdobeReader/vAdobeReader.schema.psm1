configuration vAdobeReader {
    param (
        ## Path to Adobe Reader DC installation exe
        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [System.String] $Path,

        [Parameter(Mandatory)]
        [ValidateSet('XI','DC')]
        [System.String] $Version,

        ## Override the package name used to check for product installation
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String] $ProductName
    )

    # Import the module that defines custom resources
    Import-DscResource -ModuleName PSDesiredStateConfiguration, xPSDesiredStateConfiguration;

    switch ($Version) {
        'XI' {
            $productDisplayName = 'Adobe Acrobat Reader XI'; # Adobe Reader XI (11.0.10)
            $versionString = '11.0';
        }
        'DC' {
            $productDisplayName = 'Adobe Acrobat Reader DC';
            $versionString = 'DC';
        }
    }

    ## If we have explicitly defined a package display name, use that!
    if ($PSBoundParameters.ContainsKey('ProductName')) {
        $productDisplayName = $ProductName;
    }

    xPackage 'AdobeReader' {
        Name = $productDisplayName;
        ProductId = '';
        Path = $Path;
        Arguments = '/sAll /msi /norestart /quiet ALLUSERS=1 EULA_ACCEPT=YES ENABLE_CACHE_FILES=NO ENABLE_OPTIMIZATION=NO';
        ReturnCode = 0;
        InstalledCheckRegKey = 'Software\Wow6432Node\Adobe\Acrobat Reader\{0}\Installer' -f $versionString;
        InstalledCheckRegValueName = 'Path';
        InstalledCheckRegValueData = 'C:\Program Files (x86)\Adobe\Reader {0}\' -f $versionString;
    }

    ## FeatureLockdown : DWORD 0
    foreach ($valueName in 'bUpdater','bUsageMeasurement','bPurchaseAcro') {
        Registry "FeatureLockdown_$valueName" {
            Key = 'HKEY_LOCAL_MACHINE\Software\Wow6432Node\Policies\Adobe\Acrobat Reader\{0}\FeatureLockdown' -f $versionString;
            ValueName = $valueName;
            ValueData = '0';
            ValueType = 'Dword';
            Ensure = 'Present';
            DependsOn = '[xPackage]AdobeReader';
        }
    } #end foreach \xx\FeatureLockdown

    ## FeatureLockdown : DWORD 1
    foreach ($valueName in 'bCommercialPDF') {
        Registry "FeatureLockdown_$valueName" {
            Key = 'HKEY_LOCAL_MACHINE\Software\Wow6432Node\Policies\Adobe\Acrobat Reader\{0}\FeatureLockdown' -f $versionString;
            ValueName = $valueName;
            ValueData = '1';
            ValueType = 'Dword';
            Ensure = 'Present';
            DependsOn = '[xPackage]AdobeReader';
        }
    } #end foreach \xx\FeatureLockdown

    ## cServices : DWORD 0
    foreach ($valueName in 'bUpdater','bToggleAdobeDocumentServices','bTogglePrefsSync','bEnableSignPane') {
        Registry "cServices_$valueName" {
            Key = 'HKEY_LOCAL_MACHINE\Software\Wow6432Node\Policies\Adobe\Acrobat Reader\{0}\FeatureLockdown\cServices' -f $versionString;
            ValueName = $valueName;
            ValueData = '0';
            ValueType = 'Dword';
            Ensure = 'Present';
            DependsOn = '[xPackage]AdobeReader';
        }
    } #end foreach \xx\FeatureLockdown\cServices

} #end configuration vAdobeReader
