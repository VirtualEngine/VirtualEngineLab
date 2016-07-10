configuration vDismFeature {
    param (
        ## DISM feature name
        [Parameter(Mandatory)]
        [System.String] $Name,

        ## DISM feature installation state
        [Parameter(Mandatory)] [ValidateSet('Present','Absent')]
        [System.String] $Ensure = 'Present'
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration;

    Script $Name {

        GetScript = {
            $feature = & DISM.EXE /Online /Get-Features /Format:Table | Where-Object { $_ -imatch "$using:Name" };
            $featureState = ($feature.Split('|')[1]).Trim();
            return @{ Result = $featureState; }
        }

        TestScript = {
            $dismFeature = & DISM.EXE /Online /Get-Features /Format:Table | Where-Object { $_ -imatch "$using:Name" }
            $featureState = ($dismFeature.Split('|')[1]).Trim();
            if (($using:Ensure -eq 'Present') -and ($featureState -eq 'Enabled')) {
                return $true;
            }
            elseif (($using:Ensure -eq 'Absent') -and ($featureState -eq 'Disabled')) {
                return $true;
            }
            return $false;
        }

        SetScript = {
            if ($using:Ensure -eq 'Present') {
                & DISM.EXE /Online /Enable-Feature /FeatureName:$using:Name;
            }
            elseif ($using:Ensure -eq 'Absent') {
                & DISM.EXE /Online /Disable-Feature /FeatureName:$using:Name;
            }
        }

} #end script
} #end configuration vDismFeature
