configuration vDefaultDesktopWallpaper {
    param (
        ## Path to desktop wallpaper
        [Parameter(Mandatory)] [ValidateNotNull()]
        [System.String] $Path
    )
 
    # Import the module that defines custom resources
    Import-DscResource -ModuleName PSDesiredStateConfiguration;

    File 'vDefaultDesktopWallpaper' {
        SourcePath = $Path;
        DestinationPath = '{0}\Web\Wallpaper\Windows\';
        Type = 'File';
        Force = $true;
    }

} #end configuration vDefaultDesktopWallpaper
