configuration vExchange2013 {
    param (
        ## AD Schema Admin/Enterprise Admin credential
        [Parameter(Mandatory)] [PSCredential] $Credential,
        ## Path to Exchange 2013 setup.exe
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()] [System.String] $Path,
        ## Path to Unified Communications Managed API 4 exe
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()] [System.String] $UCMAPath,
        ## Exchange organization name
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()] [System.String] $OrganizationName
    )

    Import-DscResource -Module xPSDesiredStateConfiguration, xPendingReboot;
    ## Avoid recursive loading of the VirtualEngineBaseLab composite module
    Import-DscResource -Name vExchangePrerequisites, vExchangeADPrep;

    vExchangePrerequisites ExchangePrerequisites {
        UCMAPath = $UCMAPath;
    }

    vExchangeADPrep ExchangeADPrep {
        Path = $Path;
        OrganizationName = $OrganizationName;
        Credential = $Credential;
    }

    xPendingReboot PendingRebootPreInstall {
        Name = 'PreExchangeInstall';
        DependsOn = '[vExchangePrerequisites]ExchangePrerequisites','[vExchangeADPrep]ExchangeADPrep';
    }

    xPackage ExchangeInstall {
        Name = 'Exchange 2013';
        ProductId = '{4934D1EA-BE46-48B1-8847-F1AF20E892C1}';
        Path = $Path;
        Arguments = '/mode:Install /role:Mailbox,ClientAccess /Iacceptexchangeserverlicenseterms';
        RunAsCredential = $Credential;
        DependsOn = '[vExchangePrerequisites]ExchangePrerequisites','[vExchangeADPrep]ExchangeADPrep','[xPendingReboot]PendingRebootPreInstall';
    }
        
    xPendingReboot PendingRebootPostInstall {
        Name = 'PostInstall';
        DependsOn = '[xPackage]ExchangeInstall'
    }

}