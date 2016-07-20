configuration vXmlNodeAttribute {
<#
    .SYNOPSIS
        Configures a Xml element attribute
#>
    param (
        ## Path the Xml file
        [Parameter(Mandatory)]
        [System.String] $Path,

        ## XPath to the (single) Xml node containing the attribute
        [Parameter(Mandatory)]
        [System.String] $XPath,

        ## Xml attribute name to set
        [Parameter(Mandatory)]
        [System.String] $AttributeName,

        ## Xml attribute value to set
        [Parameter(Mandatory)]
        [System.String] $AttributeValue
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration;

    $resourceName = '{0}_{1}' -f $AttributeName, $AttributeValue;

    Script $resourceName.Replace(' ','') {

        GetScript = {

            $xml = New-Object -TypeName 'System.Xml.XmlDocument';
            $xml.Load($using:Path);
            $node = $xml.SelectSingleNode($using:XPath);
            return @{
                Result = $node.$using:AttributeName;
            }

        }
        TestScript = {

            $xml = New-Object -TypeName 'System.Xml.XmlDocument';
            $xml.Load($using:Path);
            $node = $xml.SelectSingleNode($using:XPath);
            if ($node.$using:AttributeName -ne $using:AttributeValue) {
                return $false;
            }
            else {
                return $true;
            }

        }
        SetScript = {

            $xml = New-Object -TypeName 'System.Xml.XmlDocument';
            $xml.Load($using:Path);
            $node = $xml.SelectSingleNode($using:XPath);
            $node.$using:AttributeName = $using:AttributeValue;
            $xml.Save($using:Path);

        }
    } #end script

} #end configuration vXmlNodeAttribute
