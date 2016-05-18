The VirtualEngineLab composite DSC resources provide a common set of DSC resources that simplify the
implementation of internal lab configurations.

###Included Resources
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
* vNotepadPlusPlus
 * Installs Notepad++
 * Requires: xPSDesiredStateConfiguration
* vOfficeProPlus
 * Installs and configures Office 2010, 2013 or 2016 Professional Plus and configures KMS server
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
* vServerManager
 * Disables Server Manager upon login
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
* vWindowsHelpTips
 * Enables/disables the Windows 8 help tips
* vWindowsSignInAnimation
 * Enables/disables the Windows 8/10 sign-in animation
* vWorkgroupMember
 * Configures the TCP/IP stack and computer name
 * Requires: xComputerManagement, xNetworking and LegacyNetworking

###Requirements
There are __dependencies__ on the following DSC resources:

* xActiveDirectory - https://github.com/Powershell/xActiveDirectory
* xComputerManagement - https://github.com/Powershell/xComputerManagement
* xExchange - https://github.com/Powershell/xExchange
* xNetworking - https://github.com/Powershell/xNetworking
* xPSDesiredStateConfiguration - https://github.com/Powershell/xPSDesiredStateConfiguration
* xRemoteDesktopAdmin - https://github.com/Powershell/xRemoteDesktopAdmin
* xWebAdministration - https://github.com/Powershell/xWebAdministration
* xPendingReboot - https://github.com/Powershell/xPendingReboot
* xCertificate - https://github.com/Powershell/xCertificate
* LegacyNetworking - https://github.com/VirtualEngine/LegacyNetworking
