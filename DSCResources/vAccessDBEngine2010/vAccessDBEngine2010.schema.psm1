configuration vAccessDBEngine2010 {
    param (
        ## Path to Microsoft Access Database Engine 2010 Redistributable installation exe
        [Parameter(Mandatory)] [ValidateNotNull()]
        [System.String] $Path
    )
 
    # Import the module that defines custom resources
    Import-DscResource -ModuleName xPSDesiredStateConfiguration;

    xPackage 'MSAccessDBEngine2010' {
        Name = 'Microsoft Access Database Engine 2010 Redistributable';
        ProductId = '90140000-00D1-0409-1000-0000000FF1CE';
        Path = $Path;
        Arguments = '/quiet';
        ReturnCode = 0;
    }

} #end configuration vAccessDBEngine2010
