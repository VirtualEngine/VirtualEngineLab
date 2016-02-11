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
        [Parameter()] [ValidateSet('2012','2014')]
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
        [Parameter()] [System.Boolean]
        $TcpEnabled = $true,
        
        ## Enable SQL Express Named Pipes connectivity. Defaults to True.
        [Parameter()] [System.Boolean]
        $NpeEnabled = $true,
        
        ## Whether to ensure that SQL Express is installed or removed.
        [Parameter()] [ValidateSet('Present','Absent')]
        $Ensure = 'Present',
        
        ## Credential to access Setup.exe
        [Parameter()]
        [System.Management.Automation.PSCredential] $Credential
    )

    Import-DscResource -ModuleName xNetworking;
   
    WindowsFeature NetFX35 {
	    Ensure = 'Present';
	    Name = 'Net-Framework-Core';
    }

    $tcpEnabledString = if ($TcpEnabled -eq $true) { '1' } else { '0' };
    $npeEnabledString = if ($NpeEnabled -eq $true) { '1'} else { '0' };

    $packageArguments = New-Object System.Text.StringBuilder;
    [ref] $null = $packageArguments.AppendFormat('/Q /ACTION=INSTALL /INSTANCENAME={0} /TCPENABLED={1} /NPENABLED={2}', $Instance, $tcpEnabledString, $npeEnabledString); 
    [ref] $null = $packageArguments.AppendFormat(' /FEATURES={0} ', [System.String]::Join(',', $Features));
    if ($SAPassword) {
        [ref] $null = $packageArguments.AppendFormat(' /SECURITYMODE=SQL /SAPWD={0}', $SAPassword.GetNetworkCredential().Password);
    }
    [ref] $null = $packageArguments.Append(' /SQLSYSADMINACCOUNTS="Builtin\Administrators" /SQLSVCACCOUNT="NT AUTHORITY\SYSTEM" /IACCEPTSQLSERVERLICENSETERMS');

    switch ($Version) {
        '2012' { $packageProductId = '18B2A97C-92C3-4AC7-BE72-F823E0BC895B'; }
        '2014' { $packageProductId = '0EEBDCCA-EF5D-4896-9FEA-D7D410A57E8A'; }
    }

    if ($Credential) {
        Package 'SQLExpressInstall' {
            Ensure = $Ensure;
            Name = 'SQL Express';
            Path = $Path;
            ProductId = $packageProductId;
            Arguments = $packageArguments.ToString();
            DependsOn = '[WindowsFeature]NetFx35';
            Credential = $Credential;
        }
    }
    else {
        Package 'SQLExpressInstall' {
            Ensure = $Ensure;
            Name = 'SQL Express';
            Path = $Path;
            ProductId = $packageProductId;
            Arguments = $packageArguments.ToString();
            DependsOn = '[WindowsFeature]NetFx35';
        }
    }

    xFirewall 'SQLFirewall' {
        Name = 'MSSQL-TCP-1433-In';
        Action = 'Allow';
        Direction = 'Inbound';
        DisplayName = 'MS SQL Server (MSSQLServer)';
        Enabled = $true;
        Profile = 'Any';
        LocalPort = '1433';
        Protocol = 'TCP';
        Description = 'Default MS SQL Server instance';
    }

} #end configuration vSQLExpress
