configuration vDomainMember {
    param (
        [Parameter(Mandatory)]
        [System.String] $ComputerName,
        
        [Parameter(Mandatory)] [AllowNull()]
        [System.String] $DomainName,
        
        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential] $Credential,
        
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $InterfaceAlias = 'Ethernet',
        
        [Parameter(ParameterSetName = 'Static')] [ValidateNotNullOrEmpty()]
        [System.String] $IPAddress,
        
        [Parameter(ParameterSetName = 'Static')] [ValidateNotNull()]
        [System.Int32] $SubnetMask = 24,
        
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $DefaultGateway,
        
        [Parameter()] [ValidateSet('IPv4','IPv6')]
        [System.String] $AddressFamily = 'IPv4',
        
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $DnsServer,
        
        [Parameter()] [AllowNull()]
        [System.String] $TargetOU
    )

    Import-DscResource -ModuleName xComputerManagement, xNetworking;
    Import-DscResource -Name vIPAddress, vDNSServerAddress, vDefaultGatewayAddress;

    $resourceDependsOn = @();
    $domainCredential = $Credential;
    
    if ($InterfaceAlias -match 'Local Area Connection') {
        
        ## Uses the legacy WMI calls
        if ($DnsServer) {
            vDNSServerAddress 'DNS' {
                InterfaceAlias = $InterfaceAlias;
                Address = $DnsServer;
                AddressFamily = $AddressFamily;
            }
            $resourceDependsOn += '[vDNSServerAddress]DNS';
        }
        
        if ($IPAddress) {
            vIPAddress 'IP' {
                IPAddress = $IPAddress;
                SubnetMask = $SubnetMask;
                InterfaceAlias = $InterfaceAlias;
                AddressFamily = $AddressFamily;
            }
            $resourceDependsOn += '[vIPAddress]IP';
        }
        
        if ($DefaultGateway) {
            vDefaultGatewayAddress 'Gateway' {
                Address = $DefaultGateway;
                InterfaceAlias = $InterfaceAlias;
                AddressFamily = $AddressFamily;
            }
        }
        
        ## Win7 requires domain join credential to be NETBIOSDOMAIN\Username
        if (-not $Credential.UserName.Contains('\')) {
            $domainCredentialUsername = '{0}\{1}' -f $DomainName.Split('.')[0], $Credential.Username;
            $domainCredential = New-Object PSCredential -ArgumentList $domainCredentialUsername, $Credential.Password;
        }
        
    } #end InterfaceAlias like Local Area Connection
    else {
        
        if ($DnsServer) {
            xDNSServerAddress 'DNS' {
                InterfaceAlias = $InterfaceAlias;
                Address = $DnsServer;
                AddressFamily = $AddressFamily;
            }
            $resourceDependsOn += '[xDNSServerAddress]DNS';
        }
        
        if ($IPAddress) {
            xIPAddress 'IP' {
                IPAddress = $IPAddress;
                SubnetMask = $SubnetMask;
                InterfaceAlias = $InterfaceAlias;
                AddressFamily = $AddressFamily;
            }
            $resourceDependsOn += '[xIPAddress]IP';
        }
  
        if ($DefaultGateway) {
            xDefaultGatewayAddress 'Gateway' {
                Address = $DefaultGateway;
                InterfaceAlias = $InterfaceAlias;
                AddressFamily = $AddressFamily;
            }
        }
        
    } #end InterfaceAlias like Ethernet 
    
    if ($resourceDependsOn.Count -ge 1) {
        if ([System.String]::IsNullOrEmpty($TargetOU)) {
            xComputer 'ComputerName' {
                Name = $ComputerName;
                DomainName = $DomainName;
                Credential = $domainCredential;
                DependsOn = $resourceDependsOn;
            }
        }
        else {
            xComputer 'ComputerName' {
                Name = $ComputerName;
                DomainName = $DomainName;
                JoinOU = $TargetOU;
                Credential = $domainCredential;
                DependsOn = $resourceDependsOn;
            }
        }
    } #end if dependecnies
    else {
        if ([System.String]::IsNullOrEmpty($TargetOU)) {
            xComputer 'ComputerName' {
                Name = $ComputerName;
                DomainName = $DomainName;
                Credential = $domainCredential;
            }
        }
        else {
            xComputer 'ComputerName' {
                Name = $ComputerName;
                DomainName = $DomainName;
                JoinOU = $TargetOU;
                Credential = $domainCredential;
            }
        }
    } #end if no dependencies

} #end configurationvDomainMember
