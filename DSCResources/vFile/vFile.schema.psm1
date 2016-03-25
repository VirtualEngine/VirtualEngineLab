configuration vFile {
    <#
        .SYNOPSIS
            Downloads files from file or web servers based on the URI.
        .NOTES
            Requires the xRemoteFile resource from the xPSDesiredStateConfiguration module.
    #>
    param (
        ## The key used for the resource to avoid only being able to download one resource
        [Parameter(Mandatory)] [System.String] $Key,
        ## The file, unc or http Uri of the resource to download
        [Parameter(Mandatory)] [System.String] $Uri,
        ## The target/output path to download/copy the file to on the node
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()] [System.String] $DestinationPath,
        ## Credential used to invoke the download
        [Parameter()] [AllowNull()] [PSCredential] $Credential,
        ## File resource type for file-based resources
        [Parameter()] [ValidateSet('File','Directory')] $Type = 'File'
    )

    Import-DscResource -ModuleName xPSDesiredStateConfiguration;

    $uriScheme = (New-Object -TypeName System.Uri).Scheme;
    if ($uriScheme -eq 'http') {
        
        if ($Credential) {
            xRemoteFile $Key {
                DestinationPath = $DestinationPath;
                Uri = $Uri;
                Credential = $Credential;
            }
        }
        else {
            xRemoteFile $Key {
                DestinationPath = $DestinationPath;
                Uri = $Uri;
            }
        }

    } #end if scheme = http

    elseif ($uriScheme -eq 'file') {
        
        if ($Type -eq 'File') {
            if ($Credential) {
                File $Key {
                    SourcePath = $Uri;
                    DestinationPath = $DestinationPath;
                    Credential = $Credential;
                    Type = 'File';
                }
            }
            else {
                File $Key {
                    SourcePath = $Uri;
                    DestinationPath = $DestinationPath;
                    Type = 'File';
                }
            }
        } #end if file
        
        elseif ($Type -eq 'Directory') {
            if ($Credential) {
                File $Key {
                    SourcePath = $Uri;
                    DestinationPath = $DestinationPath;
                    Credential = $Credential;
                    Type = 'Directory';
                    Recurse = $true;
                }
            }
            else {
                File $Key {
                    SourcePath = $Uri;
                    DestinationPath = $DestinationPath;
                    Type = 'Directory';
                    Recurse = $true;
                }
            }
        } #end if directory

    } #end if scheme = file

} #end configuration vFile
