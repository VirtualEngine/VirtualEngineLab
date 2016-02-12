data localized {
    # culture="en-US"
    ConvertFrom-StringData -StringData @'
        GettingIPAddress = Getting the IP address for network adapter '{0}'.
        SettingIPAddress = Setting IP address '{0}' for network adapter '{1}'.
        IPAddressDoesNotMatch = IPAddress does not match desired state. Expected '{0}', actual '{1}'.
        ResourcePropertyMismatch = Property '{0}' does not match the desired state; expected '{1}', actual '{2}'.
        ResourceInDesiredState = Resource '{0}' is in the desired state.
        ResourceNotInDesiredState = Resource '{0}' is NOT in the desired state.
'@
}

function ConvertFrom-CIDR {
    [CmdletBinding()]
    [OutputType([System.String])]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [Uint32] $CIDR
    )
    ## Convert CIDR to netmask
    $int64 = ([System.Convert]::ToInt64(('1'*$CIDR + '0'*(32-$CIDR)), 2));
    return '{0}.{1}.{2}.{3}' -f ([System.Math]::Truncate($int64 / 16777216)).ToString(),
        ([System.Math]::Truncate(($int64 % 16777216) / 65536)).ToString(),
        ([System.Math]::Truncate(($int64 % 65536) / 256)).ToString(),
        ([System.Math]::Truncate($int64 % 256)).ToString();

} #end function ConvertFrom-CIDR

function ConvertTo-CIDR {
    [CmdletBinding()]
    [OutputType([System.String])]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [System.String] $SubnetMask
    )

    $SubnetMask -split '\.' | ForEach-Object { $subnet = $subnet * 256 + [System.Convert]::ToInt64($_); }
    return [System.Convert]::ToString($subnet, 2).IndexOf('0');

} #end function ConvertTo-CIDR

function Get-NetworkAdapter {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [System.String] $InterfaceAlias
    )

    $adapaterFilter = 'NetConnectionID = "{0}"' -f $InterfaceAlias;
    $adapater = Get-WmiObject -Class Win32_NetworkAdapter -Filter $adapaterFilter;
    $configurationFilter = 'Index = {0}' -f $adapater.DeviceID;
    return Get-WmiObject -Class Win32_NetworkAdapterConfiguration -Filter $configurationFilter;

} #end function Get-NetworkAdapter

function Get-TargetResource {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param (
        [Parameter(Mandatory)]
        [String] $IPAddress,

        [Parameter(Mandatory)]
        [String] $InterfaceAlias,

        [Parameter()]
        [UInt32] $SubnetMask = 16,

        [Parameter()] [ValidateSet('IPv4')]
        [String] $AddressFamily = 'IPv4'
    )
    
    Write-Verbose -Message ($localized.GettingIPAddress -f $InterfaceAlias);
    $configuration = Get-NetworkAdapter -InterfaceAlias $InterfaceAlias;

    $IPAddresses = @();
    for ($i = 0; $i -lt $configuration.IPAddress.Count; $i++) { 
        if ($configuration.IPAddress[$i] -match '\.') {
            $IPAddresses += $configuration.IPAddress[$i];
            $subnetCIDR = ConvertTo-CIDR -SubnetMask $configuration.IPSubnet[$i];
        }
    }

    $targetResource = @{
        IPAddress = $IPAddresses -join ',';
        InterfaceAlias = $InterfaceAlias;
        SubnetMask = $subnetCIDR;
        AddressFamily = $AddressFamily;
    }

    return $targetResource;

} #end function Get-TargetResource

function Test-TargetResource {
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param (
        [Parameter(Mandatory)]
        [String] $IPAddress,

        [Parameter(Mandatory)]
        [String] $InterfaceAlias,

        [Parameter()]
        [UInt32] $SubnetMask = 16,

        [Parameter()] [ValidateSet('IPv4')]
        [String] $AddressFamily = 'IPv4'
    )

    $targetResource = Get-TargetResource @PSBoundParameters;
    $inDesiredState = $true;

    if ($targetResource.IPAddress -notcontains $IPAddress) {
        Write-Verbose -Message ($localized.ResourcePropertyMismatch -f 'IPAddress', $IPAddress, $targetResource.IPAddress);
        $inDesiredState = $false;   
    }
    elseif ($targetResource.SubnetMask -ne $SubnetMask) {
        Write-Verbose -Message ($localized.ResourcePropertyMismatch -f 'SubnetMask', $SubnetMask, $targetResource.SubnetMask);
        $inDesiredState = $false;   
    }

    if ($inDesiredState) {
        Write-Verbose -Message ($localized.ResourceInDesiredState -f $InterfaceAlias);
        return $true;
    }
    else {
        Write-Verbose -Message ($localized.ResourceNotInDesiredState -f $InterfaceAlias);
        return $false;
    }

} #end function Test-TargetResource

function Set-TargetResource {
    param (
        [Parameter(Mandatory)]
        [String] $IPAddress,

        [Parameter(Mandatory)]
        [String] $InterfaceAlias,

        [Parameter()]
        [UInt32] $SubnetMask = 16,

        [Parameter()] [ValidateSet('IPv4')]
        [String] $AddressFamily = 'IPv4'
    )

    $configuration = Get-NetworkAdapter -InterfaceAlias $InterfaceAlias;
    $subnetMaskString = ConvertFrom-CIDR -CIDR $SubnetMask;
    $ipAddressString = '{0}/{1}' -f $IPAddress, $subnetMaskString;
    Write-Verbose -Message ($localized.SettingIPAddress -f $ipAddressString, $InterfaceAlias);
    [ref] $null = $configuration.EnableStatic($IPAddress, $subnetMaskString);

} #end function Set-TargetResource

Export-ModuleMember -Function *-TargetResource;
