configuration vWorkgroupMember {
    param (
        [Parameter(Mandatory)]
        [System.String] $ComputerName,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String] $InterfaceAlias = 'Ethernet',

        [Parameter(ParameterSetName = 'Static')]
        [ValidateNotNullOrEmpty()]
        [System.String] $IPAddress,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String] $DefaultGateway,

        [Parameter()]
        [ValidateSet('IPv4','IPv6')]
        [System.String] $AddressFamily = 'IPv4',

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String] $DnsServer
    )

    Import-DscResource -ModuleName xComputerManagement, xNetworking, LegacyNetworking;

    if ($InterfaceAlias -match 'Local Area Connection') {

        ## Uses the legacy WMI calls
        if ($DnsServer) {

            vDNSServerAddress 'DNS' {
                InterfaceAlias = $InterfaceAlias;
                Address = $DnsServer;
                AddressFamily = $AddressFamily;
            }
        }

        if ($IPAddress) {

            vIPAddress 'IP' {
                IPAddress = $IPAddress.Split('/')[0];
                SubnetMask = $IPAddress.Split('/')[1];
                InterfaceAlias = $InterfaceAlias;
                AddressFamily = $AddressFamily;
            }
        }

        if ($DefaultGateway) {

            vDefaultGatewayAddress 'Gateway' {
                Address = $DefaultGateway;
                InterfaceAlias = $InterfaceAlias;
                AddressFamily = $AddressFamily;
            }
        }

    } #end InterfaceAlias like Local Area Connection
    else {

        if ($DnsServer) {

            xDNSServerAddress 'DNS' {
                InterfaceAlias = $InterfaceAlias;
                Address = $DnsServer;
                AddressFamily = $AddressFamily;
            }
        }

        if ($IPAddress) {

            xIPAddress 'IP' {
                IPAddress = $IPAddress;
                InterfaceAlias = $InterfaceAlias;
                AddressFamily = $AddressFamily;
            }
        }

        if ($DefaultGateway) {

            xDefaultGatewayAddress 'Gateway' {
                Address = $DefaultGateway;
                InterfaceAlias = $InterfaceAlias;
                AddressFamily = $AddressFamily;
            }
        }

    } #end InterfaceAlias like Ethernet

    xComputer ComputerName {
        Name = $ComputerName;
    }

}
