data localized {
    # culture="en-US"
    ConvertFrom-StringData -StringData @'
        GettingGatewayAddress = Getting the default gateway address for network adapter '{0}'.
        SettingGatewayAddress = Setting default gateway address '{0}' for network adapter '{1}'.
        IPAddressDoesNotMatch = IPAddress does not match desired state. Expected '{0}', actual '{1}'.
        ResourcePropertyMismatch = Property '{0}' does not match the desired state; expected '{1}', actual '{2}'.
        ResourceInDesiredState = Resource '{0}' is in the desired state.
        ResourceNotInDesiredState = Resource '{0}' is NOT in the desired state.
'@
}

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
        [System.String] $Address,

        [Parameter(Mandatory)]
        [System.String] $InterfaceAlias,

        [Parameter()] [ValidateSet('IPv4')]
        [System.String] $AddressFamily = 'IPv4'
    )
    
    Write-Verbose -Message ($localized.GettingGatewayAddress -f $InterfaceAlias);
    $configuration = Get-NetworkAdapter -InterfaceAlias $InterfaceAlias;

    $targetResource = @{
        Address = $configuration.DefaultIPGateway -join ',';
        InterfaceAlias = $InterfaceAlias;
        AddressFamily = $AddressFamily;
    }

    return $targetResource;

} #end function Get-TargetResource

function Test-TargetResource {
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param (
        [Parameter(Mandatory)]
        [String] $Address,

        [Parameter(Mandatory)]
        [String] $InterfaceAlias,

        [Parameter()] [ValidateSet('IPv4')]
        [String] $AddressFamily = 'IPv4'
    )

    $targetResource = Get-TargetResource @PSBoundParameters;
    $inDesiredState = $true;

    if ($targetResource.Address -ne $Address) {
        Write-Verbose -Message ($localized.ResourcePropertyMismatch -f 'Address', $Address, $targetResource.Address);
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

} #end Test-TargetResource

function Set-TargetResource {
    param (
        [Parameter(Mandatory)]
        [String] $Address,

        [Parameter(Mandatory)]
        [String] $InterfaceAlias,

        [Parameter()] [ValidateSet('IPv4')]
        [String] $AddressFamily = 'IPv4'
    )

    $configuration = Get-NetworkAdapter -InterfaceAlias $InterfaceAlias;
    Write-Verbose -Message ($localized.SettingGatewayAddress -f $Address, $InterfaceAlias);
    [ref] $null = $configuration.SetGateways($Address);
}

Export-ModuleMember -Function *-TargetResource;
