The VirtualEngineLab composite DSC resources provide a common set of DSC resources that simplify the
implementation of DSC configurations.

###Included Resources
* vADDomain
 * Deploys a new Active Directory forest and domain
* vADDomainController
 * Deploys an additional Active Directory domain controller to a domain
* vDomainMember
 * Configures the TCP/IP stack, computer name and joins a computer to an Active Directory domain
* vExchange2013
 * Installs prerequisites, prepares AD
 * Installs Exchange 2013
 * Extends Active Directory schema for Exchange 2013 deployment
* vExchange2013Prerequisites
 * Installs required Windows features and installs Unified Communications Managed API 4.0
* vFile
 * Downloads a file from a UNC path or from the internet
* vICMP
 * Permits inbound ICMP traffic through the Windows firewall
* vRemoteAssistance
 * Installs the Remote Assistance feature and permits inbound RDP shadow requests
* vRemoteDesktopAdmin
 * Enables RDP connections and permits inbound RDP connections
* vSQLExpress
 * Installs NetFX 3.5 and SQL Express 2012/2014
* vWebServer
 * Installs standard IIS web server roles/features
* vWorkgroupMember
 * Configures the TCP/IP stack and computer name

###Requirements
There are __dependencies__ on the following DSC resources:

* xActiveDirectory - https://github.com/Powershell/xActiveDirectory
* xComputerManagement - https://github.com/Powershell/xComputerManagement
* xNetworking - https://github.com/Powershell/xNetworking
* xPSDesiredStateConfiguration - https://github.com/Powershell/xPSDesiredStateConfiguration
* xRemoteDesktopAdmin - https://github.com/Powershell/xRemoteDesktopAdmin
* xWebAdministration - https://github.com/Powershell/xWebAdministration
* xPendingReboot - https://github.com/Powershell/xPendingReboot
