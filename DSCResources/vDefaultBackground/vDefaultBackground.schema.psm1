configuration vDefaultBackground {
    param (
        ## Source desktop wallpaper path
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()]
        [System.String] $Path
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration;

    Script 'DefaultDesktopWallpaper' {

        GetScript = {

            $destinationFileHash = (Get-FileHash -Path "$env:SystemRoot\Web\Wallpaper\Windows\img0.jpg" -Algorithm MD5).Hash;
            return @{
                Result = $fileHash;
            }
        }

        TestScript = {

            $sourceFileHash = (Get-FileHash -Path $using:Path -Algorithm MD5).Hash;
            $destinationFileHash = (Get-FileHash -Path "$env:SystemRoot\Web\Wallpaper\Windows\img0.jpg" -Algorithm MD5).Hash;
            return ($destinationFileHash -eq $sourceFileHash);
        }

        SetScript = {

            & "$env:SystemRoot\System32\takeown.exe" /f "$env:SystemRoot\Web\wallpaper\Windows\img0.jpg";
            & "$env:SystemRoot\System32\icacls.exe" "$env:SystemRoot\Web\wallpaper\Windows\img0.jpg" /Grant 'System:(F)';
            Remove-Item -Path "$env:SystemRoot\Web\wallpaper\Windows\img0.jpg";
            Copy-Item -Path $using:Path -Destination "$env:SystemRoot\Web\wallpaper\Windows\img0.jpg";
        }

    } #end script DefaultDesktopWallpaper

} #end configuration vDefaultBackground
