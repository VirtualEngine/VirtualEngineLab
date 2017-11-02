configuration vDomainMember {
    param (
        [Parameter(Mandatory)]
        [System.String] $ComputerName,

        [Parameter(Mandatory)]
        [AllowNull()]
        [System.String] $DomainName,

        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential] $Credential,

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
        [System.String] $DnsServer,

        [Parameter()]
        [AllowNull()]
        [System.String] $TargetOU,

        ## Domain join retry interval
        [Parameter()]
        [System.Int32] $RetryIntervalSec = 60,

        ## Domain join retry count
        [Parameter()]
        [System.Int32] $RetryCount = 60
    )

    Import-DscResource -ModuleName xComputerManagement, xActiveDirectory;
    Import-DscResource -ModuleName xNetworking, LegacyNetworking;

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
                IPAddress = $IPAddress.Split('/')[0];
                SubnetMask = $IPAddress.Split('/')[1];
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

        ## Add a pause to wait for IP stack to be able to communicate with AD
        xWaitForADDomain 'WaitForADDomain' {
            DomainName = $DomainName;
            DomainUserCredential = $domainCredential;
            RetryIntervalSec = $RetryIntervalSec;
            RetryCount = $RetryCount;
            DependsOn = $resourceDependsOn;
        }

        if ([System.String]::IsNullOrEmpty($TargetOU)) {

            xComputer 'ComputerName' {
                Name = $ComputerName;
                DomainName = $DomainName;
                Credential = $domainCredential;
                DependsOn = '[xWaitForADDomain]WaitForADDomain';
            }
        }
        else {

            xComputer 'ComputerName' {
                Name = $ComputerName;
                DomainName = $DomainName;
                JoinOU = $TargetOU;
                Credential = $domainCredential;
                DependsOn = '[xWaitForADDomain]WaitForADDomain';
            }
        }

    } #end if dependecnies
    else {

        ## Add a pause to wait for IP stack to be able to communicate with AD
        xWaitForADDomain 'WaitForADDomain' {
            DomainName = $DomainName;
            DomainUserCredential = $domainCredential;
            RetryIntervalSec = $RetryIntervalSec;
            RetryCount = $RetryCount;
        }

        if ([System.String]::IsNullOrEmpty($TargetOU)) {

            xComputer 'ComputerName' {
                Name = $ComputerName;
                DomainName = $DomainName;
                Credential = $domainCredential;
                DependsOn = '[xWaitForADDomain]WaitForADDomain';
            }
        }
        else {

            xComputer 'ComputerName' {
                Name = $ComputerName;
                DomainName = $DomainName;
                JoinOU = $TargetOU;
                Credential = $domainCredential;
                DependsOn = '[xWaitForADDomain]WaitForADDomain';
            }
        }
    } #end if no dependencies

} #end configuration vDomainMember
