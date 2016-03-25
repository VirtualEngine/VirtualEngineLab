configuration vExchange2013ADPrep {
    param (
        ## AD Schema Admin/Enterprise Admin credential
        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential] $Credential,
        
        ## Path to Exchange 2013 setup.exe
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()]
        [System.String] $Path,
        
        ## Exchange organization name
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()]
        [System.String] $OrganizationName
    )
    
    Import-DscResource -ModuleName xPSDesiredStateConfiguration;

    $registryKey = 'Software\VirtualEngine';
    $forestPrepValue = 'ExchangeForestPrep';
    $domainPrepValue = 'ExchangeDomainPrep';

    xPackage 'ExchangeForestPrep' {
        Name = 'Exchange Forest Prep';
        ProductId = '';
        Path = $Path;
        Arguments = '/PrepareSchema /IAcceptExchangeServerLicenseTerms';
        RunAsCredential = $Credential;
        ReturnCode = 0;
        InstalledCheckRegKey = $registryKey;
        InstalledCheckRegValueName = $forestPrepValue;
        InstalledCheckRegValueData = 'True';
        CreateCheckRegValue = $true; ## NOTE: Requires resource that implements issue #46
    }

    xPackage 'ExchangeDomainPrep' {
        Name = 'Exchange Domain Prep';
        ProductId = '';
        Path = $Path;
        Arguments = '/PrepareAD /OrganizationName:"{0}" /IAcceptExchangeServerLicenseTerms' -f $OrganizationName;
        RunAsCredential = $Credential;
        ReturnCode = 0;
        InstalledCheckRegKey = $registryKey;
        InstalledCheckRegValueName = $domainPrepValue;
        InstalledCheckRegValueData = 'True';
        DependsOn = '[xPackage]ExchangeForestPrep';
        CreateCheckRegValue = $true; ## NOTE: Requires resource that implements issue #46
    }
    
} #end configuration vExchange2013ADPrep
