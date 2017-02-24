#Create VM Dock1, set adminpassword
Enter-PSSession -vmname dock1
Rename-Computer -NewName dock1 -ComputerName .
#sconfig
#6 run and install updates
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Install-Module -Name DockerMsftProvider -Force
Install-Package -Name docker -ProviderName DockerMsftProvider -Force
Restart-Computer -Force

start docker
docker version
docker pull microsoft/WindowsServerCore
