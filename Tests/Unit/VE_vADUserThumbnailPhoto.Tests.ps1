$Global:DSCModuleName      = 'VirtualEngineLab'
$Global:DSCResourceName    = 'VE_vADUserThumbnailPhoto'

#region HEADER
[String] $moduleRoot = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $Script:MyInvocation.MyCommand.Path))
if ( (-not (Test-Path -Path (Join-Path -Path $moduleRoot -ChildPath 'DSCResource.Tests'))) -or `
     (-not (Test-Path -Path (Join-Path -Path $moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1'))) )
{
    & git @('clone','https://github.com/PowerShell/DscResource.Tests.git',(Join-Path -Path $moduleRoot -ChildPath '\DSCResource.Tests\'))
}
else
{
    & git @('-C',(Join-Path -Path $moduleRoot -ChildPath '\DSCResource.Tests\'),'pull')
}
Import-Module (Join-Path -Path $moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1') -Force
$TestEnvironment = Initialize-TestEnvironment `
    -DSCModuleName $Global:DSCModuleName `
    -DSCResourceName $Global:DSCResourceName `
    -TestType Unit 
#endregion

# TODO: Other Optional Init Code Goes Here...

# Begin Testing
try
{

    #region Pester Tests

    # The InModuleScope command allows you to perform white-box unit testing on the internal
    # (non-exported) code of a Script Module.
    InModuleScope $Global:DSCResourceName {

        $testPresentParams = @{
            DomainName = 'contoso.com';
            UserName = 'TestUser';
            Ensure = 'Present';
            ThumbnailPhoto = 'AQIDBA==';
        }
        $testAbsentParams = $testPresentParams.Clone();
        $testAbsentParams['Ensure'] = 'Absent';
        
        $fakePresentResource = @{
            DomainName = $testPresentParams.DomainName;
            UserName = $testPresentParams.UserName;
            Ensure = 'Present';
            ThumbnailPhoto = $testPresentParams.ThumbnailPhoto;
            ThumbnailPhotoHash = '08D6C05A21512A79A1DFEB9D2A8F262F';
        }
        $fakeAbsentResource = $fakePresentResource.Clone();
        $fakeAbsentResource['Ensure'] = 'Absent';
        $fakeAbsentResource['ThumbnailPhotoHash'] = $null;
        
        $fakeADUser = @{
            SamAccountName = $testPresentParams.UserName;
            ThumbnailPhoto = [Byte[]] @(1,2,3,4);
        }
        
        $fakeADUserNoThumbnail = @{
            SamAccountName = $testPresentParams.UserName;
        }
        
        $testDomainController = 'TESTDC';
        $testCredential = New-Object System.Management.Automation.PSCredential 'DummyUser', (ConvertTo-SecureString 'DummyPassword' -AsPlainText -Force);


        #region Function Get-TargetResource
        Describe "$($Global:DSCResourceName)\Get-TargetResource" {
            
            Mock Assert-Module -MockWith { }
            
            It "Returns a 'System.Collections.Hashtable' object type" {
                Mock Get-ADUser { return [PSCustomObject] $fakeADUser; }
        
                $targetResource = Get-TargetResource @testPresentParams;
        
                $targetResource -is [System.Collections.Hashtable] | Should Be $true;
            }
        
            It "Returns 'Ensure' is 'Present' when thumbnail exists" {
                Mock Get-ADUser { return [PSCustomObject] $fakeADUser; }
        
                $targetResource = Get-TargetResource @testPresentParams;
        
                $targetResource.Ensure | Should Be 'Present';
            }
            
            It "Returns 'Ensure' is 'Absent' when thumbnail does not exist" {
                Mock Get-ADUser {  return [PSCustomObject] $fakeADUserNoThumbnail; }
                
                $targetResource = Get-TargetResource @testPresentParams;
                
                $targetResource.Ensure | Should Be 'Absent';
            }
            
            It "Calls 'Get-ADUser' with 'Server' parameter when 'DomainController' specified" {
                Mock Get-ADUser -ParameterFilter { $Server -eq $testDomainController } -MockWith { return [PSCustomObject] $fakeADUser; }
                
                Get-TargetResource @testPresentParams -DomainController $testDomainController;
                
                Assert-MockCalled Get-ADUser -ParameterFilter { $Server -eq $testDomainController } -Scope It;
            }
            
            It "Calls 'Get-ADUser' with 'Credential' parameter when 'DomainAdministratorCredential' specified" {
                Mock Get-ADUser -ParameterFilter { $Credential -eq $testCredential } -MockWith { return [PSCustomObject] $fakeADUser; }
        
                Get-TargetResource @testPresentParams -DomainAdministratorCredential $testCredential;
                
                Assert-MockCalled Get-ADUser -ParameterFilter { $Credential -eq $testCredential } -Scope It;
            }
        }
        #endregion

        #region Function Test-TargetResource
        Describe "$($Global:DSCResourceName)\Test-TargetResource" {
            
            
            
            It "Passes when thumbnail does not exist and 'Ensure' is 'Absent'" {
                Mock Get-TargetResource { return $fakeAbsentResource }
                
                Test-TargetResource @testAbsentParams | Should Be $true;
            }
        
            It "Fails when thumbnail exists and 'Ensure' is 'Absent'" {
                Mock Get-TargetResource { return $fakePresentResource }
                
                Test-TargetResource @testAbsentParams | Should Be $false;
            }
            
            It "Passes when thumbnail matches and 'Ensure' is 'Present'" {
                Mock Get-TargetResource { return $fakePresentResource }
                
                Test-TargetResource @testPresentParams | Should Be $true;
            }
        
            It "Fails when thumbnail does not exist and 'Ensure' is 'Present'" {
                Mock Get-TargetResource { return $fakeAbsentResource }
                
                Test-TargetResource @testPresentParams | Should Be $false;
            }
            
            It "Fails when thumbnail does exist and 'Ensure' is 'Present', but has incorrect hash" {
                Mock Get-TargetResource { return $fakePresentResource }
                $testIncorrectParams = $testPresentParams.Clone();
                $testIncorrectParams['ThumbnailPhoto'] = 'BAMCAQ==';
                
                Test-TargetResource @testIncorrectParams | Should Be $false;
            }
            
        }
        #endregion

        #region Function Set-TargetResource
        Describe "$($Global:DSCResourceName)\Set-TargetResource" {
            
            Mock Assert-Module -MockWith { }
            
            It "Calls 'Set-ADUser' with 'Replace' when 'Ensure' = 'Present'" {
                Mock Get-TargetResource { return $fakePresentResource }
                Mock Set-ADUser -ParameterFilter { $Replace -ne $null } -MockWith { }
                
                Set-TargetResource @testPresentParams;
                
                Assert-MockCalled -ParameterFilter { $Replace -ne $null } Set-ADUser -Scope It;
            }
            
            It "Calls 'Set-ADUser' with 'Clear' when 'Ensure' = 'Present'" {
                Mock Get-TargetResource { return $fakePresentResource }
                Mock Set-ADUser -ParameterFilter { $Clear -ne $null } -MockWith { }
                
                Set-TargetResource @testAbsentParams;
                
                Assert-MockCalled -ParameterFilter { $Clear -ne $null } Set-ADUser -Scope It;
            }
            
        }
        #endregion
        
        Describe "$($Global:DSCResourceName)\Get-ThumbnailBytes" {
            
            It 'Converts from Base64 when "ThumbnailPhoto" does not contain a "."' {
                $testThumbnailPhotoBytes = [Byte[]] @(1,2,3,4);
                $thumbnailBytes = Get-ThumbnailBytes -ThumbnailPhoto 'AQIDBA==';
                
                Compare-Object -ReferenceObject $testThumbnailPhotoBytes -DifferenceObject $thumbnailBytes  | Should BeNullOrEmpty;
            }
            
            It 'Reads from disk when "ThumbnailPhoto" contains a "."' {
                $testThumbnailPhotoPath = 'TestDrive:\TestThumbnail.pic';
                $testThumbnailPhotoBytes = [Byte[]] @(1,2,3,4);
                $testThumbnailPhotoBytes | Set-Content -Path $testThumbnailPhotoPath -Encoding Byte -Force;
                
                $thumbnailBytes = Get-ThumbnailBytes -ThumbnailPhoto $testThumbnailPhotoPath;
                
                Compare-Object -ReferenceObject $testThumbnailPhotoBytes -DifferenceObject $thumbnailBytes  | Should BeNullOrEmpty;
            }
            
        } #end describe Get-ThumbnailBytes
        
        Describe "$($Global:DSCResourceName)\Get-MD5HashString" {
            
            It 'Returns "$null" when passed "$null"' {
                $result = Get-MD5HashString -Bytes $null;
                
                $result | Should BeNullOrEmpty;
            }
            
            It 'Returns MD5 hash when passed a "byte[]"' {
                $testThumbnailPhotoBytes = [Byte[]] @(1,2,3,4);
                $expected = '08D6C05A21512A79A1DFEB9D2A8F262F';
                
                $result = Get-MD5HashString -Bytes $testThumbnailPhotoBytes;
                
                $result | Should BeExactly $expected;
            }
            
        } #end describe Get-MD5HashString

    }
    #endregion
}
finally
{
    #region FOOTER
    Restore-TestEnvironment -TestEnvironment $TestEnvironment
    #endregion

    # TODO: Other Optional Cleanup Code Goes Here...
}