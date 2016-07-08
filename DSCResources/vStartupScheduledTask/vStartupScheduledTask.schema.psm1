configuration vStartupScheduledTask {
    param (
        ## Scheduled task name
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()]
        [System.String] $TaskName,

        ## Command to execute
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()]
        [System.String] $TaskCommand
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration;

    $scriptResourceId = $TaskName.Replace(' ','').Replace('\','_');
    Script $scriptResourceId {

        GetScript = {

            $task = & "$env:windir\System32\schtasks.exe" /Query /TN "$using:TaskName" 2>&1;
            foreach ($taskString in $task) {
                Write-Verbose -Message $taskString;
            }
            if (($task -join ',') -imatch 'ERROR') {
                return @{ Target = 'Absent'; }
            }
            else {
                return @{ Result = 'Present'; }
            }

        }

        TestScript = {

            $task = & "$env:windir\System32\schtasks.exe" /Query /TN "$using:TaskName" 2>&1;
            foreach ($taskString in $task) {
                Write-Verbose -Message $taskString;
            }
            if (($task -join ',') -imatch 'ERROR') {
                return $false;
            }
            else {
                return $true;
            }

        }

        SetScript = {

            & "$env:windir\System32\schtasks.exe" /Create /RU SYSTEM /SC ONSTART /TN "$TaskName" /TR "$TaskCommand" /RL HIGHEST /F;

        }

    } #end script

} #end configuration vStartupScheduledTask
