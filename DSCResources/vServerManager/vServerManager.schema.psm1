configuration vServerManager {
    param (
        ## 
        [Parameter(Mandatory)] [ValidateNotNull()]
        [System.Boolean] $Enable
    )

    Import-DscResource -Name PSDesiredStateConfiguration;
    
    Registry 'ServerManager' {
        Key = 'HKEY_LOCAL_MACHINE\Software\Microsoft\ServerManager';
        ValueName = 'DoNotOpenServerManagerAtLogon';
        ValueData =  (-not $Enable -as [System.Int32]).ToString();
        ValueType = 'Dword';
        Ensure = 'Present';
    }
    
}
