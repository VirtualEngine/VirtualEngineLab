configuration vExchange2013 {
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
        [System.String] $OrganizationName
    )

    Import-DscResource -Module xPSDesiredStateConfiguration, xPendingReboot;
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

} #end configuration vExchange2013
