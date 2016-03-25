configuration vWebServerHttps {
    param (
        ## Personal information exchange (Pfx) ertificate file path
        [Parameter(Mandatory)]
        [System.String] $PfxCertificatePath,
        
        ## Pfx certificate thumbprint
        [Parameter(Mandatory)]
        [System.String] $PfxCertificateThumbprint,
        
        ## Pfx certificate password
        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential] $PfxCertificateCredential
    )
    
    Import-DSCResource -ModuleName xCertificate, xWebAdministration;

    $features = @(
        'NET-Framework-45-ASPNET',
        'Web-Server',
        'Web-Common-Http',
        'Web-Default-Doc',
        'Web-Http-Errors',
        'Web-Static-Content',
        'Web-Http-Redirect',
        'Web-Http-Logging',
        'Web-Filtering',
        'Web-Basic-Auth',
        'Web-Windows-Auth',
        'Web-Net-Ext45',
        'Web-AppInit',
        'Web-Asp-Net45',
        'Web-ISAPI-Ext',
        'Web-ISAPI-Filter',
        'Web-Mgmt-Console',
        'Web-Scripting-Tools'
    )
    foreach ($feature in $features) {
        WindowsFeature $feature {
            Name = $feature;
            Ensure = 'Present';
        }
    } #end foreach feature

    xPfxImport 'PfxCertificate' {
        Thumbprint = $PfxCertificateThumbprint;
        Location = 'LocalMachine';
        Store = 'My';
        Path = $PfxCertificatePath;
        Credential = $PfxCertificateCredential;
    }
    
    xWebSite 'DefaultWebSite' {
        Name = 'Default Web Site';
        PhysicalPath = 'C:\inetpub\wwwroot';
        BindingInfo = @(
            MSFT_xWebBindingInformation  { Protocol = 'HTTPS'; Port = 443; CertificateThumbprint = $PfxCertificateThumbprint; CertificateStoreName = 'My'; }
            MSFT_xWebBindingInformation  { Protocol = 'HTTP'; Port = 80; }
        )
        DependsOn = '[WindowsFeature]Web-Server','[xPfxImport]PfxCertificate';
    }
    
} #end configuration vWebServerHttps
