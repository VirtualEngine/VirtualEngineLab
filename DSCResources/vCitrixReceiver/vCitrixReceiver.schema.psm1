configuration vCitrixReceiver {
    param (
        ## Path to Citrix Receiver installation exe
        [Parameter(Mandatory)] [ValidateNotNull()]
        [System.String] $Path
    )
 
    # Import the module that defines custom resources
    Import-DscResource -Module xPSDesiredStateConfiguration;

    xPackage 'CitrixReceiver' {
        Name = 'Citrix Receiver';
        ProductId = '';
        Path = $Path;
        Arguments = '/noreboot /silent';
        ReturnCode = 0;
        InstalledCheckRegKey = 'Software\Citrix\Install\ICA Client';
        InstalledCheckRegValueName = 'InstallFolder';
        InstalledCheckRegValueData = 'C:\Program Files (x86)\Citrix\ICA Client\';
    }

} #end configuration vCitrixReceiver
