configuration vFSLogixHotfix {
    param (
        ## Path to Microsoft hotfix installation .msu
        [Parameter(Mandatory)]
        [System.String] $Path,
        
        ## Hotfix ID
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String] $Id = 'KB2614892',
        
        [Parameter()]
        [ValidateSet('Present', 'Absent')]
        [System.String] $Ensure = 'Present'
    )
 
    # Import the module that defines custom resources
    Import-DscResource -ModuleName xWindowsUpdate;
     
    xHotfix $Id {
        Path = $Path;
        Id = $Id;
        Ensure = $Ensure;
    }

} #end configuration vFSLogixHotfix
