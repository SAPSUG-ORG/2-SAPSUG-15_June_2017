
$Node = "192.168.1.104"
$Credential = Get-Credential -UserName:"root" -Message:"Enter Password:"

$session = New-CimSession -Credential $Credential -Authentication Basic -ComputerName $Node -SessionOption (New-CimSessionOption -SkipCACheck -SkipCNCheck -SkipRevocationCheck -UseSsl)
Get-CimInstance -CimSession $session -ClassName OMI_Identify -Namespace root/omi


Start-DscConfiguration -Path:"C:\temp" -CimSession:$session -Wait -Verbose