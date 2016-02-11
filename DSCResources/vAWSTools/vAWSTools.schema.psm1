configuration vAWSTools {
    <#
        .SYNOPSIS
            Virtual Engine DSC Amazon Web Tools composite resource.
        .DESCRIPTION
            The vAWSTools Powershell Desired Configuration State composite resource
            is used for downloading and installing the AWS Powershell Tools that
            are required to download files from AWS S3. This is a prerequisite for
            the cS3RemoteFile custom DSC resource to function.
    #>
    param (
        [Parameter()] [ValidateNotNullOrEmpty()] [System.String] $SourcePath = (Join-Path -Path $env:SystemDrive -ChildPath Sources),
        [Parameter()] [ValidateNotNullOrEmpty()] [System.String] $FileName = 'AWSToolsAndSDKForNet.msi',
        [Parameter()] [ValidateNotNullOrEmpty()] [System.String] $Uri = 'http://sdk-for-net.amazonwebservices.com/latest/AWSToolsAndSDKForNet.msi'
    )

    Import-DscResource -Module xPSDesiredStateConfiguration;
   
    File 'Sources' {
        DestinationPath = $SourcePath;
        Type = 'Directory';
        Ensure = 'Present';
    }

    ## Download Binaries
    xRemoteFile 'AWSToolsAndSDKForNetDownload' {
        #Ensure = 'Present';
        DestinationPath = Join-Path -Path $SourcePath -ChildPath $FileName;
        Uri = $Uri;
    }

    ## Install AWS SDK
    Package 'AWSPowershellToolsInstall' {
        Ensure = 'Present';
        Name = 'AWS Tools for Windows';
        Path = Join-Path -Path $SourcePath -ChildPath $FileName;
        ProductId = 'EEE1BFFB-7501-4F9D-88D4-705C53D403C1';
        Arguments = 'ADDLOCAL=SDK_NET45,SDK_NET35,AWSPowerShell';
        DependsOn = '[xRemoteFile]AWSToolsAndSDKForNetDownload';
    }
}