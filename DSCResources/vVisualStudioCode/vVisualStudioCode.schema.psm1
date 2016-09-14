configuration vVisualStudioCode {
    param (
        ## Path to Citrix Receiver installation exe
        [Parameter(Mandatory)] [ValidateNotNull()]
        [System.String] $Path
    )

    # Import the module that defines custom resources
    Import-DscResource -ModuleName xPSDesiredStateConfiguration;

    $arguments = '/SP-','/VERYSILENT','/SUPPRESSMSGBOXES','/NORESTART','/CLOSEAPPLICATIONS','/NORESTARTAPPLICATIONS';

    xPackage 'VSCode' {
        Name = 'Microsoft Visual Studio Code';
        ProductId = '';
        Path = $Path;
        Arguments = [System.String]::Join(' ', $arguments);
        ReturnCode = 0;
        InstalledCheckRegKey = 'SOFTWARE\Classes\VSCode';
        InstalledCheckRegValueName = '(default)';
        InstalledCheckRegValueData = 'Visual Studio Code Source File';
    }

} #end configuration vVisualStudioCode
