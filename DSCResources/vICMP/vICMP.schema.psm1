configuration vICMP {
<#
    Requires xNetworking/dev (v2.5.0.0 or later):   https://github.com/PowerShell/xNetworking/dev (due to issue #34)
#>
    param (
        [Parameter()] [System.Boolean] $IPv4 = $true,
        [Parameter()] [System.Boolean] $IPv6 = $true
    )
 
    Import-DscResource -Module xNetworking;

    xFirewall 'xFirewall_ICMPv4' {
        Name = 'FPS-ICMP4-ERQ-In';
        DisplayName = 'File and Printer Sharing (Echo Request - ICMPv4-In)';
        Description = 'Echo request messages are sent as ping requests to other nodes.';
        Direction = 'Inbound';
        Action = 'Allow';
        Profile = 'Any';
        Enabled = $IPv4.ToString();
    }

    xFirewall 'xFirewall_ICMPv6' {
        Name = 'FPS-ICMP6-ERQ-In';
        DisplayName = 'File and Printer Sharing (Echo Request - ICMPv6-In)';
        Description = 'Echo request messages are sent as ping requests to other nodes.';
        Direction = 'Inbound';
        Action = 'Allow';
        Profile = 'Any';
        Enabled = $IPv6.ToString();
    }

}
