configuration vFirefox {
    param (
        ## Path to Firefox installation exe
        [Parameter(Mandatory)] [ValidateNotNull()]
        [System.String] $Path,
        
        ## Enable favorite import on startup
        [Parameter()]
        [System.Boolean] $EnableProfileMigration
    )
 
    # Import the module that defines custom resources
    Import-DscResource -Module PSDesiredStateConfiguration, xPSDesiredStateConfiguration;

    $firefoxIniPath = Join-Path -Path "$env:SYSTEMROOT\Temp\" -ChildPath 'Firefox.ini';
    $firefoxIni = @'
[Install]
InstallDirectoryPath=C:\Program Files (x86)\Mozilla Firefox
QuickLaunchShortcut=false
DesktopShortcut=false
StartMenuShortcuts=true
MaintenanceService=false
'@;
    
    File FirefoxIni {
        DestinationPath = $firefoxIniPath;
        Contents = $firefoxIni;
        Ensure = 'Present';
        Type = 'File';
    }
    
    xPackage Firefox {
        Name = 'Firefox';
        ProductId = '';
        Path = $Path;
        Arguments = '/INI="{0}"' -f $firefoxIniPath;
        ReturnCode = 0;
        InstalledCheckRegKey = 'Software\Mozilla';
        InstalledCheckRegValueName = 'Installed';
        InstalledCheckRegValueData = 'True';
        CreateCheckRegValue = $true;
        DependsOn = '[File]FirefoxIni';
    }
    
    $mozillaCfg = @'
//
lockPref("app.update.enabled", false);
lockPref("app.update.auto", false);
lockPref("app.update.service.enabled", false);

// Turn off for XenApp
defaultPref("layers.acceleration.disabled", true);
'@
    File MozillaCfg {
        DestinationPath = '{0}\Mozilla Firefox\Mozilla.cfg' -f ${env:ProgramFiles(x86)};
        Contents = $mozillaCfg;
        Ensure = 'Present';
        Type = 'File';
        DependsOn = '[xPackage]Firefox';
    }
    
    $localSettingsJS = @'
pref("general.config.obscure_value", 0); // only needed if you do not want to obscure the content with ROT-13
pref("general.config.filename", "mozilla.cfg");
'@
    
    File LocalSettingsJS {
        DestinationPath = '{0}\Mozilla Firefox\browser\defaults\preferences\local-settings.js' -f ${env:ProgramFiles(x86)};
        Contents = $localSettingsJS;
        Ensure = 'Present';
        Type = 'File';
        DependsOn = '[xPackage]Firefox';
    }
    
    if (-not $EnableProfileMigration) {
        $overrideIni = @'
[XRE]
EnableProfileMigrator=false
'@
        File OverrideIni {
            DestinationPath = '{0}\Mozilla Firefox\browser\override.ini' -f ${env:ProgramFiles(x86)};
            Contents = $overrideIni;
            Ensure = 'Present';
            Type = 'File';
            DependsOn = '[xPackage]Firefox';
        }
    } #end if Enable Profile Migration
    
} #end configuration vFirefox
