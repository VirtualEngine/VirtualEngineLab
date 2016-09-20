configuration vGitForWindows {
    param (
        ## Path to Citrix Receiver installation exe
        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [System.String] $Path,

        ## MSI product name
        [Parameter(Mandatory)]
        [System.String] $ProductName,

        ## Credential used to install Git for Windows
        [Parameter()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()]
        $Credential,

        ## Remove the specified icons
        [Parameter()]
        [ValidateSet('GitBash','GitCmd','GitGui')]
        [System.String[]] $RemoveGitForWindowsIcon,

        ## Path to Git for Windows icon file
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String] $GitForWindowsIconPath
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration, xPSDesiredStateConfiguration;

    $gitForWindowsInfPath = 'C:\Windows\Temp\GitForWindows.inf';
    $gitForWindowsInf = @'
[Setup]
Lang=default
Dir=C:\Program Files\Git
Group=Git
NoIcons=0
SetupType=default
Components=
Tasks=
PathOption=Cmd
SSHOption=OpenSSH
CRLFOption=CRLFAlways
BashTerminalOption=ConHost
PerformanceTweaksFSCache=Enabled
'@

    File 'GitForWindowsInf' {
        Contents        = $gitForWindowsInf;
        DestinationPath = $gitForWindowsInfPath;
        Force           = $true;
        Type            = 'File';
        Ensure          = 'Present';
    }

    $gitForWindowsDependsOn = @('[File]GitForWindowsInf');

    if ($PSBoundParameters.ContainsKey('GitForWindowsIconPath')) {

        File 'GitForWindowsIcon' {
            SourcePath      = $GitForWindowsIconPath;
            DestinationPath = 'C:\Program Files\Git\mingw64\share\git\git-for-windows.ico';
            Type            = 'File';
            Force           = $true;
            Ensure          = 'Present';
        }

        $gitForWindowsDependsOn += '[File]GitForWindowsIcon';
    }

    $arguments = '/SP-','/VERYSILENT','/SUPPRESSMSGBOXES','/NORESTART',"/LOADINF=$gitForWindowsInfPath";

    if ($PSBoundParameters.ContainsKey('Credential')) {

        xPackage 'GitForWindows' {
            Name                       = $ProductName;
            Path                       = $Path
            ProductId                  = '';
            Arguments                  = [System.String]::Join(' ', $arguments);
            InstalledCheckRegKey       = 'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Git_is1';
            InstalledCheckRegValueName = 'URLInfoAbout';
            InstalledCheckRegValueData = 'https://git-for-windows.github.io/';
            RunAsCredential            = $Credential;
            DependsOn                  = $gitForWindowsDependsOn;
        }

    }
    else {

        xPackage 'GitForWindows' {
            Name                       = $ProductName;
            Path                       = $Path
            ProductId                  = '';
            Arguments                  = [System.String]::Join(' ', $arguments);
            InstalledCheckRegKey       = 'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Git_is1';
            InstalledCheckRegValueName = 'URLInfoAbout';
            InstalledCheckRegValueData = 'https://git-for-windows.github.io/';
            DependsOn                  = $gitForWindowsDependsOn;
        }
    }

    foreach ($icon in $RemoveGitForWindowsIcon) {

        switch ($icon) {

            'GitBash' {
                $gitForWindowsIconPath = 'C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Git\Git Bash.lnk';
            }
            'GitCmd' {
                $gitForWindowsIconPath = 'C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Git\Git CMD.lnk';
            }
            'GitGui' {
                $gitForWindowsIconPath = 'C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Git\Git GUI.lnk';
            }
        }

        File "$($icon)Icon" {
            DestinationPath = $gitForWindowsIconPath;
            Type            = 'File';
            Force           = $true;
            Ensure          = 'Absent';
            DependsOn       = '[xPackage]GitForWindows';
        }

    } #end foreach icon

} #end configuration vGitForWindows
