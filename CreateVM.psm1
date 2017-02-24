######################################################
###              Template Definition               ###
######################################################
# Connect to hyp1, remove # to run script remotely
#Enter-PSSession hyp1

 
# VM Name
$VMName          = "mim01.lab.klaget.no"
 
# Automatic Start Action (Nothing = 0, Start =1, StartifRunning = 2)
$AutoStartAction = 2
# In second
$AutoStartDelay  = 10
# Automatic Start Action (TurnOff = 0, Save =1, Shutdown = 2)
$AutoStopAction  = 2
 
 
###### Hardware Configuration ######
# VM Path
$VMPath         = "E:\VMS"
 
# VM Generation (1 or 2)
$Gen            = 2
 
# Processor Number
$ProcessorCount = 2
 
## Memory (Static = 0 or Dynamic = 1)
$Memory         = 1
# StaticMemory
$StaticMemory   = 8GB
 
# DynamicMemory
$StartupMemory  = 2GB
$MinMemory      = 1GB
$MaxMemory      = 4GB
 
# Sysprep VHD path (The VHD will be copied to the VM folder)
$SysVHDPath     = "E:\Templates\TemplateG2Server2016\Virtual Hard Disks\TemplateG2Server2016.vhdx"
# Rename the VHD copied in VM folder to:
$OsDiskName     = $VMName
 
### Network Adapters
# Primary Network interface: VMSwitch 
$VMSwitchName = "External1"
$VlanId       = 0
$VMQ          = $False
$IPSecOffload = $False
$SRIOV        = $False
$MacSpoofing  = $False
$DHCPGuard    = $False
$RouterGuard  = $False
$NicTeaming   = $False
 
  
######################################################
###           VM Creation and Configuration        ###
######################################################
 
## Creation of the VM
# Creation without VHD and with a default memory value (will be changed after)
New-VM -Name $VMName `
       -Path $VMPath `
       -NoVHD `
       -Generation $Gen `
       -MemoryStartupBytes 1GB `
       -SwitchName $VMSwitchName

 
if ($AutoStartAction -eq 0){$StartAction = "Nothing"}
Elseif ($AutoStartAction -eq 1){$StartAction = "Start"}
Else{$StartAction = "StartIfRunning"}
 
if ($AutoStopAction -eq 0){$StopAction = "TurnOff"}
Elseif ($AutoStopAction -eq 1){$StopAction = "Save"}
Else{$StopAction = "Shutdown"}
 
## Changing the number of processor and the memory
# If Static Memory
if (!$Memory){
    
    Set-VM -Name $VMName `
           -ProcessorCount $ProcessorCount `
           -StaticMemory `
           -MemoryStartupBytes $StaticMemory `
           -AutomaticStartAction $StartAction `
           -AutomaticStartDelay $AutoStartDelay `
           -AutomaticStopAction $StopAction
 
 
}
# If Dynamic Memory
Else{
    Set-VM -Name $VMName `
           -ProcessorCount $ProcessorCount `
           -DynamicMemory `
           -MemoryMinimumBytes $MinMemory `
           -MemoryStartupBytes $StartupMemory `
           -MemoryMaximumBytes $MaxMemory `
           -AutomaticStartAction $StartAction `
           -AutomaticStartDelay $AutoStartDelay `
           -AutomaticStopAction $StopAction
 
}
 
## Set the primary network adapters
$PrimaryNetAdapter = Get-VM $VMName | Get-VMNetworkAdapter
if ($VlanId -gt 0){$PrimaryNetAdapter | Set-VMNetworkAdapterVLAN -Access -VlanId $VlanId}
else{$PrimaryNetAdapter | Set-VMNetworkAdapterVLAN -untagged}
 
if ($VMQ){$PrimaryNetAdapter | Set-VMNetworkAdapter -VmqWeight 100}
Else {$PrimaryNetAdapter | Set-VMNetworkAdapter -VmqWeight 0}
 
if ($IPSecOffload){$PrimaryNetAdapter | Set-VMNetworkAdapter -IPsecOffloadMaximumSecurityAssociation 512}
Else {$PrimaryNetAdapter | Set-VMNetworkAdapter -IPsecOffloadMaximumSecurityAssociation 0}
 
if ($SRIOV){$PrimaryNetAdapter | Set-VMNetworkAdapter -IovQueuePairsRequested 1 -IovInterruptModeration Default -IovWeight 100}
Else{$PrimaryNetAdapter | Set-VMNetworkAdapter -IovWeight 0}
 
if ($MacSpoofing){$PrimaryNetAdapter | Set-VMNetworkAdapter -MacAddressSpoofing on}
Else {$PrimaryNetAdapter | Set-VMNetworkAdapter -MacAddressSpoofing off}
 
if ($DHCPGuard){$PrimaryNetAdapter | Set-VMNetworkAdapter -DHCPGuard on}
Else {$PrimaryNetAdapter | Set-VMNetworkAdapter -DHCPGuard off}
 
if ($RouterGuard){$PrimaryNetAdapter | Set-VMNetworkAdapter -RouterGuard on}
Else {$PrimaryNetAdapter | Set-VMNetworkAdapter -RouterGuard off}
 
if ($NicTeaming){$PrimaryNetAdapter | Set-VMNetworkAdapter -AllowTeaming on}
Else {$PrimaryNetAdapter | Set-VMNetworkAdapter -AllowTeaming off}

 
## VHD(X) OS disk copy
$OsDiskInfo = Get-Item $SysVHDPath
Copy-Item -Path $SysVHDPath -Destination $($VMPath + "\" + $VMName)
Rename-Item -Path $($VMPath + "\" + $VMName + "\" + $OsDiskInfo.Name) -NewName $($OsDiskName + $OsDiskInfo.Extension)
 
# Attach the VHD(x) to the VM
Add-VMHardDiskDrive -VMName $VMName -Path $($VMPath + "\" + $VMName + "\" + $OsDiskName + $OsDiskInfo.Extension)
 
$OsVirtualDrive = Get-VMHardDiskDrive -VMName $VMName -ControllerNumber 0
     
# Change the boot order to the VHDX first
Set-VMFirmware -VMName $VMName -FirstBootDevice $OsVirtualDrive
 
Start-VM $VMName
