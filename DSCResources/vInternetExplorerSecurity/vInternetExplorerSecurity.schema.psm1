configuration vInternetExplorerSecurity {
    param (
        ## Path to Notepad++ installation exe
        [Parameter(Mandatory)] [ValidateSet('Administrators','Users')]
        [System.String[]] $Configuration,

        [Parameter(Mandatory)] [ValidateSet('Present','Absent')]
        [System.String] $Ensure
    )

    Import-DscResource -ModuleName xSystemSecurity;

    foreach ($config in $Configuration) {

        $resourceId = 'IEESC_{0}' -f $config;

        xIEEsc $resourceId {
            UserRole = $config;
            IsEnabled = $Ensure -eq 'Present';
        }

    }

} #end configuration vInternetExplorerSecurity
