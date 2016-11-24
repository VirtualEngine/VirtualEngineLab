configuration vVisualStudioCode {
    param (
        ## Path to Citrix Receiver installation exe
        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [System.String] $Path,

        ## Credential used to install VS Code
        [Parameter()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()]
        $Credential,

        ## Remove the VS Code file type associations
        [Parameter()]
        [System.Boolean] $RemoveFileTypeAssociation,

        ## Registers an Active Setup PowerShell script that is run per user, e.g.
        ## to disable automatic updates.
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String] $ActiveSetupScriptPath,

        ## Override the package name used to check for product installation
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String] $ProductName = 'Microsoft Visual Studio Code'
    )

    # Import the module that defines custom resources
    Import-DscResource -ModuleName PSDesiredStateConfiguration, xPSDesiredStateConfiguration;

    $vsCodeInfPath = 'C:\Windows\Temp\VSCode.inf';
    $vsCodeInf = @'
[Setup]
Lang=english
Dir=C:\Program Files (x86)\Microsoft VS Code
Group=Visual Studio Code
NoIcons=0
Tasks=desktopicon,addcontextmenufiles,addtopath
'@

    File 'VSCodeInf' {
        Contents        = $vsCodeInf;
        DestinationPath = $vsCodeInfPath;
        Force           = $true;
        Ensure          = 'Present';
    }

    $arguments = '/SP-','/VERYSILENT','/SUPPRESSMSGBOXES','/NORESTART','/CLOSEAPPLICATIONS','/NORESTARTAPPLICATIONS',"/LOADINF=$gitForWindowsInfPath";

    if ($PSBoundParameters.ContainsKey('Credential')) {

        xPackage 'VSCode' {
            Name                       = $ProductName;
            ProductId                  = '';
            Path                       = $Path;
            Arguments                  = [System.String]::Join(' ', $arguments);
            ReturnCode                 = 0;
            InstalledCheckRegKey       = 'SOFTWARE\Classes\VSCode';
            InstalledCheckRegValueName = '(default)';
            InstalledCheckRegValueData = 'Visual Studio Code Source File';
            RunAsCredential            = $Credential;
            DependsOn                  = '[File]VSCodeInf';
        }

    }
    else {

        xPackage 'VSCode' {
            Name                       = $ProductName;
            ProductId                  = '';
            Path                       = $Path;
            Arguments                  = [System.String]::Join(' ', $arguments);
            ReturnCode                 = 0;
            InstalledCheckRegKey       = 'SOFTWARE\Classes\VSCode';
            InstalledCheckRegValueName = '(default)';
            InstalledCheckRegValueData = 'Visual Studio Code Source File';
            DependsOn                  = '[File]VSCodeInf';
        }
    }

    if ($RemoveFileTypeAssociation) {

        Registry 'VSCodeFileTypeAssociationPs1' {
            Key       = 'HKEY_LOCAL_MACHINE\SOFTWARE\Classes\.ps1\OpenWithProgids';
            ValueName = 'VSCode.ps1';
            Ensure    = 'Absent';
            DependsOn = '[xPackage]VSCode';
        }

        Registry 'VSCodeFileTypeAssociationPsd1' {
            Key       = 'HKEY_LOCAL_MACHINE\SOFTWARE\Classes\.psd1\OpenWithProgids';
            ValueName = 'VSCode.psd1';
            Ensure    = 'Absent';
            DependsOn = '[xPackage]VSCode';
        }

        Registry 'VSCodeFileTypeAssociationPsm1' {
            Key       = 'HKEY_LOCAL_MACHINE\SOFTWARE\Classes\.psm1\OpenWithProgids';
            ValueName = 'VSCode.psm1';
            Ensure    = 'Absent';
            DependsOn = '[xPackage]VSCode';
        }
    }

    if ($PSBoundParameters.ContainsKey('ActiveSetupScriptPath')) {

        Registry 'VSCodeActiveSetup' {
            Key       = 'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Active Setup\Installed Components\VE_VSCode';
            ValueType = 'String';
            ValueName = '(Default)';
            ValueData = 'Visual Studio Code';
            Ensure    = 'Present';
            DependsOn = '[xPackage]VSCode';
        }

        Registry 'VSCodeAutoUpdate' {
            Key       = 'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Active Setup\Installed Components\VE_VSCode';
            ValueType = 'String';
            ValueName = 'StubPath';
            ValueData = 'powershell.exe -ExecutionPolicy RemoteSigned -NoLogo -WindowStyle Hidden -File {0}' -f $ActiveSetupScriptPath.Replace('\','\\');
            Ensure    = 'Present';
            DependsOn = '[xPackage]VSCode';
        }

        Registry 'VSCodeAutoUpdateVersion' {
            Key       = 'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Active Setup\Installed Components\VE_VSCode';
            ValueType = 'String';
            ValueName = 'Version';
            ValueData = '1,0';
            Ensure    = 'Present';
            DependsOn = '[xPackage]VSCode';
        }
    }

} #end configuration vVisualStudioCode
