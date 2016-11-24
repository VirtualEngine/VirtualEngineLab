configuration vPowerPointViewer {
    param (
        ## Path to Notepad++ installation exe
        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [System.String] $Path,

        ## Override the package name used to check for product installation
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String] $ProductName = 'Microsoft PowerPoint Viewer'
    )

    # Import the module that defines custom resources
    Import-DscResource -ModuleName xPSDesiredStateConfiguration;

    xPackage 'PowerPointViewer' {
        Name = $ProductName;
        ProductId = '';
        Path = $Path;
        Arguments = '/quiet /norestart';
        ReturnCode = 0;
    }

} #end configuration vPowerPointViewer
