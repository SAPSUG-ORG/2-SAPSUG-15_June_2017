#----------------------------------------------------------------------
#determine current configuration of LCM
Get-DscLocalConfigurationManager

#determine if current DSC applied
Get-DscConfiguration

#test DSC
Test-DscConfiguration
#test DSC with use-able information
Test-DscConfiguration -Verbose

#determine what DSC resources are available on your device
Get-DscResource
#determine what options you have with a resource
Get-DscResource -Name File | Select-Object -ExpandProperty Properties
#----------------------------------------------------------------------
Configuration TestDSC{
    Param()
    node localhost {
        #------------------------------------
        WindowsFeature 'Telnet-Client' {
            Ensure='Absent'
            Name='Telnet-Client'
        }#TelNetFeature
        #------------------------------------
        File DSCDirectory {
            Ensure = 'Present'
            Type = 'Directory'
            DestinationPath = "C:\NewDSCFolder"
        }#VMsFile
        #------------------------------------
        File DSCFile {
            DependsOn = '[File]DSCDirectory'
            Ensure = 'Present'
            Type = 'File'
            DestinationPath = "C:\NewDSCFolder\DSCFile.txt"
            Contents = 'DSC Made This.'
        }#rspkgs
        #------------------------------------
    }#node

}#close configuration
TestDSC -OutputPath C:\DSC

Start-DscConfiguration -ComputerName 2016H -Path C:\DSC -Wait -Verbose -Force
#----------------------------------------------------------------------
#find more DSC capabilities
Find-Module -Name "*hyper*" -Tag DSC
#install a DSC module
Install-Module -Name xHyper-V
#----------------------------------------------------------------------
#Remove all mof files (pending,current,backup,MetaConfig.mof,caches,etc)
rm C:\windows\system32\Configuration\*.mof*
#Kill the LCM/DSC processes
gps wmi* | ? {$_.modules.ModuleName -like "*DSC*"} | stop-process -force
#----------------------------------------------------------------------