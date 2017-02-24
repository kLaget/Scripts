Enter-PSSession -vmname DC01


Import-Module ServerManager
Add-WindowsFeature -Name Web-Server -IncludeManagementTools
Add-WindowsFeature Adcs-Cert-Authority -IncludeManagementTools
Add-WindowsFeature ADCS-Web-Enrollment
md \temp
md C:\inetpub\crl
icacls C:\inetpub\crl /grant everyone:r

Install-AdcsCertificationAuthority -HashAlgorithmName SHA256 -CACommonName "LAB KLAGET CA" -CAType EnterpriseSubordinateCA -KeyLength 2048 -OutputCertRequestFile \temp\ca.req

Get-CACrlDistributionPoint | Remove-CACrlDistributionPoint -force
Get-CAAuthorityInformationAccess | Remove-CAAuthorityInformationAccess -force

Add-CACrlDistributionPoint -Uri "C:\inetpub\crl\ca.crl" -publishtoserver -force
Add-CACrlDistributionPoint -Uri "http://crl.lab.klaget.no\ca.crl" -AddToCertificateCdp -force
Add-CAAuthorityInformationAccess -Uri "http://crl.lab.klaget.no/ca.crt" -AddToCertificateAia -force

New-WebSite -name CRL -HostHeader crl.lab.klaget.no -PhysicalPath "C:\inetpub\crl"

###
### NB! Siste punkt på lista, etter at CA er startet
### CA må startes manuelt, etter at CA sertifikat er signert av root og lastet opp
### Server må så publiseres i Netscaler, se egen dok et annet sted
###
copy \Windows\System32\certsrv\CertEnroll\*crt C:\inetpub\crl\ca.crt
