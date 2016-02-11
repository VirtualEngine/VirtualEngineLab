configuration vPowerPointViewer {
    param (
        ## Path to Notepad++ installation exe
        [Parameter(Mandatory)] [ValidateNotNull()]
        [System.String] $Path
    )
 
    # Import the module that defines custom resources
    Import-DscResource -Module xPSDesiredStateConfiguration;

    xPackage 'PowerPointViewer' {
        Name = 'Microsoft PowerPoint Viewer';
        ProductId = '95140000-00AF-0409-0000-0000000FF1CE';
        Path = $Path;
        Arguments = '/quiet /norestart';
        ReturnCode = 0;
    }

} #end configuration vPowerPointViewer
