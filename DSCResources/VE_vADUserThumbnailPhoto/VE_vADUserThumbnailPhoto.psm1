# Localized messages
data LocalizedData
{
    # culture="en-US"
    ConvertFrom-StringData @'
        RoleNotFoundError              = Please ensure that the PowerShell module for role '{0}' is installed.
        UserNotFoundError              = Active Directory user '{0}' ({0}@{1}) was not found.
        ThumbnailPathInvalidError      = The specified thumbnail path '{0}' is not valid.
        
        RetrievingADUser               = Retrieving Active Directory user '{0}' ({0}@{1}) ...
        ADUserIsPresent                = Active Directory user '{0}' ({0}@{1}) is present.
        ADUserNotPresent               = Active Directory user '{0}' ({0}@{1}) was NOT present.
        ADUserNotDesiredPropertyState  = User '{0}' property is NOT in the desired state. Expected '{1}', actual '{2}'.
        ADUserInDesiredState           = Active Directory user '{0}' ({0}@{1}) is in the desired state.
        ADUserNotInDesiredState        = Active Directory user '{0}' ({0}@{1}) is NOT in the desired state.
        
        SettingADUserProperty         = Setting user property '{0}' with/to '{1}'.
        ClearingADUserProperty        = Clearing user property '{0}'.
        LoadingThumbnailFromFile      = Loading thumbnail photo from file '{0}'.
'@
}

## Create a property map that maps the DSC resource parameters to the
## Active Directory user attributes.
$adPropertyMap = @(
    @{ Parameter = 'ThumbnailPhoto'; }
)

function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        ## Only used if password is managed.
        [Parameter(Mandatory)]
        [System.String] $DomainName,
        
        # SamAccountName
        [Parameter(Mandatory)]
        [System.String] $UserName,
        
        # Path to user's thumbnail photo or Base64 encoded photo
        [Parameter(Mandatory)]
        [System.String] $ThumbnailPhoto,

        ## Ideally this should just be called 'Credential' but is here for backwards compatibility
        [Parameter()] [ValidateNotNull()]
        [System.Management.Automation.PSCredential] $DomainAdministratorCredential,
        
        [Parameter()] [ValidateNotNull()]
        [System.String] $DomainController,
        
        [Parameter()] [ValidateSet('Present','Absent')]
        [System.String] $Ensure = 'Present'
    )
    
    Assert-Module -ModuleName 'ActiveDirectory';
    
    try
    {
        $adCommonParameters = Get-ADCommonParameters @PSBoundParameters;
        $adProperties = @('ThumbnailPhoto');
        Write-Verbose -Message ($LocalizedData.RetrievingADUser -f $UserName, $DomainName);
        $adUser = Get-ADUser @adCommonParameters -Properties $adProperties;
        Write-Verbose -Message ($LocalizedData.ADUserIsPresent -f $UserName, $DomainName);
    }
    catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException]
    {
        $errorMessage = $LocalizedData.UserNotFoundError -f $UserName, $DomainName;
        ThrowInvalidOperationError -ErrorId 'UserNotFound' -ErrorMessage $errorMessage;
    }
    catch
    {
        Write-Error -Message ($LocalizedData.RetrievingADUserError -f $UserName, $DomainName);
        throw $_;
    }

    $targetResource = @{
        DomainName        = $DomainName;
        UserName          = $UserName;
        DistinguishedName = $adUser.DistinguishedName; ## Read-only property
        Ensure            = if ($adUser.ThumbnailPhoto.Length -gt 0) { 'Present' } else { 'Absent' };
        ThumbnailPhotoHash = (Get-MD5HashString -Bytes $adUser.ThumbnailPhoto); 
    }
    
    return $targetResource;
} #end function Get-TargetResource

