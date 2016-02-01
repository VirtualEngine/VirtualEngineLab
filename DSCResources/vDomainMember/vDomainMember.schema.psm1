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
        [System.String] $DnsServer
    )

    Import-DscResource -Module xComputerManagement, xNetworking;

    $resourceDependsOn = @();
    
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
        xDefaultGatewayAddress Gateway {
            Address = $DefaultGateway;
            InterfaceAlias = $InterfaceAlias;
            AddressFamily = $AddressFamily;
        }
    }

    if ($DnsServer) {
        xDNSServerAddress 'DNS' {
            InterfaceAlias = $InterfaceAlias;
            Address = $DnsServer;
            AddressFamily = $AddressFamily;
        }
        $resourceDependsOn += '[xDNSServerAddress]DNS';
    }
    
    if ($resourceDependsOn.Count -ge 1) {
        xComputer 'ComputerName' {
            Name = $ComputerName;
            DomainName = $DomainName;
            Credential = $Credential;
            DependsOn = $resourceDependsOn;
        }
    }
    else {
        xComputer 'ComputerName' {
            Name = $ComputerName;
            DomainName = $DomainName;
            Credential = $Credential;
        }
    }
}
