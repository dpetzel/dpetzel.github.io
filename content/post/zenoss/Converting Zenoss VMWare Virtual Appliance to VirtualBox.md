---
categories: [Zenoss]
date: 2012-02-10
draft: false
tags: [zenoss]
title: Converting Zenoss VMWare Virtual Appliance to VirtualBox
type: post
---

So you can use the VMWare Appliance Zenoss Inc. provides under VirtualBox
<!--more-->

## Instructions
### Linux

Download the existing VMware Image:
```bash
cd /tmp
wget http://downloads.sourceforge.net/project/zenoss/zenoss-alpha/4.1.70-1427/zenoss-4.1.70-1427-x86_64.vmware.zip
```

Unzip the downloaded zip file:
```bash
unzip zenoss-4.1.70-1427-x86_64.vmware.zip
```

Create a new VirtualBox VM:
```bash
VM_NAME="Zenoss_4.1_Appliance"
VM_BASE_PATH=/VMs
sudo mkdir $VM_BASE_PATH
sudo chmod 777 $VM_BASE_PATH
VBoxManage createvm --name $VM_NAME --basefolder $VM_BASE_PATH --register
```

Move the VMDK file over to the VM's directory:
```bash
mv zenoss-4.1.70-1427-x86_64.vmdk $VM_BASE_PATH/$VM_NAME/
```

Change Settings on the newly created VM:
```bash
VBoxManage modifyvm $VM_NAME --ostype RedHat_64 --memory 2048 --nic1 nat --nictype1 82545EM --ioapic on
```

Attach the VMDK file to the VM:
```bash
VBoxManage storagectl $VM_NAME --name "SCSI Controller" --add scsi --controller LsiLogic
VBoxManage storageattach $VM_NAME --storagectl "SCSI Controller" --type hdd --port 0 --medium $VM_BASE_PATH/$VM_NAME/zenoss-4.1.70-1427-x86_64.vmdk
```

Add a DVD/CD Drive (At a minimum you'll need this for installing Guest Additions):
```bash
VBoxManage storagectl $VM_NAME --name "IDE Controller" --add ide --controller PIIX4
VBoxManage storageattach $VM_NAME --storagectl "IDE Controller" --type dvddrive --port 1 --device 0 --medium emptydrive
```

Power on the new Virtual Machine:
```bash
VBoxManage startvm $VM_NAME
```

Once the VM has started up, log into the console and Remove VMWare Tools:
```bash
vmware-uninstall-tools.pl
```

Use the VirtualBox documentation to install VirtualBox Guest Additions

### Windows

Lets get our powershell on...All commands are run in a power shell prompt

 Setup some Variables:
```powershell
$buildNumber = "4.1.70-1434"
$arch = "x86_64"  
$baseFileName = "zenoss-$buildNumber-$arch"
$zipFileName = "$baseFileName.vmware.zip"
$zipFileDownloadUrl = "http://downloads.sourceforge.net/project/zenoss/zenoss-alpha/$buildNumber/$zipFileName"

$VM_NAME="Zenoss_Appliance_$buildNumber"
$VM_BASE_PATH="VMs"
```

Download the existing VMware Image:

```powershell
cd temp
$webclient = New-Object System.Net.WebClient
echo "Going to Download File. This will take a long time without output. Be Patient"
$webclient.DownloadFile($zipFileDownloadUrl,"$pwd$zipFileName")
```

Unzip the downloaded zip file:

```powershell
$shell_app=new-object -com shell.application
$zip_file = $shell_app.namespace((Get-Location).Path + "$zipFileName")
$destination = $shell_app.namespace((Get-Location).Path)
$destination.Copyhere($zip_file.items())
```

Create a new VirtualBox VM:

```powershell
if ((Test-Path -path $VM_BASE_PATH) -ne $True){New-Item $VM_BASE_PATH -type directory}
VBoxManage createvm --name $VM_NAME --basefolder $VM_BASE_PATH --register
```

Move the VMDK file over to the VM's directory:

```powershell
mv $baseFileName$baseFileName.vmdk $VM_BASE_PATH$VM_NAME
```

Change Settings on the newly created VM:

```powershell
VBoxManage modifyvm $VM_NAME --ostype RedHat_64 --memory 2048 --nic1 nat --nictype1 82545EM --ioapic on
```

Attach the VMDK file to the VM:

```powershell
VBoxManage storagectl $VM_NAME --name "SCSI Controller" --add scsi --controller LsiLogic
VBoxManage storageattach $VM_NAME --storagectl "SCSI Controller" --type hdd --port 0 --medium $VM_BASE_PATH$VM_NAME$baseFileName.vmdk
```

Add a DVD/CD Drive (At a minimum you'll need this for installing Guest Additions):

```powershell
VBoxManage storagectl $VM_NAME --name "IDE Controller" --add ide --controller PIIX4
VBoxManage storageattach $VM_NAME --storagectl "IDE Controller" --type dvddrive --port 1 --device 0 --medium (get-command VBoxGuestAdditions.iso).Path
```

Some Optional Port forwards I find useful:

```powershell
VBoxManage controlvm $VM_NAME natpf1 "SSH,tcp,,8022,,22"
VBoxManage controlvm $VM_NAME natpf1 "ZOPE,tcp,,8080,,8080"
```

Power on the new Virtual Machine:

```powershell
VBoxManage startvm $VM_NAME
```

Once the VM has started up, log into the console (root/zenoss) and Remove VMWare Tools:

```bash
vmware-uninstall-tools.pl
```

While still logged into the console, install VirtualBox guest additions:
```shell
yum -y install bzip2 make gcc
mkdir /media/ga
mount /dev/cdrom /media/ga
/media/ga/VBoxLinuxAdditions.run
```

Reboot for good measure
```shell
reboot
```