function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        ## Only used if password is managed.
        [Parameter(Mandatory)]
        [System.String] $DomainName,
        
        # SamAccountName
        [Parameter(Mandatory)]
        [System.String] $UserName,
        
        # Path to user's thumbnail photo or Base64 encoded photo
        [Parameter(Mandatory)]
        [System.String] $ThumbnailPhoto,

        ## Ideally this should just be called 'Credential' but is here for backwards compatibility
        [Parameter()] [ValidateNotNull()]
        [System.Management.Automation.PSCredential] $DomainAdministratorCredential,
        
        [Parameter()] [ValidateNotNull()]
        [System.String] $DomainController,
        
        [Parameter()] [ValidateSet('Present','Absent')]
        [System.String] $Ensure = 'Present'
    )
    
    $targetResource = Get-TargetResource @PSBoundParameters;
    $inDesiredState = $true;
    
    $thumbnailBytes = Get-ThumbnailBytes -ThumbnailPhoto $ThumbnailPhoto;
    $thumbnailPhotoHash = Get-MD5HashString -Bytes $thumbnailBytes;
    
    if ($Ensure -eq 'Present')
    {
        if ($thumbnailPhotoHash -ne $targetResource.ThumbnailPhotoHash)
        {
            Write-Verbose -Message ($LocalizedData.ADUserNotDesiredPropertyState -f 'ThumbnailPhoto', $thumbnailPhotoHash, $targetResource.ThumbnailPhotoHash);
            $inDesiredState = $false;    
        }
    }
    elseif ($Ensure -eq 'Absent')
    {
        if ($targetResource.ThumbnailPhotoHash)
        {
            Write-Verbose -Message ($LocalizedData.ADUserNotDesiredPropertyState -f 'ThumbnailPhoto', '<empty>', $targetResource.ThumbnailPhotoHash);
            $inDesiredState = $false;   
        }
    }
    
    if ($inDesiredState)
    {
        Write-Verbose -Message ($LocalizedData.ADUserInDesiredState -f $UserName, $DomainName);
        return $true;
    }
    else
    {
        Write-Verbose -Message ($LocalizedData.ADUserNotInDesiredState -f $UserName, $DomainName);
        return $false;    
    }

} #end function Test-TargetResource

function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        ## Only used if password is managed.
        [Parameter(Mandatory)]
        [System.String] $DomainName,
        
        # SamAccountName
        [Parameter(Mandatory)]
        [System.String] $UserName,
        
        # Path to user's thumbnail photo or Base64 encoded photo
        [Parameter(Mandatory)]
        [System.String] $ThumbnailPhoto,

        ## Ideally this should just be called 'Credential' but is here for backwards compatibility
        [Parameter()] [ValidateNotNull()]
        [System.Management.Automation.PSCredential] $DomainAdministratorCredential,
        
        [Parameter()] [ValidateNotNull()]
        [System.String] $DomainController,
        
        [Parameter()] [ValidateSet('Present','Absent')]
        [System.String] $Ensure = 'Present'
    )
    
    $targetResource = Get-TargetResource @PSBoundParameters;
    $setADUserParams = Get-ADCommonParameters @PSBoundParameters;
    
    if ($Ensure -eq 'Present')
    {
        $thumbnailPhotoBytes = Get-ThumbnailBytes -ThumbnailPhoto $ThumbnailPhoto;
        $thumbnailPhotoHash = Get-MD5HashString -Bytes $thumbnailPhotoBytes;
        Write-Verbose -Message ($LocalizedData.SettingADUserProperty -f 'ThumbnailPhoto', $thumbnailPhotoHash);
        [ref] $null = Set-ADUser @setADUserParams -Replace @{ thumbnailPhoto = $thumbnailPhotoBytes; }
    }
    elseif ($Ensure -eq 'Absent')
    {
        Write-Verbose -Message ($LocalizedData.ClearingADUserProperty -f 'ThumbnailPhoto');
        [ref] $null = Set-ADUser @setADUserParams -Clear ThumbnailPhoto;
    }
    
} #end function  Set-TargetResource

