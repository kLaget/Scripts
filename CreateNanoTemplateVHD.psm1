#https://technet.microsoft.com/windows-server-docs/get-started/nano-server-quick-start
Import-Module .\NanoServerImageGenerator -Verbose
New-NanoServerImage -Edition Standard -DeploymentType Guest -MediaPath d:\ -BasePath .\Base -TargetPath .\Nano\NanoHyp1.vhd -ComputerName NanoHyp1 -compute -Clustering
