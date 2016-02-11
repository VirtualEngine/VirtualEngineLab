configuration vAppV5 {
    param (
        ## Path to App-V 5.1 installation media
        [Parameter(Mandatory)] [ValidateNotNull()]
        [System.String] $Path,
        
        [Parameter(Mandatory)] [ValidateSet('5.0','5.1')]
        [System.String] $Version,

        [Parameter()]
        [System.Boolean] $IsRDS,
        
        [Parameter()]
        [System.Boolean] $EnablePackageScripts = $true
    )
 
    # Import the module that defines custom resources
    Import-DscResource -Module PSDesiredStateConfiguration;

    switch ($Version) {
        '5.0' {
            if ($IsRDS) { $productCode = '6313DBA3-0CA9-4CD8-93B3-373534146B7B'; }
            else { $productCode = '6313DBA3-0CA9-4CD8-93B3-373534146B7B'; }
        }
        '5.1' {
            if ($IsRDS) { $productCode = '9C9A5F2A-9323-4849-90B7-F12D1A7CF544'; }
            else { $productCode = '5A1C366F-31AC-48CA-BF13-0504FF31D6A3'; }
        }
    }
     
    Package 'AppV5' {
        Name = 'Microsoft Application Virtualization (App-V) Client';
        Path = $Path;
        ProductId = $productCode;
        Arguments = '/ACCEPTEULA=1 /CEIPOPTIN=0 /ENABLEPACKAGESCRIPTS={0} /NORESTART /q' -f ([System.Int32]$EnablePackageScripts);
    }

} #end configuration vAppV5
