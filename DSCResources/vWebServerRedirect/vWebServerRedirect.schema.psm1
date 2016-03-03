<#
    .SYNOPSIS
        Creates a Javascript document, redirecting to another URL
#>
configuration vWebServerRedirect {
    param (
        ## Relative or absolute redirect path, i.e. /Citrix/StoreWeb/
        [Parameter(Mandatory)]
        [System.String] $RedirectUrl,
        
        ## Default document path
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $Path = 'C:\inetpub\wwwroot\index.htm',
        
        [Parameter()] [ValidateSet('Present','Absent')]
        [System.String] $Ensure = 'Present'
    )
    
    Import-DSCResource -Module PSDesiredStateConfiguration;
    
    $defaultDocument = @"
<script type="text/javascript">
<!--
window.location="$RedirectUrl";
// -->
</script>    
"@
    
    File 'vWebServerRedirect' {
        DestinationPath = $Path;
        Contents = $defaultDocument;
        Type = 'File'
        Ensure = $Ensure;
    }
} #end configuration vWebServerRedirect
