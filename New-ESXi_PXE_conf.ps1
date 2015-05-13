function New-ESXi_PXE_conf{
param(
[Parameter(Mandatory=$true,HelpMessage="The kickstart file will be generated for a host with this mac address")]
$Host_macaddress,
[Parameter(Mandatory=$true)]
$DestinationFolder,
[Parameter(Mandatory=$true)]
$ImageName,
[Parameter(Mandatory=$true)]
$FTPAddress,
[Parameter(Mandatory=$true)]
$FTPUser,
[Parameter(Mandatory=$true)]
$FTPPassword
)
  process{
 
    $MacAddressNewFormat = $Host_macaddress -replace ":","-"
    $DestinationPath = $DestinationFolder + '\01-' + $MacAddressNewFormat
    If(Test-Path $DestinationPath){
    Remove-item $DestinationPath -Force
    }
     
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
     
    $ToWrite = 'LABEL ' + $ImageName + "`n"
    $stream1.Write($ToWrite)
    $ToWrite = '  KERNEL vmware/' + $ImageName + '/mboot.c32' + "`n"
    $stream1.Write($ToWrite)
    $ToWrite = '  APPEND -c vmware/' + $ImageName + '/boot.cfg' + " ks=ftp://" + $FTPUser + ":" + $FTPPassword + "@" + $FTPAddress + "/"+ $MacAddressNewFormat + "_ks.cfg" + "`n"
    $stream1.Write($ToWrite)
    $ToWrite = '  MENU LABEL ' + $ImageName + ' ^Installer' + "`n"
    $stream1.Write($ToWrite)
    $stream1.Close()
    $stream1 = $Null
 
     
  }
 
}
