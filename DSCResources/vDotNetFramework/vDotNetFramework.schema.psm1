configuration vDotNetFramework {
    param (
        ## Path to .NET Framework installation exe
        [Parameter(Mandatory)] [ValidateNotNull()]
        [System.String] $Path,

        ## Minimum .NET Framework build number
        ## https://docs.microsoft.com/en-us/dotnet/framework/migration-guide/how-to-determine-which-versions-are-installed
        [Parameter(Mandatory)] [ValidateNotNull()]
        [System.Int32] $MinimumBuildNumber
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration;

    Script 'vDotNetFramework' {
        GetScript = {
            return @{ Result = Get-ChildItem 'HKLM:SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full\' | Get-ItemPropertyValue -Name Release }
        }

        SetScript = {
            Start-Process -FilePath $Path -ArgumentList '/q /norestart' -Wait;
        }

        TestScript = {
            Get-ChildItem 'HKLM:SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full\' |
                Get-ItemPropertyValue -Name Release |
                    ForEach-Object { $_ -ge $MinimumBuildNumber }
        }
    } #end script vDotNetFramework

} #end configuration
