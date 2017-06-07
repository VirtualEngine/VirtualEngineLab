configuration vSSMS {
    <#
        .SYNOPSIS
            Installs Microsoft SQL Server Management Studio.
    #>
    param (
        ## Path to the SQL Express installation SETUP.EXE on the node.
        [Parameter(Mandatory)]
        [System.String] $Path,

        ## Product display name (used for product detection)
        [Parameter(Mandatory)]
        [System.String] $ProductName,
        
        ## Whether to ensure that SQL Express is installed or removed.
        [Parameter()] [ValidateSet('Present','Absent')]
        [System.String] $Ensure = 'Present',


        ## Credential to access Setup.exe
        [Parameter()]
        [System.Management.Automation.PSCredential] $Credential
    )

    Import-DscResource -ModuleName xPSDesiredStateConfiguration;


    $packageArguments = '/install /passive /norestart';
    $resourceId = $ProductName.Replace(' ','').Replace('.','_');

    if ($Credential) {

        xPackage $resourceId {
            Ensure = $Ensure;
            Name = $ProductName;
            Path = $Path;
            ProductId = '';
            Arguments = $packageArguments;
            Credential = $Credential;
        }

    }
    else {
        
        xPackage $resourceId {
            Ensure = $Ensure;
            Name = $ProductName;
            Path = $Path;
            ProductId = '';
            Arguments = $packageArguments;
        }

    }

} #end configuration vSSMS
