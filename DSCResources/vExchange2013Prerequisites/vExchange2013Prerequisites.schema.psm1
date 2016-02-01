configuration vExchange2013Prerequisites {
    param (
        ## Path to Unified Communications Managed API 4 exe
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()]
        [System.String] $UCMAPath
    )

    Import-DscResource -Module xPSDesiredStateConfiguration;

    foreach ($feature in @(
        'AS-HTTP-Activation',
        'Desktop-Experience',
        'NET-Framework-45-Features',
        'RPC-over-HTTP-proxy',
        'RSAT-ADDS',
        'RSAT-ADDS-Tools',
        'RSAT-Clustering',
        'RSAT-Clustering-CmdInterface',
        'Web-Mgmt-Console',
        'WAS-Process-Model',
        'Web-Asp-Net45',
        'Web-Basic-Auth',
        'Web-Client-Auth',
        'Web-Digest-Auth',
        'Web-Dir-Browsing',
        'Web-Dyn-Compression',
        'Web-Http-Errors',
        'Web-Http-Logging',
        'Web-Http-Redirect',
        'Web-Http-Tracing',
        'Web-ISAPI-Ext',
        'Web-ISAPI-Filter',
        'Web-Lgcy-Mgmt-Console',
        'Web-Metabase',
        'Web-Mgmt-Service',
        'Web-Net-Ext45',
        'Web-Request-Monitor',
        'Web-Server',
        'Web-Stat-Compression',
        'Web-Static-Content',
        'Web-Windows-Auth',
        'Web-WMI',
        'Windows-Identity-Foundation',
        'RSAT-AD-PowerShell')) {

        WindowsFeature $feature {
            Name = $feature;
            Ensure = 'Present';
        }
    } #end foreach feature

    xPackage UcmaRuntime {
        Name = 'Unified Communications Managed API 4.0';
        ProductId = '{41D635FE-4F9D-47F7-8230-9B29D6D42D31}';
        Path = $UCMAPath;
        Arguments = '-q';
    }

} #end configuration vExchange2013Prerequisites
