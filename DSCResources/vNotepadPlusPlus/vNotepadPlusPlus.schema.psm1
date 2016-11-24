configuration vNotepadPlusPlus {
    param (
        ## Path to Notepad++ installation exe
        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [System.String] $Path,

        ## Override the package name used to check for product installation
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String] $ProductName = 'Notepad++'
    )

    # Import the module that defines custom resources
    Import-DscResource -ModuleName xPSDesiredStateConfiguration;

    xPackage 'NotepadPlusPlus' {
        Name = $ProductName;
        ProductId = '';
        Path = $Path;
        Arguments = '/S';
        ReturnCode = 0;
        InstalledCheckRegKey = 'Software\Notepad++';
        InstalledCheckRegValueName = 'Installed';
        InstalledCheckRegValueData = 'True';
        CreateCheckRegValue = $true;
    }

} #end configuration vNotepadPlusPlus
