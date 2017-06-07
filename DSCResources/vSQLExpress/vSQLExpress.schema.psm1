configuration vSQLExpress {
    <#
        .SYNOPSIS
            Installs Microsoft SQL Server Express 2012/2014.
    #>
    param (
        ## Path to the SQL Express installation SETUP.EXE on the node.
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()]
        [System.String] $Path,

        ## Version of SQL we're installing (needed to determine the ProductId).
        [Parameter()] [ValidateSet('2012','2014','2016')]
        [System.String] $Version = '2014',

        ## SQL Express server instance name.
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $Instance = 'MSSQLServer',

        ## SQL Express feature(s) to install.
        [Parameter()] [ValidateSet('SQLENGINE','SSMS')]
        [System.String[]] $Features = @('SQLENGINE','SSMS'),

        ## SQL Express SA account password. If not specified, SQL authentication is not enabled.
        [Parameter()] [AllowNull()]
        [PSCredential] $SAPassword,

        ## Enable SQL Express TCP/IP connectivity. Defaults to True.
        [Parameter()]
        [System.Boolean] $TcpEnabled = $true,

        ## Enable SQL Express Named Pipes connectivity. Defaults to True.
        [Parameter()]
        [System.Boolean] $NpeEnabled = $true,

        ## Whether to ensure that SQL Express is installed or removed.
        [Parameter()] [ValidateSet('Present','Absent')]
        [System.String] $Ensure = 'Present',

        ## Product display name (used for product detection)
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $ProductName = ('Microsoft SQL Server {0} Setup (English)' -f $Version),

        ## Install Microsoft .Net Framework 3.0 feature. Defaults to True.
        [Parameter()]
        [System.Boolean] $InstallNetFrameworkCore = $true,

        ## Credential to access Setup.exe
        [Parameter()]
        [System.Management.Automation.PSCredential] $Credential
    )

    Import-DscResource -ModuleName xPSDesiredStateConfiguration, xNetworking;

    if ($InstallNetFrameworkCore) {
        WindowsFeature NetFX35 {
	        Ensure = 'Present';
	        Name = 'Net-Framework-Core';
        }
    }

    $tcpEnabledString = if ($TcpEnabled -eq $true) { '1' } else { '0' };
    $npeEnabledString = if ($NpeEnabled -eq $true) { '1'} else { '0' };

    $packageArguments = New-Object System.Text.StringBuilder;
    [ref] $null = $packageArguments.AppendFormat('/Q /ACTION=INSTALL /INSTANCENAME={0} /TCPENABLED={1} /NPENABLED={2}', $Instance, $tcpEnabledString, $npeEnabledString);
    [ref] $null = $packageArguments.AppendFormat(' /FEATURES={0}', [System.String]::Join(',', $Features));
    if ($SAPassword) {
        [ref] $null = $packageArguments.AppendFormat(' /SECURITYMODE=SQL /SAPWD={0}', $SAPassword.GetNetworkCredential().Password);
    }
    [ref] $null = $packageArguments.Append(' /SQLSYSADMINACCOUNTS="Builtin\Administrators" /SQLSVCACCOUNT="NT AUTHORITY\SYSTEM" /IACCEPTSQLSERVERLICENSETERMS');

    $resourceId = 'SQL{0}ExpressPackage' -f $Version;

    if ($Credential -and $InstallNetFrameworkCore) {
        xPackage $resourceId {
            Ensure = $Ensure;
            Name = $ProductName;
            Path = $Path;
            ProductId = '';
            Arguments = $packageArguments.ToString();
            DependsOn = '[WindowsFeature]NetFx35';
            Credential = $Credential;
        }
    }
    elseif ($InstallNetFrameworkCore) {
        xPackage $resourceId {
            Ensure = $Ensure;
            Name = $ProductName;
            Path = $Path;
            ProductId = '';
            Arguments = $packageArguments.ToString();
            DependsOn = '[WindowsFeature]NetFx35';
        }
    }
    else {
        xPackage $resourceId {
            Ensure = $Ensure;
            Name = $ProductName;
            Path = $Path;
            ProductId = '';
            Arguments = $packageArguments.ToString();
        }
    }

    xFirewall 'SQLFirewall' {
        Name = 'MSSQL-TCP-1433-In';
        Group = 'Microsoft SQL Server';
        Action = 'Allow';
        Direction = 'Inbound';
        DisplayName = 'MS SQL Server (MSSQLServer)';
        Enabled = $true;
        Profile = 'Any';
        LocalPort = '1433';
        Protocol = 'TCP';
        Description = 'Default MS SQL Server instance';
        Ensure = $Ensure;
        DependsOn = "[xPackage]$resourceId";
    }

    Registry 'CustomerFeedback' {
        Key = 'HKEY_LOCAL_MACHINE\Software\Microsoft\Microsoft SQL Server\120';
        ValueName = 'CustomerFeedback';
        ValueData = '0';
        ValueType = 'Dword';
        DependsOn = "[xPackage]$resourceId";
    }

} #end configuration vSQLExpress
