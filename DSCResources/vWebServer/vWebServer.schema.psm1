configuration vWebServer {
    param ( )
    
    Import-DscResource -ModuleName PSDesiredStateConfiguration;

    $features = @(
        'NET-Framework-45-ASPNET',
        'Web-Server',
        'Web-Common-Http',
        'Web-Default-Doc',
        'Web-Http-Errors',
        'Web-Static-Content',
        'Web-Http-Redirect',
        'Web-Http-Logging',
        'Web-Filtering',
        'Web-Basic-Auth',
        'Web-Windows-Auth',
        'Web-Net-Ext45',
        'Web-AppInit',
        'Web-Asp-Net45',
        'Web-ISAPI-Ext',
        'Web-ISAPI-Filter',
        'Web-Mgmt-Console',
        'Web-Scripting-Tools'
    )
    foreach ($feature in $features) {
        WindowsFeature $feature {
            Name = $feature;
            Ensure = 'Present';
        }
    } #end foreach feature

} #end configuration vWebServer
