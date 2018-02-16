configuration vFolder {
    param (
        ## Collection of folders to provision
        [Parameter(Mandatory)]
        [System.Collections.Hashtable[]] $Folders
    )

    Import-DscResource -Module PSDesiredStateConfiguration, xSmbShare, PowerShellAccessControl;

    foreach ($folder in $Folders) {

        $folderId = $folder.Path.Replace(':','').Replace(' ','').Replace('\','_');

        File $folderId {
            DestinationPath = $folder.Path;
            Type = 'Directory';
        }

        if ($folder.ReadNtfs) {

            cAccessControlEntry $folderId {
                Ensure = 'Present';
                Path = $folder.Path;
                AceType = 'AccessAllowed';
                ObjectType = 'Directory';
                AccessMask = [System.Security.AccessControl.FileSystemRights]::ReadAndExecute;
                Principal = $folder.ReadNtfs;
                DependsOn = "[File]$folderId";
            }
        }

        if ($folder.ModifyNtfs) {

            cAccessControlEntry $folderId {
                Ensure = 'Present';
                Path = $folder.Path;
                AceType = 'AccessAllowed';
                ObjectType = 'Directory';
                AccessMask = [System.Security.AccessControl.FileSystemRights]::Modify;
                Principal = $folder.ModifyNtfs;
                DependsOn = "[File]$folderId";
            }
        }

        if ($folder.FullControlNtfs) {

            cAccessControlEntry $folderId {
                Ensure = 'Present';
                Path = $folder.Path;
                AceType = 'AccessAllowed';
                ObjectType = 'Directory';
                AccessMask = [System.Security.AccessControl.FileSystemRights]::FullControl;
                Principal = $folder.FullControlNtfs;
                DependsOn = "[File]$folderId";
            }
        }

        if ($folder.Share) {

            $folderName = $folder.Share.Replace('$','');

            if ($folder.FullControl -and $folder.ChangeControl -and $folder.Description) {

                xSmbShare $folderName {
                    Name = $folder.Share;
                    Path = $folder.Path;
                    Description = $folder.Description;
                    FullAccess = $folder.FullControl;
                    ChangeAccess = $folder.ChangeControl;
                    Ensure = 'Present';
                    DependsOn = "[File]$folderId";
                }
            }
            elseif ($folder.FullControl -and $folder.ChangeControl) {

                xSmbShare $folderName {
                    Name = $folder.Share;
                    Path = $folder.Path;
                    FullAccess = $folder.FullControl;
                    ChangeAccess = $folder.ChangeControl;
                    Ensure = 'Present';
                    DependsOn = "[File]$folderId";
                }
            }
            elseif ($folder.FullControl -and $folder.Description) {

                xSmbShare $folderName {
                    Name = $folder.Share;
                    Path = $folder.Path;
                    Description = $folder.Description;
                    FullAccess = $folder.FullControl;
                    Ensure = 'Present';
                    DependsOn = "[File]$folderId";
                }
            }
            elseif ($folder.ChangeControl -and $folder.Description) {

                xSmbShare $folderName {

                    Name = $folder.Share;
                    Path = $folder.Path;
                    Description = $folder.Description;
                    ChangeAccess = $folder.ChangeControl;
                    Ensure = 'Present';
                    DependsOn = "[File]$folderId";
                }
            }
            elseif ($folder.Description) {

                xSmbShare $folderName {
                    Name = $folder.Share;
                    Path = $folder.Path;
                    Description = $folder.Description;
                    Ensure = 'Present';
                    DependsOn = "[File]$folderId";
                }
            }
            elseif ($folder.FullControl) {

                xSmbShare $folderName {
                    Name = $folder.Share;
                    Path = $folder.Path;
                    FullAccess = $folder.FullControl;
                    Ensure = 'Present';
                    DependsOn = "[File]$folderId";
                }
            }
            elseif ($folder.ChangeControl) {

                xSmbShare $folderName {
                    Name = $folder.Share;
                    Path = $folder.Path;
                    ChangeAccess = $folder.ChangeControl;
                    Ensure = 'Present';
                    DependsOn = "[File]$folderId";
                }
            }
            else {

                xSmbShare $folderName {
                    Name = $folder.Share;
                    Path = $folder.Path;
                    Ensure = 'Present';
                    DependsOn = "[File]$folderId";
                }
            }
        } #end if shared

    } #end foreach folder
    
} #end configuration vTrainingLabFolders
