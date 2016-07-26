configuration vWindowsRearm {
    param (
        ## Target path of the Windows Rearm script
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()]
        [System.String] $DestinationPath,

        ## Name of the startup scheduled task
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $TaskName = 'Virtual Engine\Windows Rearm'
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration;

    $windowsRearmScript = @'
$DebuglogPreference = $true ## Set to $true if you want an output log created
$Days = 1 ## Number of days to check for grace period before doing anything
$LogFilePath = 'C:\Windows\Temp\VE_Rearm.txt' ## Log file location
$registryPath = "HKLM:\SOFTWARE\Virtual Engine"
$registryName = "SkipRearmCount"
$registryValue = 1

function Get-WindowsVersion {
    [CmdletBinding()] param ()

    Begin{}

    process {

        $OSVersion = (Get-WmiObject -class Win32_OperatingSystem).Caption
        Write-DebugLog("$Date - Detected running OS '{0}'." -f $OSVersion);
        Return $OSVersion
    }

    End{}
}

function Write-DebugLog {

    [CmdletBinding()]
    param (
        [string]$message,
        [string]$filepath = $LogFilePath

    )

    Begin{}

    Process {

           if ($DebuglogPreference -eq $true) {

             $message | Out-File $filepath -append
           }
           else
           {

            $VerbosePreference = 'Continue'
            Write-Verbose("$message")

           }

    }

    End{}

}

function Test-RegistryValue {

    [CmdletBinding()]
    param (

    [parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]$Path,

    [parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]$Value
    )

    try {

        $regObj = Get-ItemProperty -Path $Path -ErrorAction Stop | Out-Null
        $regObj | Select-Object -ExpandProperty $Value -ErrorAction Stop | Out-Null
         return $true
     }

    catch {

        return $false

    }

}

function Get-Win7RACount {
    [CmdletBinding()] param ()

    Begin{}

    process {

        ## I can find the rearm count using /dlv
        $result = cscript.exe //nologo c:\windows\system32\slmgr.vbs /dlv

        ## Find the rearm count by finding the last 2 characters
        $a = ($result | Select-String 'rearm').ToString()
        $rearmcount = $a.Substring($a.Length - 1, 1)

        Return $rearmcount
    }

    End{}
}

function Test-EvalEdition {
    [CmdletBinding()] param ()

    Begin{}

    process {


        $result = cscript.exe //nologo c:\windows\system32\slmgr.vbs /dlv

        ## Return True or False
        Return [bool] ($result -match 'TIMEBASED_EVAL')
    }

    End{}
}



## Clear contents of log file first if it exists
##If (test-path $LogFilePath) {Clear-Content -Path $LogFilePath}

$Date = Get-Date -Format g
$osVersion = Get-WindowsVersion

## Ensure we're using an Windows Eval otherwise exit script - VL editions screw up if rearming
if ((Test-EvalEdition) -eq $false) {
    Write-DebugLog("$Date - Windows Evaluation Edition not found. Exiting.");
    #return;
}

## Use WMI to grab all the SoftwareLicensingProduct information
$SLObj = Get-WmiObject SoftwareLicensingProduct -Filter "Description LIKE '%TIMEBASED_EVAL%'" -ErrorAction SilentlyContinue

## Rearm Count for Win8.1/10/2012
$rearmcount = $SLObj.RemainingAppReArmCount


if ($osVersion -match 'Windows 7') {

    ## We need to activated Windows 7 first and after every rearm
    ## LicenseStatus = 1 (Licensed), = 0 (Unlicensed)
    if ($SLObj.LicenseStatus -ne 1) {

        Write-DebugLog("$Date - Windows Unlicensed so activating now.")
        $result = cscript.exe //nologo c:\windows\system32\slmgr.vbs /ato
        Write-DebugLog("$Date - $result")

    }

    ## Can't find the remaining rearm count from WMI on Win7 so working around this
    Write-DebugLog("$Date - Detected Windows 7 so finding rearm count a different way.")
    $rearmcount = Get-Win7RACount

}

## Grace Period is in minutes therefore divide by 1440 to get number of days
$gpDays = [math]::Round($SLObj.GracePeriodRemaining/1440)

Write-DebugLog("$Date - Check for Windows License to Expire in {0} Days." -f ($gpDays - $Days))
Write-DebugLog("$Date - Windows License Valid for {0} Days." -f $gpDays)
Write-DebugLog("$Date - Remaining Rearm Count = {0}." -f $rearmcount)

## Check If Grace Period is less than 1 day and it's not Windows 10
if (($gpDays -le $Days) -and ($osVersion -Notmatch 'Microsoft Windows 10')) {

    ## If Remaining ReArm Count is less that 0, we need to set this registry value to enable us to rearm again.
    if ($rearmcount -eq 0) {

        #Write-DebugLog("$Date - Remaining Rearm Count = {0}" -f $SLObj.RemainingAppReArmCount)

        Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SoftwareProtectionPlatform" -Name "SkipRearm" -Value 1
        Write-DebugLog("$Date - Changing 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SoftwareProtectionPlatform' SkipRearm Registry Value to 1")

        $result = Test-RegistryValue -Path $registryPath -Value $registryName -ErrorAction SilentlyContinue

        if ($result -eq $false) {

            New-Item -Path $registryPath -Force | Out-Null
            New-ItemProperty $registryPath -Name $registryName -Value $registryValue -PropertyType DWORD -Force | Out-Null

        }
        else {

            $Value = Get-ItemProperty $registryPath -Name $registryName
            Set-ItemProperty $registryPath -Name $registryName -Value ($Value.SkipRearmCount + 1)

        }

        $Value= Get-ItemProperty $registryPath -Name $registryName
        Write-DebugLog("$Date - 'SkipRearm' Registry Value Set {0} Time(s)." -f $Value.SkipRearmCount)

    }

    Write-DebugLog("$Date - Windows Rearm Required!")
    ## Rearm Windows - Restart is needed afterwards to take effect
    $result = cscript.exe //nologo c:\windows\system32\slmgr.vbs /rearm
    Write-DebugLog("$Date - $result")

 }

Write-DebugLog("")
'@

    ## Remove spaces in path as SCHTASKS.EXE doesn't like them
    $resourcePath = $DestinationPath.Replace(' ','');

    $resourceParentPath = $resourcePath;
    $resourcePaths = @();
    $resourceDependsOn = @();

    ## Find all the folders in the specified destination path
    while ((Split-Path -Path $resourceParentPath -Parent) -notmatch '^.:\\$') {
        $resourceParentPath = Split-Path -Path $resourceParentPath -Parent;
        $resourcePaths += $resourceParentPath;
    }

    ## Process the discovered folders in reverse order
    for ($i = ($resourcePaths.Length -1); $i -ge 0; $i--) {

        $resourceName = $resourcePaths[$i].Replace(':','').Replace('\','_');

        ## Only hide the first (root) folder
        if ($i -eq ($resourcePaths.Length -1)) {

            File $resourceName {
                DestinationPath = $resourcePaths[$i];
                Type            = 'Directory';
                Attributes      = 'Hidden';
                Ensure          = 'Present';
            }
        }
        else {

            File $resourceName {
                DestinationPath = $resourcePaths[$i];
                Type            = 'Directory';
                Ensure          = 'Present';
                DependsOn       = $resourceDependsOn;
            }
        }

        $resourceDependsOn += "[File]$resourceName";

    } #end foreach folder

    File 'WindowsRearm_ps1' {
        DestinationPath = $resourcePath;
        Contents        = $windowsRearmScript;
        Type            = 'File';
        Ensure          = 'Present';
        DependsOn       = $resourceDependsOn;
    }

    Script 'WindowsRearmTask' {

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

            $taskCommand = 'Powershell.exe -ExecutionPolicy RemoteSigned -File "{0}"' -f $using:resourcePath;
            & "$env:windir\System32\schtasks.exe" /Create /RU SYSTEM /SC ONSTART /RL HIGHEST /F /TN "$using:TaskName" /TR "$taskCommand";
        }

        DependsOn = '[File]WindowsRearm_ps1';

    } #end script WindowsRearmTask

} #end configuration vWindowsRearm
