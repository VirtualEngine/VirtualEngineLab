configuration vGitForWindows {
    param (
        ## Path to Citrix Receiver installation exe
        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [System.String] $Path,


        [Parameter(Mandatory)]
        [System.String] $ProductName,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()]
        $Credential,

        [Parameter()]
        [ValidateSet('GitBash','GitCmd','GitGui')]
        [System.String[]] $RemoveGitForWindowsIcon
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
        Ensure          = 'Present';
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
            DependsOn                  = '[File]GitForWindowsInf';
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
            DependsOn                  = '[File]GitForWindowsInf';
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
            Type = 'File';
            Force = $true;
            Ensure = 'Absent';
        }

    } #end foreach icon

} #end configuration vGitForWindows
