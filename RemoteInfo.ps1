try{
    $hostname = $env:COMPUTERNAME
    $domain = $env:USERDOMAIN
    $model = (Get-WmiObject -ErrorAction Stop -Class:Win32_ComputerSystem).Model
    $cpuInfo = Get-WmiObject –class Win32_processor -ErrorAction Stop| Select-Object -ExpandProperty NumberOfCores
    $physicalMemory = Get-WmiObject CIM_PhysicalMemory -ErrorAction Stop | Measure-Object -Property capacity -sum | % {[math]::round(($_.sum / 1GB),2)} 
    $osInfo = Get-WmiObject Win32_OperatingSystem -ErrorAction Stop | Select-Object -ExpandProperty Caption
    
    Write-Output "----------------------"
    Write-Output "Hostname: $hostname"
    Write-Output "Domain: $domain"
    Write-Output "Model: $model"
    Write-Output "CPU: $cpuInfo"
    Write-Output "Memory: $physicalMemory GB"
    Write-Output "OS: $osInfo"
    Write-Output "----------------------"
}
catch{
    Write-Output "Error encountered getting device info"
}


