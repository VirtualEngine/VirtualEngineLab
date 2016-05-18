configuration vScheduledTask {
    param (
        ## Scheduled task name
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()]
        [System.String] $TaskName,
        
        ## Task scheduler folder/path
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()]
        [System.String] $TaskPath,
        
        ## Target scheduled task state 
        [Parameter(Mandatory)] [ValidateSet('Enabled','Disabled')]
        [System.String] $State
    )
    
    ## Requires Server 2012/Windows 8 or later

    Import-DscResource -ModuleName PSDesiredStateConfiguration;
    
    $scriptResourceId = $TaskName.Replace(' ','');
    Script $scriptResourceId {
        
        GetScript = {
            $task = Get-ScheduledTask -TaskName $using:TaskName -TaskPath $using:TaskPath;
            return @{ Target = $task.State; }
        }
        
        TestScript = {
            $task = Get-ScheduledTask -TaskName $using:TaskName -TaskPath $using:TaskPath;
            if ($using:State -eq 'Enabled') {
                ## Task could also be Ready or Queued
                return ($task.State -ne 'Disabled');
            }
            else {
                return ($task.State -eq $using:State);
            }
        }
        
        SetScript = {
            if ($using:State -eq 'Enabled') {
                [ref] $null = Enable-ScheduledTask -TaskName $using:TaskName -TaskPath $using:TaskPath;
            }
            else {
                [ref] $null = Disable-ScheduledTask -TaskName $using:TaskName -TaskPath $using:TaskPath;
            }
        }
    
    } #end script
    
} #end configuration vScheduledTask
