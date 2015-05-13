function New-ESXi_ks_conf{
param(
[Parameter(Mandatory=$true,HelpMessage="The kickstart file will be generated for a host with this mac address")]
$Host_macaddress,
[Parameter(Mandatory=$true)]
$DestinationFolder,
[boolean]$Miscellaneous_vmaccepteula = $True,
[ValidateSet('Belgian','Brazilian','Croatian','Czechoslovakian','Danish','Default','Estonian','Finnish','French','German','Greek','Icelandic','Italian','Japanese','Latin American','Norwegian','Polish','Portuguese','Russian','Slovenian','Spanish','Swedish','Swiss French','Swiss German','Turkish','US Dvorak','Ukrainian','United Kingdom')]
$Miscellaneous_keyboard = 'Default',
[boolean]$Miscellaneous_dryrun = $False,
[boolean]$Miscellaneous_reboot = $True ,
[boolean]$Miscellaneous_reboot_noeject = $False,
[Parameter(Mandatory=$true)]
$Miscellaneous_rootpw,
[boolean]$Miscellaneous_rootpw_iscrypted = $False,
[boolean]$Miscellaneous_paranoid = $False,
[boolean]$Miscellaneous_licensekey,
[Parameter(Mandatory=$true,HelpMessage="Select between install, upgrade, or installorupgrade")]
[ValidateSet('install','upgrade','installorupgrade')]
$installorUpgrade_Mode,
[ValidateSet('disk','firstdisk')]
$Install_diskSelection_Mode,
$Install_disk_targetdisk,
$Install_firstdisk_disktypeparameters,
[boolean]$Install_ignoressd,
[boolean]$Install_overwritevsan,
[boolean]$Install_overwritevmfs,
[boolean]$Install_preservevmfs,
[boolean]$Install_novmfsondisk,
[ValidateSet('disk','firstdisk')]
$Upgrade_diskSelection_Mode,
$Upgrade_disk_targetdisk,
$Upgrade_firstdisk_disktypeparameters,
[boolean]$Upgrade_deletecosvmdk = $False,
[ValidateSet('disk','firstdisk')]
$Installorupgrade_diskSelection_Mode,
$Installorupgrade_disk_targetdisk,
$Installorupgrade_firstdisk_disktypeparameters,
[boolean]$Installorupgrade_overwritevsan,
[boolean]$Installorupgrade_overwritevmfs,
[ValidateSet('drives','alldrives','ignoredrives','firstdisk')]
$Clearpart_driveSelection_Mode,
$clearpart_drives_targetdrives,
$clearpart_ignoredrives_targetdrives,
$clearpart_firstdisk_disktypeparameters,
[boolean]$clearpart_overwritevmfs,
[ValidateSet('ondisk','firtdisk')]
$partition_diskSelection_Mode,
$partition_datastorename,
$partition_ondisk_targetdisk,
$partition_onfirstdisk_disktypeparameters,
[ValidateSet('dhcp','static')]
$Network_bootproto_Mode,
$Network_device,
$Network_ip,
$Network_gateway,
$Network_nameserver,
$Network_netmask,
$Network_hostname,
$Network_vlanid,
[boolean]$Network_addvmportgroup
)
process{
	
	$MacAddressNewFormat = $Host_MacAddress -replace ":","-"
	$DestinationFilePath = $DestinationFolder + "\" +  $MacAddressNewFormat + "_ks.cfg"
	If(Test-Path $DestinationFilePath ){
	Remove-item $DestinationFilePath  -Force
	}
	$stream1 = [System.IO.StreamWriter] $DestinationFilePath
	
	#Miscellaneous section
	if ($Miscellaneous_vmaccepteula){
	$ToWrite = '# Accepts the VMware License Agreement (EULA).' + "`n"
	$stream1.Write($ToWrite)
	$ToWrite =  'vmaccepteula' + "`n"
	$stream1.Write($ToWrite)
	$ToWrite = "`n"
	$stream1.Write($ToWrite)	
	}

	IF($Miscellaneous_keyboard){
	$ToWrite = '# Set the keyboard type for the system' + "`n"
	$stream1.Write($ToWrite)
	$ToWrite =  "keyboard '" + $Miscellaneous_keyboard + "'" + "`n"
	$stream1.Write($ToWrite)
	$ToWrite = "`n"
	$stream1.Write($ToWrite)	
	}
	
	IF($Miscellaneous_dryrun){
	$ToWrite = '# Parse and check the kickstart file, but do not actually do the install.' + "`n"
	$stream1.Write($ToWrite)
	$ToWrite =  "dryrun" + "`n"
	$stream1.Write($ToWrite)
	$ToWrite = "`n"
	$stream1.Write($ToWrite)	
	}
	
	if ($Miscellaneous_reboot){
	$ToWrite = '# Reboot the machine after the scripted installation is finished.' + "`n"
	$stream1.Write($ToWrite)
	$ToWrite =  'reboot'
		if($Miscellaneous_reboot_noeject){
		$ToWrite =  $ToWrite + '--noeject' 
		}
	$ToWrite = $ToWrite + "`n"
	$stream1.Write($ToWrite)
	$ToWrite = "`n"
	$stream1.Write($ToWrite)	
	}
	
	If($Miscellaneous_rootpw){
	$ToWrite = '# Set the root password for the DCUI and Tech Support Mode' + "`n"
	$stream1.Write($ToWrite)
	$ToWrite =  'rootpw'
		If($Miscellaneous_rootpw_iscrypted){
		$ToWrite =  $ToWrite + ' --iscrypted'
		}
	$ToWrite =  $ToWrite + ' ' + $Miscellaneous_rootpw + "`n"
	$stream1.Write($ToWrite)
	$ToWrite = "`n"
	$stream1.Write($ToWrite)
	}

	IF($Miscellaneous_paranoid){
	$ToWrite = '# Causes warning messages to interrupt the installation. If you omit this command, warning messages are logged.'+ "`n"
	$stream1.Write($ToWrite)
	$ToWrite =  "paranoid" + "`n"
	$stream1.Write($ToWrite)
	$ToWrite = "`n"
	$stream1.Write($ToWrite)	
	}

	IF($Miscellaneous_licensekey){
	$ToWrite = '# Deprecated in ESXi 5.0.x. Supported in ESXi 5.1 and later. Configures licensing. If not included, ESXi installs in evaluation mode' + "`n"
	$stream1.Write($ToWrite)
	$ToWrite =  "serialnum --esx=" + $Miscellaneous_licensekey + "`n"
	$stream1.Write($ToWrite)
	$ToWrite = "`n"
	$stream1.Write($ToWrite)	
	}
	
	#Installation or upgrade section
	switch($installorUpgrade_Mode){
		install {
			$ToWrite = '# Specifies that this is a fresh installation. Replaces the deprecated autopart command used for ESXi 4.1 scripted installations. Either the install, upgrade, or installorupgrade command is required to determine which disk to install or upgrade ESXi on.' + "`n"
			$stream1.Write($ToWrite)
			$ToWrite = 'install'
				switch($Install_diskSelection_Mode){
					disk{
					$ToWrite = $ToWrite + ' --disk=' + $Install_disk_targetdisk
					}
					firstdisk{
					$ToWrite = $ToWrite + ' --firstdisk'
						if($Install_firstdisk_disktypeparameters){
						$ToWrite = $ToWrite + '=' + $Install_firstdisk_disktypeparameters
						}
						If($Install_ignoressd){
						$ToWrite = $ToWrite + ' --ignoressd' 
						}
					}
				}	
			if($Install_overwritevsan){
			$ToWrite = $ToWrite + ' --overwritevsan'
			}
			if($Install_overwritevmfs){
			$ToWrite = $ToWrite + ' --overwritevmfs'
			}
			if($Install_preservevmfs){
			$ToWrite = $ToWrite + ' --preservevmfs'
			}
			if($Install_novmfsondisk){
			$ToWrite = $ToWrite + ' --novmfsondisk'
			}
			$ToWrite =  $ToWrite + "`n"
			$stream1.Write($ToWrite)
			$ToWrite = "`n"
			$stream1.Write($ToWrite)
		}
		upgrade {
			$ToWrite = '# Specifies that this is a upgrade. Replaces the deprecated autopart command used for ESXi 4.1 scripted installations. One of the commands install, upgrade, or installorupgrade is required to determine which disk to install or upgrade ESXi on.' + "`n"
			$stream1.Write($ToWrite)
			$ToWrite = 'upgrade'
			switch($Upgrade_diskSelection_Mode){
					disk{
					$ToWrite = $ToWrite + ' --disk=' + $Upgrade_disk_targetdisk
					}
					firstdisk{
					$ToWrite = $ToWrite + ' --firstdisk'
						if($Upgrade_firstdisk_disktypeparameters){
						$ToWrite = $ToWrite + '=' + $Upgrade_firstdisk_disktypeparameters
						}
					}			
			}
			if($Upgrade_deletecosvmdk){
			$ToWrite = $ToWrite + ' --deletecosvmdk'
			}
			$ToWrite =  $ToWrite + "`n"
			$stream1.Write($ToWrite)
			$ToWrite = "`n"
			$stream1.Write($ToWrite)
		}
		installorupgrade {
			$ToWrite = '# Either the install, upgrade, or installorupgrade command is required to determine which disk to install or upgrade ESXi on.' + "`n"
			$stream1.Write($ToWrite)
			$ToWrite = 'installorupgrade'
			switch($Installorupgrade_diskSelection_Mode){
					disk{
					$ToWrite = $ToWrite + ' --disk=' + $Installorupgrade_disk_targetdisk
					}
					firstdisk{
					$ToWrite = $ToWrite + ' --firstdisk'
						if($Installorupgrade_firstdisk_disktypeparameters){
						$ToWrite = $ToWrite + '=' + $Installorupgrade_firstdisk_disktypeparameters
						}
					}			
			}
			if($Installorupgrade_overwritevsan){
			$ToWrite = $ToWrite + ' --overwritevsan'
			}
			if($Installorupgrade_overwritevsan){
			$ToWrite = $ToWrite + ' --overwritevmfs'
			}
			$ToWrite =  $ToWrite + "`n"
			$stream1.Write($ToWrite)
			$ToWrite = "`n"
			$stream1.Write($ToWrite)
		
		}
	}
	#Clearpart section
	if($installorUpgrade_Mode -eq "install"){
		if($Clearpart_driveSelection_Mode){
			$ToWrite = '# Clears any existing partitions on the disk. Requires the install command to be specified. Carefully edit the clearpart command in your existing scripts.' + "`n"
			$stream1.Write($ToWrite)		
			$ToWrite = 'clearpart'
			$stream1.Write($ToWrite)
				switch($Clearpart_driveSelection_Mode){
					drives{
					$ToWrite = $ToWrite + ' --drives=' + $clearpart_drives_targetdrives
					}
					alldrives{
					$ToWrite = $ToWrite + ' --alldrives'
					}
					ignoredrives{
					$ToWrite = $ToWrite + ' --ignoredrives=' + $clearpart_ignoredrives_targetdrives
					}
					firstdisk{
					$ToWrite = $ToWrite + ' --firstdisk'
						if($clearpart_firstdisk_disktypeparameters){
						$ToWrite = $ToWrite + '=' + $clearpart_firstdisk_disktypeparameters
						}
					}			
				}
				if(clearpart_overwritevmfs){
				$ToWrite = $ToWrite + ' --overwritevmfs'
				}
			$ToWrite =  $ToWrite + "`n"
			$stream1.Write($ToWrite)
			$ToWrite = "`n"
			$stream1.Write($ToWrite)	
		}
	}
	
	#Partition section
	if($partition_diskSelection_Mode){
			$ToWrite = '# Creates an additional VMFS datastore on the system. Only one datastore per disk can be created. Cannot be used on the same disk as the install command. Only one partition can be specified per disk and it can only be a VMFS partition.' + "`n"
			$stream1.Write($ToWrite)		
			$ToWrite = 'partition'
			$stream1.Write($ToWrite)
				switch($partition_diskSelection_Mode){
					ondisk{
					$ToWrite = $ToWrite + ' --ondisk=' + $partition_ondisk_targetdisk
					}
					firstdisk{
					$ToWrite = $ToWrite + ' --firstdisk'
						if($partition_onfirstdisk_disktypeparameters){
						$ToWrite = $ToWrite + '=' + $partition_onfirstdisk_disktypeparameters
						}					
					}
				}
			if($partition_datastorename){
			$ToWrite = $ToWrite + ' ' + $partition_datastorename
			}
			$ToWrite =  $ToWrite + "`n"
			$stream1.Write($ToWrite)
			$ToWrite = "`n"
			$stream1.Write($ToWrite)	
			
	}
	
	#Network section
	if($Network_bootproto_Mode){
		$ToWrite = '# Specify a network address for the system.' + "`n"
		$stream1.Write($ToWrite)
		$ToWrite = 'network'
			switch($Network_bootproto_Mode){
				dhcp{
				$ToWrite = $ToWrite+ ' --bootproto=dhcp'
				}
				static{
				$ToWrite = $ToWrite + ' --bootproto=static'
					if($Network_ip){
					$ToWrite = $ToWrite + ' --ip=' + $Network_ip
					}
					if($Network_gateway){
					$ToWrite = $ToWrite + ' --gateway=' + $Network_gateway
					}
					if($Network_nameserver){
					$ToWrite = $ToWrite + ' --nameserver=' + $Network_nameserver
					}
					if($Network_netmask){
					$ToWrite = $ToWrite + ' --netmask=' + $Network_netmask
					}
				}
			}
		if($Network_device){
		$ToWrite = $ToWrite + ' --device=' + $Network_device
		}	
		if($Network_hostname){
		$ToWrite = $ToWrite + ' --hostname=' + $Network_hostname
		}	
		if($Network_vlanid){
		$ToWrite = $ToWrite + ' --vlanid=' + $Network_vlanid
		}
		if($PSBoundParameters.ContainsKey('Network_addvmportgroup')){
			if($Network_addvmportgroup -eq $true){
			$ToWrite = $ToWrite + ' --addvmportgroup=1'
			}
			Else{
			$ToWrite = $ToWrite + ' --addvmportgroup=0'
			}
		}
	$ToWrite =  $ToWrite + "`n"
	$stream1.Write($ToWrite)
	}

	$stream1.Close()
	$stream1 = $Null
	
}
	
	
}

