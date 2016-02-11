configuration vOfficeProPlus {
    param (
        ## Path to Office setup.exe
        [Parameter(Mandatory)] [ValidateNotNull()]
        [System.String] $Path,
        
        [Parameter(Mandatory)] [ValidateSet('2010','2013','2016')]
        [System.String] $Version,
        
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $CompanyName = 'VirtualEngine',
        
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $KmsServer,
        
        [Parameter()] 
        [System.Int32] $KmsServerPort = 1688
    )
 
    # Import the module that defines custom resources
    Import-DscResource -Module PSDesiredStateConfiguration;

    switch ($Version) {
        '2010' {
            $productName = 'Microsoft Office Professional Plus 2010';
            $productCode = '90140000-0011-0000-0000-0000000FF1CE';
        }
        '2013' {
            $productName = 'Microsoft Office Professional Plus 2013';
            $productCode = '90150000-0011-0000-0000-0000000FF1CE';
        }
        '2016' {
            $productName = 'Microsoft Office Professional Plus 2016';
            $productCode = '90160000-0011-0000-0000-0000000FF1CE';
        }
    }
    
    $configXmlNoKms = @'
<Configuration Product="ProPlus">
	<Display Level="Basic" CompletionNotice="no" SuppressModal="yes" AcceptEula="yes" />
	<Setting Id="SETUP_REBOOT" Value="Never" />
	<COMPANYNAME Value="{Company}" />
</Configuration>
'@;
    $configXmlKms = @'
<Configuration Product="ProPlus">
	<Display Level="Basic" CompletionNotice="no" SuppressModal="yes" AcceptEula="yes" />
	<Setting Id="SETUP_REBOOT" Value="Never" />
    <Setting Id="KMSSERVICENAME" Value="{KmsServer}" />
	<Setting Id="KMSSERVICEPORT" Value="{KmsPort}" />
	<COMPANYNAME Value="{Company}" />
</Configuration>
'@;

    $tempConfigPath = Join-Path -Path "$env:SYSTEMROOT\Temp\" -ChildPath ('{0}.xml' -f $productName.Replace(' ',''));
    
    if ($PSBoundParameters.ContainsKey('KmsServer')) {
        $configXml = $configXmlKms -replace '\{KmsServer\}',$KmsServer -replace '\{KmsPort\}',$KmsServerPort -replace '\{Company\}',$Company;
    }
    else {
        $configXml = $configXmlNoKms -replace '\{company\}',$Company;
    }
    
    File 'OfficeConfigXml' {
        DestinationPath = $tempConfigPath;
        Contents = $configXml;
        Ensure = 'Present';
        Type = 'File';
    }
            
    Package "Office$Version" {
        Name = $productName;
        Path = $Path;
        ProductId = $productCode;
        Arguments = '/config "{0}"' -f $tempConfigPath;
    }

} #end configuration vOfficeProPlus
