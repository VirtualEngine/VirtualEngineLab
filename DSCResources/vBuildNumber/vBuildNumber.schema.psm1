configuration vBuildNumber {
    param (
        ## Path to Adobe Reader DC installation exe
        [Parameter(Mandatory)] [ValidateNotNull()]
        [System.String] $BuildNumber
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration;

    ## The built-in Registry provider, forces key names to lower case? Therefore, use
    ## the Script resource to create the registy key!

    Script 'DeploymentDate' {
        GetScript = {
            $deploymentDate = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Virtual Engine' -Name 'DeploymentDate' -ErrorAction SilentlyContinue);
            return @{ Result = $deploymentDate.DeploymentDate; }
        }
        TestScript = {
            $deploymentDate = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Virtual Engine' -Name 'DeploymentDate' -ErrorAction SilentlyContinue);
            if ($null -ne $deploymentDate.DeploymentDate) { return $true; }
            else { return $false; }
        }
        SetScript = {
            Set-ItemProperty -Path 'HKLM:\SOFTWARE\Virtual Engine' -Name 'DeploymentDate' -Value (Get-Date).ToString('dd/MM/yyyy HH:mm:ss.ff');
        }
    } #end script DeploymentDate

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
