configuration vExchange2013Https {
    param (
        ## AD Schema Admin/Enterprise Admin credential
        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential] $Credential,
        
        ## Path to Exchange 2013 setup.exe
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()]
        [System.String] $Path,
        
        ## Path to Unified Communications Managed API 4 exe
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()]
        [System.String] $UCMAPath,
        
        ## Exchange organization name
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()]
        [System.String] $OrganizationName,
        
        # Personal information exchange (Pfx) ertificate file path
        [Parameter(Mandatory)]
        [System.String] $PfxCertificatePath,
        
        ## Pfx certificate thumbprint
        [Parameter(Mandatory)]
        [System.String] $PfxCertificateThumbprint,
        
        ## Pfx certificate password
        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential] $PfxCertificateCredential
    )

    Import-DscResource -Module xPSDesiredStateConfiguration, xPendingReboot, xExchange;
    ## Avoid recursive loading of the VirtualEngineLab composite module
    Import-DscResource -Name vExchange2013Prerequisites, vExchange2013ADPrep;

    vExchange2013Prerequisites 'ExchangePrerequisites' {
        UCMAPath = $UCMAPath;
    }

    vExchange2013ADPrep 'ExchangeADPrep' {
        Path = $Path;
        OrganizationName = $OrganizationName;
        Credential = $Credential;
    }

    xPendingReboot 'PendingRebootPreInstall' {
        Name = 'PreExchangeInstall';
        DependsOn = '[vExchange2013Prerequisites]ExchangePrerequisites','[vExchange2013ADPrep]ExchangeADPrep';
    }

    xPackage 'ExchangeInstall' {
        Name = 'Exchange 2013';
        ProductId = '{4934D1EA-BE46-48B1-8847-F1AF20E892C1}';
        Path = $Path;
        Arguments = '/mode:Install /role:Mailbox,ClientAccess /IAcceptExchangeServerLicenseTerms';
        RunAsCredential = $Credential;
        DependsOn = '[vExchange2013Prerequisites]ExchangePrerequisites','[vExchange2013ADPrep]ExchangeADPrep','[xPendingReboot]PendingRebootPreInstall';
    }
        
    xPendingReboot 'PendingRebootPostInstall' {
        Name = 'PostInstall';
        DependsOn = '[xPackage]ExchangeInstall'
    }
    
    xExchExchangeCertificate 'ExchangeCertificate' {
        Thumbprint = $PfxCertificateThumbprint;
        Credential = $Credential;
        CertCreds = $PfxCertificateCredential;
        CertFilePath = $PfxCertificatePath;
        Services = 'IIS','SMTP';
        Ensure = 'Present';
        DependsOn = '[xPackage]ExchangeInstall';
    }

} #end configuration vExchange2013Https
