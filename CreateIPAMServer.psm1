Install-WindowsFeature IPAM -IncludeManagementTools

Invoke-IpamGpoProvisioning -Domain lab.klaget.no -GpoPrefixName IPAM01 -IpamServerFqdn ipam01.lab.klaget.no