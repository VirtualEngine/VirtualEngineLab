configuration vBuildNumber {
    param (
        ## Path to Adobe Reader DC installation exe
        [Parameter(Mandatory)] [ValidateNotNull()]
        [System.String] $BuildNumber
    )

    # Import the module that defines custom resources
    Import-DscResource -ModuleName PSDesiredStateConfiguration;

    Registry 'BuildNumber' {
        Key = 'HKEY_LOCAL_MACHINE\Software\Virtual Engine' -f $versionString;
        ValueName = 'BuildNumber';
        ValueData = $BuildNumber;
        ValueType = 'String';
        Ensure = 'Present';
    }

    Registry 'BuildDate' {
        Key = 'HKEY_LOCAL_MACHINE\Software\Virtual Engine' -f $versionString;
        ValueName = 'BuildDate';
        ValueData = (Get-Date).ToString('dd/MM/yyyy HH:mm:ss.ff');
        ValueType = 'String';
        Ensure = 'Present';
    }

} #end configuration vBuildNumber
