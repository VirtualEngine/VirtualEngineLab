The VirtualEngineLab composite DSC resources provide a common set of DSC resources that simplify the
implementation of internal lab configurations.

### Included Resources
* vAccessDBEngine2010
 * Installs the Microsoft Access Database Engine 2010 components
 * Requires: xPSDesiredStateConfiguration
* vADDomain
 * Deploys a new Active Directory forest and domain
 * Requires: xActiveDirectory
* vADDomainController
 * Deploys an additional Active Directory domain controller to a domain
 * Requires: xActiveDirectory
* vAdobeReader
 * Installs Adobe Reader XI/DC and disables updates and cloud service integration
 * Requires: xPSDesiredStateConfiguration
* vADUserThumbnailPhoto
 * Configures Active Directory user thumbnail photos
 * Requires: Active Directory module to be installed on the enacting node
* vAppV5
 * Installs App-V 5.0/5.1 client/RDS client
* vCitrixReceiver
 * Installs Citrix Receiver
 * Requires: xPSDesiredStateConfiguration
* vDomainMember
 * Configures the TCP/IP stack, computer name and joins a computer to an Active Directory domain
 * Requires: xActiveDirectory, xNetworking, xComputerManagement and LegacyNetworking
* vExchange2013
 * Installs prerequisites and prepares AD
 * Installs Exchange 2013
 * Requires: xPSDesiredStateConfiguration and xPendingReboot
* vExchange2013ADPrep
 * Extends Active Directory schema for Exchange 2013 deployment
 * Requires: xPSDesiredStateConfiguration
* vExchange2013Https
 * Installs prerequisites and prepares AD
 * Installs Exchange 2013
 * Installs PFX certificate and binds services to HTTPS
 * Requires: xExchange, xPSDesiredStateConfiguration and xPendingReboot
* vExchange2013Prerequisites
 * Installs required Windows features and installs Unified Communications Managed API 4.0
 * Requires: xPSDesiredStateConfiguration
* vFile
 * Downloads a file from a UNC path or from the internet
 * Requires: xPSDesiredStateConfiguration
* vFirefox
 * Installs Mozilla Firefox and disables updates
 * Requires: xPSDesiredStateConfiguration
* vICMP
 * Permits inbound ICMP traffic through the Windows firewall
 * Requires: xNetworking
* vInternetExplorerSecurity
 * Enables or disables Internet Explorer Enhanced Security Configuration
 * Requires: xSystemSecurity
* vNotepadPlusPlus
 * Installs Notepad++
 * Requires: xPSDesiredStateConfiguration
* vOfficeProPlus
 * Installs and configures Office 2010, 2013 or 2016 Professional Plus and configures KMS server
* vPerformanceSetting
 * Configures and manages:
   * Active power plan
   * Server Manager auto start
   * System Restore settings
   * Windows Explorer Visual effects
   * Windows Explorer help tips
   * Windows Explorer logon animations
 * Requires: xWindowsRestore, StackExchangeResources
* vPowerPointViewer
 * Installs Microsoft PowerPoint Viewer
 * Requires: xPSDesiredStateConfiguration
* vRemoteAssistance
 * Installs the Remote Assistance feature and permits inbound RDP shadow requests
 * Requires: -EnableFirewallException requires xNetworking resource
* vRemoteDesktopAdmin
 * Enables RDP connections and permits inbound RDP connections
 * Requires: xRemoteDesktopAdmin, -EnableFirewallException requires xNetworking resource
* vRemoteDesktopLicensing
 * Installs the RDS licening role and optionally, the UI components
* vRemoteDesktopSessionHost
 * Installs RDS roles and optionally, Remote Assistance and Desktop Experience
 * Adds users/groups to the local Remote Desktop Users group
 * Configures the RDS license server
* vScheduledTask
 * Enables/disables _existing_ scheduled tasks.
 * __Requires Server 2012/Windows 8 or later.__
* vSQLExpress
 * Enables NetFX 3.5 and installs SQL Express 2012/2014
 * Requires: xNetworking
* vWebServer
 * Installs standard IIS web server roles/features
* vWebServerHttps
 * Installs standard IIS web server roles/features and imports PFX certificate
 * Requires: xCertificate and xWebAdministration
* vWebServerRedirect
 * Creates a Javascript HTML redirection file
* vWorkgroupMember
 * Configures the TCP/IP stack and computer name
 * Requires: xComputerManagement, xNetworking and LegacyNetworking

### Requirements
There are __dependencies__ on the following DSC resources:

* LegacyNetworking - https://github.com/VirtualEngine/LegacyNetworking
* StackExchangeResources - https://github.com/PowerShellOrg/StackExchangeResources
* xActiveDirectory - https://github.com/Powershell/xActiveDirectory
* xCertificate - https://github.com/Powershell/xCertificate
* xComputerManagement - https://github.com/Powershell/xComputerManagement
* xExchange - https://github.com/Powershell/xExchange
* xNetworking - https://github.com/Powershell/xNetworking
* xPendingReboot - https://github.com/Powershell/xPendingReboot
* xPSDesiredStateConfiguration - https://github.com/Powershell/xPSDesiredStateConfiguration
* xRemoteDesktopAdmin - https://github.com/Powershell/xRemoteDesktopAdmin
* xSystemSecurity - https://github.com/Powershell/xSystemSecurity
* xWebAdministration - https://github.com/Powershell/xWebAdministration
* xWindowsRestore - https://github.com/Powershell/xWindowsRestore
