function New-ESXi_PXE_defaultconf{
param(
[Parameter(Mandatory=$true)]
$DestinationFolder,
[Parameter(Mandatory=$true)]
$PXE_VMware_Folder
)
	process{
		$DestinationPath = $DestinationFolder + "\default"
		If(Test-Path $DestinationPath){
		Remove-item $DestinationPath -Force
		}
		#Fist part regardless of which images are available
		$stream1 = [System.IO.StreamWriter] $DestinationPath
		$ToWrite = 'DEFAULT menu.c32' + "`n"
		$stream1.Write($ToWrite)
		$ToWrite =  'MENU TITLE ESXi select your version' + "`n"
		$stream1.Write($ToWrite)
		$ToWrite = 'NOHALT 1' + "`n"
		$stream1.Write($ToWrite)
		$ToWrite = 'PROMPT 0' + "`n"
		$stream1.Write($ToWrite)
		$ToWrite = 'TIMEOUT 80' + "`n"
		$stream1.Write($ToWrite)

		#MiddlePart Depend of all images available in this environment
		Get-ChildItem -path $PXE_VMware_Folder -Recurse -include Boot.cfg | foreach-object{
		$PXE_VMware_Folder_modified = $PXE_VMware_Folder + "\" 
		$DirectoryName = ($_.DirectoryName -replace [Regex]::Escape($PXE_VMware_Folder_modified),"") -replace [Regex]::Escape("\"),"/"
		$ToWrite = 'LABEL ' + $DirectoryName + "`n"
		$stream1.Write($ToWrite)
		$ToWrite = '  KERNEL vmware/' + $DirectoryName + '/mboot.c32' + "`n"
		$stream1.Write($ToWrite)
		$ToWrite = '  APPEND -c vmware/' + $DirectoryName + '/boot.cfg' + "`n"
		$stream1.Write($ToWrite)
		$ToWrite = '  MENU LABEL ' + $DirectoryName + ' ^Installer' + "`n"
		$stream1.Write($ToWrite)
		}

		#Last part regardless present regardless of which images are available
		$ToWrite = 'LABEL hddboot' + "`n"
		$stream1.Write($ToWrite)
		$ToWrite = '  LOCALBOOT 0x80' + "`n"
		$stream1.Write($ToWrite)
		$ToWrite = '  MENU LABEL ^Boot from local disk' + "`n"
		$stream1.Write($ToWrite)
		$stream1.Close()
		$stream1 = $Null
	}
}
