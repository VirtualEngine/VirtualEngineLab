configuration vPuTTY {
    param (
        ## Path to PuTTY installation exe
        [Parameter(Mandatory)]
        [System.String] $Path,

        ## MSI product name
        [Parameter(Mandatory)]
        [System.String] $ProductName,

        ## Credential used to install PuTTY
        [Parameter()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()]
        $Credential
    )

    # Import the module that defines custom resources
    Import-DscResource -ModuleName xPSDesiredStateConfiguration;

    if ($PSBoundParameters.ContainsKey('Credential')) {

        xPackage 'PuTTY' {
            Name = $ProductName;
            ProductId = '';
            Path = $Path;
            Arguments = '/VERYSILENT';
            ReturnCode = 0;
            Credential =  $Credential;
        }
    }
    else {

        xPackage 'PuTTY' {
            Name = $ProductName;
            ProductId = '';
            Path = $Path;
            Arguments = '/VERYSILENT';
            ReturnCode = 0;
        }

    }

} #end configuration vPuTTY
