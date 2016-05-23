configuration vAppV5Hotfix {
    param (
        ## Path to App-V 5.1 hotfix installation .exe
        [Parameter(Mandatory)] [ValidateNotNull()]
        [System.String] $Path,
        
        ## Hotfix (un)install display name
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()]
        [System.String] $PackageDisplayName,

        ## App-V product code
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $ProductId = '',
        
        [Parameter()]
        [System.Boolean] $EnablePackageScripts = $true,
        
        [Parameter()] [ValidateSet('Present', 'Absent')]
        [System.String] $Ensure = 'Present'
    )
 
    # Import the module that defines custom resources
    Import-DscResource -ModuleName xPSDesiredStateConfiguration;
     
    $resourceId = $PackageDisplayName.Replace('()','').Replace(')','').Replace(' ','');
    xPackage $resourceId {
        ## Cannot use the actual 'Microsoft Application Virtualization (App-V) Client' package name!
        Name = $PackageDisplayName;
        Path = $Path;
        ProductId = $ProductId;
        Arguments = '/ACCEPTEULA=1 /CEIPOPTIN=0 /ENABLEPACKAGESCRIPTS={0} /NORESTART /q' -f ([System.Int32]$EnablePackageScripts);
        ReturnCode = 0, 3010;
        Ensure = $Ensure;
    }

} #end configuration vAppV5Hotfix
