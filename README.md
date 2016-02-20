The VirtualEngineLab composite DSC resources provide a common set of DSC resources that simplify the
implementation of internal lab configurations.

###Included Resources
* vADDomain
 * Deploys a new Active Directory forest and domain
* vADDomainController
 * Deploys an additional Active Directory domain controller to a domain
* vAdobeReader
 * Installs Adobe Reader XI/DC and disables updates and cloud service integration
* vADUserThumbnailPhoto
 * Configures Active Directory user thumbnail photos
* vAppV5
 * Installs App-V 5.0/5.1 client/RDS client
* vCitrixReceiver
 * Installs Citrix Receiver
* vDomainMember
 * Configures the TCP/IP stack, computer name and joins a computer to an Active Directory domain
* vExchange2013
 * Installs prerequisites and prepares AD
 * Installs Exchange 2013
* vExchange2013ADPrep
 * Extends Active Directory schema for Exchange 2013 deployment
* vExchange2013Https
 * Installs prerequisites and prepares AD
 * Installs Exchange 2013
 * Installs PFX certificate and binds services to HTTPS
* vExchange2013Prerequisites
 * Installs required Windows features and installs Unified Communications Managed API 4.0
* vFile
 * Downloads a file from a UNC path or from the internet
* vFirefox
 * Installs Mozilla Firefox and disables updates 
* vICMP
 * Permits inbound ICMP traffic through the Windows firewall
* vNotepadPlusPlus
 * Installs Notepad++
* vOfficeProPlus
 * Installs and configures Office 2010, 2013 or 2016 Professional Plus and configures KMS server
* vRemoteAssistance
 * Installs the Remote Assistance feature and permits inbound RDP shadow requests
* vRemoteDesktopAdmin
 * Enables RDP connections and permits inbound RDP connections
* vRemoteDesktopLicensing
 * Installs the RDS licening role and optionally, the UI components
* vRemoteDesktopSessionHost
 * Installs RDS roles and optionally, Remote Assistance and Desktop Experience
 * Adds users/groups to the local Remote Desktop Users group
 * Configures the RDS license server
* vServerManager
 * Disables Server Manager upon login
* vSQLExpress
 * Enables NetFX 3.5 and installs SQL Express 2012/2014
* vWebServer
 * Installs standard IIS web server roles/features
* vWebServerHttps
 * Installs standard IIS web server roles/features and imports PFX certificate
* vWorkgroupMember
 * Configures the TCP/IP stack and computer name

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
