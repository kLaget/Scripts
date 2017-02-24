#Deploy Server 2016 Datacentre Edition

#Add Telnet
pkgmgr /iu:"TelnetClient"

#Install Hyper-V Feature and reboot
Install-WindowsFeature –Name Hyper-V -IncludeManagementTools -Restart  

#Enable PowerShell Remoting
Enable-PSRemoting -Force

#Created VSwitches Manually.. use external for vm`s

#Create Template VM
http://www.oxfordsbsguy.com/2014/06/02/how-to-create-a-hyper-v-vm-template-without-vmm/
#exported to C:\Klaget\Templates\TemplateG2Server2016\Virtual Hard Disks\TemplateG2Server2016.vhdx

#Deploy DC01 - Run CreateVM-script
#start-DC01, set local admin password
Enter-PSSession -vmname DC01
#. Get-NetIPAddress | Sort-Object -Property InterfaceIndex | Format-Table
#. SET IPADDRESS Set-NetIPAddress –InterfaceIndex 3 –IPAddress 192.168.0.1
#set computername DC01

#Deploy LAB-AD and DNS, below worked but threw errors
Import-Module ADDSDeployment    
Install-ADDSForest
-CreateDnsDelegation:$false
-DatabasePath “C:\Windows\NTDS”
-DomainMode “Win2016”
-DomainName "lab.klaget.no"
-DomainNetbiosName “LAB”
-ForestMode “Win2016”
-InstallDns:$true
-LogPath “C:\Windows\NTDS”
-NoRebootOnCompletion:$false
-SysvolPath “C:\Windows\SYSVOL”
-Force:$true
#-SafeModeAdministratorPassword (ConvertTo-SecureString '**********' -AsPlainText -Force)