# Internal function to convert Base64 or filename to byte[]
function Get-ThumbnailBytes
{
    [CmdletBinding()]
    [OutputType([System.Byte[]])]
    param (
        [Parameter(Mandatory)]
        [System.String] $ThumbnailPhoto
    )
    
    ## If $ThumbnailPhoto contains '.' or '\' then we assume that we have a file path
    if ($ThumbnailPhoto.Contains('.') -or $ThumbnailPhoto.Contains('\'))
    {
        if (-not (Test-Path -Path $ThumbnailPhoto))
        {
            $errorMessage = ThumbnailPathInvalidError -f $ThumbnailPhoto;
            ThrowInvalidArgumentError -ErrorId 'InvalidThumbnailPath' -ErrorMessage $errorMessage;
        }
        Write-Verbose -Message ($LocalizedData.LoadingThumbnailFromFile -f $ThumbnailPhoto);
        return (Get-Content -Path $ThumbnailPhoto -Encoding Byte);     
    }
    else
    {
        return [System.Convert]::FromBase64String($ThumbnailPhoto);
    }
    
} #end function Get-ThumbnailBytes

# Internal function to calculate the thumbnailPhoto hash
function Get-MD5HashString
{
    [CmdletBinding()]
    [OutputType([System.Byte[]])]
    param
    (
        [Parameter(Mandatory)] [AllowNull()]
        [System.Byte[]] $Bytes
    )
    
    if ($null -ne $Bytes)
    {
        $md5 = [System.Security.Cryptography.MD5]::Create();
        $hashBytes = $md5.ComputeHash($Bytes);
        return ([System.BitConverter]::ToString($hashBytes).Replace('-',''));
    }
    
} #end function Get-MDHashString

# Internal function to build common parameters for the Active Directory cmdlets
function Get-ADCommonParameters
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $UserName,

        [ValidateNotNullOrEmpty()]
        [System.String]
        $CommonName,

        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]
        $DomainAdministratorCredential,

        [ValidateNotNullOrEmpty()]
        [System.String]
        $DomainController,

        [Parameter(ValueFromRemainingArguments)]
        $IgnoredArguments,

        [System.Management.Automation.SwitchParameter]
        $UseNameParameter
    )
    
    ## The Get-ADUser, Set-ADUser and Remove-ADUser cmdlets take an -Identity parameter, but the New-ADUser cmdlet uses the -Name parameter
    if ($UseNameParameter)
    {
        if ($PSBoundParameters.ContainsKey('CommonName'))
        {
            $adUserParameters = @{ Name = $CommonName; }
        }
        else
        {
            $adUserParameters = @{ Name = $UserName; }
        }
    }
    else
    {
        $adUserParameters = @{ Identity = $UserName; }
    }

    if ($DomainAdministratorCredential)
    {
        $adUserParameters['Credential'] = $DomainAdministratorCredential;
    }
    if ($DomainController)
    {
        $adUserParameters['Server'] = $DomainController;
    }
    return $adUserParameters;

} #end function Get-ADCommonParameters

# Internal function to assert if the role specific module is installed or not
function Assert-Module
{
    [CmdletBinding()]
    param
    (
        [System.String] $ModuleName = 'ActiveDirectory'
    )

    if (-not (Get-Module -Name $ModuleName -ListAvailable))
    {
        $errorId = 'xADUser_ModuleNotFound';
        $errorMessage = $LocalizedData.RoleNotFoundError -f $moduleName;
        ThrowInvalidOperationError -ErrorId $errorId -ErrorMessage $errorMessage;
    }
    
} #end function Assert-Module

function ThrowInvalidOperationError
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $ErrorId,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $ErrorMessage
    )

    $exception = New-Object -TypeName System.InvalidOperationException -ArgumentList $ErrorMessage;
    $errorCategory = [System.Management.Automation.ErrorCategory]::InvalidOperation;
    $errorRecord = New-Object -TypeName System.Management.Automation.ErrorRecord -ArgumentList $exception, $ErrorId, $errorCategory, $null;
    throw $errorRecord;
}

function ThrowInvalidArgumentError
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $ErrorId,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $ErrorMessage
    )

    $exception = New-Object -TypeName System.ArgumentException -ArgumentList $ErrorMessage;
    $errorCategory = [System.Management.Automation.ErrorCategory]::InvalidArgument;
    $errorRecord = New-Object -TypeName System.Management.Automation.ErrorRecord -ArgumentList $exception, $ErrorId, $errorCategory, $null;
    throw $errorRecord;

} #end function ThrowInvalidArgumentError
