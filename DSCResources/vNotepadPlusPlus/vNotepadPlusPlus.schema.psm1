configuration vNotepadPlusPlus {
    param (
        ## Path to Notepad++ installation exe
        [Parameter(Mandatory)] [ValidateNotNull()]
        [System.String] $Path
    )
 
    # Import the module that defines custom resources
    Import-DscResource -Module xPSDesiredStateConfiguration;

    xPackage NotepadPlusPlus {
        Name = 'Notepad++';
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
