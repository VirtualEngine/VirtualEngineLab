configuration vPowerPointViewer {
    param (
        ## Path to Notepad++ installation exe
        [Parameter(Mandatory)] [ValidateNotNull()]
        [System.String] $Path
    )

    # Import the module that defines custom resources
    Import-DscResource -ModuleName xPSDesiredStateConfiguration;

    xPackage 'PowerPointViewer' {
        Name = 'Microsoft PowerPoint Viewer';
        ProductId = '';
        Path = $Path;
        Arguments = '/quiet /norestart';
        ReturnCode = 0;
    }

} #end configuration vPowerPointViewer
