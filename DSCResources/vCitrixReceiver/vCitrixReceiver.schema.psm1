configuration vCitrixReceiver {
    param (
        ## Path to Citrix Receiver installation exe
        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [System.String] $Path,

        ## Install single sign-on (pass-through) authentication
        [Parameter()]
        [ValidateNotNull()]
        [System.Boolean] $IncludeSSON,

        ## Enable single sign-on (pass-through) authentication
        [Parameter()]
        [ValidateNotNull()]
        [System.Boolean] $EnableSSON,

        ## Enable or disable the always-on tracing feature.
        [Parameter()]
        [ValidateNotNull()]
        [System.Boolean] $EnableTracing,

        ## Anonymous statistics and usage information are sent to Citrix to help Citrix improve the quality and performance of its products
        [Parameter()]
        [ValidateNotNull()]
        [System.Boolean] $EnableCEIP,

        ## Specifies whether users can add and remove stores
        [Parameter()]
        [ValidateSet('Any','SecureOnly','Never')]
        [System.String] $AllowAddStore,

        ## Specifies whether users can add and remove stores
        [Parameter()]
        [ValidateSet('Any','SecureOnly','Never')]
        [Alias('AllowSavePwd')]
        [System.String] $AllowSavePassword,

        ## Specifies up to 10 stores to use with Citrix Receiver
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String[]] $Store,

        ## When the administrator sets the SelfServiceMode flag to false, the user no longer has access to the self service Citrix Receiver user interface
        [Parameter()]
        [ValidateNotNull()]
        [System.Boolean] $EnableSelfService,

        ## Enables the URL redirection feature on user devices
        [Parameter()]
        [ValidateNotNull()]
        [System.Boolean] $EnableUrlRedirection,

        ## Enables session prelaunch
        [Parameter()]
        [ValidateNotNull()]
        [System.Boolean] $EnablePrelaunch,

        ## Override the package name used to check for product installation
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String] $ProductName = 'Citrix Receiver'
    )

    # Import the module that defines custom resources
    Import-DscResource -ModuleName xPSDesiredStateConfiguration;

    $arguments = '/noreboot','/silent';

    if (($PSBoundParameters.ContainsKey('IncludeSSON')) -and ($IncludeSSON -eq $true)) {
        $arguments += '/includeSSON';

        if ($PSBoundParameters.ContainsKey('EnableSSON')) {

            if ($EnableSSON) {
                $arguments += 'ENABLE_SSON=Yes';
            }
            else {
                $arguments += 'ENABLE_SSON=No';
            }
        }
    }

    if ($PSBoundParameters.ContainsKey('EnableTracing')) {
        $arguments += '/EnableTracing={0}' -f $EnableTracing.ToString();
    }

    if ($PSBoundParameters.ContainsKey('EnableCEIP')) {
        $arguments += '/EnableCEIP={0}' -f $EnableCEIP.ToString();
    }

    if ($PSBoundParameters.ContainsKey('AllowAddStore')) {
        $arguments += 'ALLOWADDSTORE={0}' -f $AllowAddStore.SubString(0,1);
    }

    if ($PSBoundParameters.ContainsKey('AllowSavePassword')) {
        $arguments += 'ALLOWSAVEPWD={0}' -f $AllowSavePassword.SubString(0,1);
    }

    if ($PSBoundParameters.ContainsKey('Store')) {
        for ($i = 0; $i -lt $Store.Count; $i++) {
            $arguments += 'STORE{0}="{1}"' -f $i, $Store[$i];
        }
    }

    if ($PSBoundParameters.ContainsKey('EnableSelfService')) {
        $arguments += 'SELFSERVICEMODE={0}' -f $EnableSelfService.SubString(0,1);
    }

    if ($PSBoundParameters.ContainsKey('EnableUrlRedirection')) {
        $arguments += 'ALLOW_CLIENTHOSTEDAPPSURL={0}' -f ($EnableUrlRedirection -as [System.Int32]);
    }

    if ($PSBoundParameters.ContainsKey('EnablePrelaunch')) {
        $arguments += 'ENABLEPRELAUNCH=' -f $EnablePrelaunch.ToString();
    }

    xPackage 'CitrixReceiver' {
        Name = $ProductName;
        ProductId = '';
        Path = $Path;
        Arguments = [System.String]::Join(' ', $arguments);
        ReturnCode = 0;
        InstalledCheckRegKey = 'Software\Citrix\Install\ICA Client';
        InstalledCheckRegValueName = 'InstallFolder';
        InstalledCheckRegValueData = 'C:\Program Files (x86)\Citrix\ICA Client\';
    }

} #end configuration vCitrixReceiver
