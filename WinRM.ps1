#-----------------------------------------------------------
#verify if WinRM is enabled
winrm get winrm/config/winrs
#verify port configuration
winrm get winrm/config/Service/DefaultPorts
#verify listeners
winrm e winrm/config/listener
#verify service
Winrm get winrm/config/service
#-----------------------------------------------------------
#configure winrm
winrm quickconfig
#The default port number is 5985 for WinRM to communicate with a remote computer.
#-----------------------------------------------------------
#test from remote device
Test-WSMan -ComputerName 2016A
#-----------------------------------------------------------
#domain to same domain
Enter-PSSession -ComputerName 2016A
Exit
#_____________________
#multinode session
$sessions = New-PSSession -ComputerName 2016A,2016B,2016C
Invoke-Command -Session $sessions -ScriptBlock {hostname} -ThrottleLimit 1
#_____________________
#running functions
function Get-Model {
    $model = ""
    try{
        $model = (Get-WmiObject -ErrorAction Stop -Class:Win32_ComputerSystem).Model
    }
    catch{
        $model = "ERROR"
    }
    return $model
}
$sessions = New-PSSession -ComputerName 2016A,2016B,2016C
Invoke-Command -Session $sessions -ScriptBlock ${function:Get-Model} -ThrottleLimit 1
#_____________________
#running scripts
$sessions = New-PSSession -ComputerName 2016A,2016B,2016C
Invoke-Command -Session $sessions -FilePath "C:\Users\jake\Desktop\RemoteInfo.ps1" -ThrottleLimit 1
#-----------------------------------------------------------
#domain to workgroup | workgroup to workgroup - much more challenging
#only SSL WinRM is supported in this configuration
#have to associate HTTPS listener with certificate to support SSL
ls CERT:\LocalMachine\My
Get-ChildItem WSMan:\localhost\Listener
#have to add remote host to trusted hosts on local management device
Set-Item WSMan:\localhost\Client\TrustedHosts -Value "fqdn-of-hyper-v-host"
#have to establish connection to device using custom session options
$creds = Get-Credential
$so = New-PSSessionOption -SkipCNCheck -SkipCACheck -SkipRevocationCheck
Enter-PSSession -ComputerName 10.0.3.50 -UseSSL -SessionOption $so -Credential $creds
#-----------------------------------------------------------