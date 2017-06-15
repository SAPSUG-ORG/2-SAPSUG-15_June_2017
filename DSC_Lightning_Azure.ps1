#---------------------------------------------------------------------------
#Provide a brief synopsis of your proposted topic in the space below:
<#
DSC Lightning Demo
#>
#---------------------------------------------------------------------------
#Provide a more detailed description of your proposed topic and what you will demo in the space below:
<#
Short lightning demo on DSC and it's capabilities.  I'll load a DSC module into Azure Automation and then create a Meta MOF on a local device that points to the Azure location.
Once set the LCM will be instructed to begin the pull and I'll walk everyone through how DSC is processing the changes and reporting the results back to Azure.
#>
#---------------------------------------------------------------------------
#code for your presentation should be put below this line:
#---------------------------------------------------------------------------

#example DSC configuration file
Configuration HyperVBuild{
    Param()
    Import-DscResource –ModuleName xHyper-V
    node localhost {
        #------------------------------------
        WindowsFeature 'Hyper-V' {
            Ensure='Present'
            Name='Hyper-V'
        }#hypFeature
        #------------------------------------
        WindowsFeature 'Hyper-V-Powershell' {
            Ensure='Present'
            Name='Hyper-V-Powershell'
        }#PSFeature
        #------------------------------------
        WindowsFeature 'Multipath-IO' {
            Ensure='Present'
            Name='Multipath-IO'
        }#MPIOFeature
        #------------------------------------
        WindowsFeature 'Telnet-Client' {
            Ensure='Present'
            Name='Telnet-Client'
        }#PSFeature
        #------------------------------------
        File VMsDirectory {
            Ensure = 'Present'
            Type = 'Directory'
            DestinationPath = "C:\VMs"
        }#VMsFile
        #------------------------------------
        File rspkgs {
            Ensure = 'Present'
            Type = 'Directory'
            DestinationPath = "C:\rs-pkgs"
        }#rspkgs
        #------------------------------------
        xVMSwitch LabSwitch {
            DependsOn = '[WindowsFeature]Hyper-V'
            Name = '_Inside'
            Ensure = 'Present'
            Type = 'External'
            NetAdapterName = 'Ethernet'
        }#switch
        #------------------------------------
    }#node

}#close configuration

# The DSC configuration that will generate metaconfigurations
[DscLocalConfigurationManager()]
Configuration DscMetaConfigs 
{ 
    param 
    ( 
        [Parameter(Mandatory=$True)] 
        [String]$RegistrationUrl,

        [Parameter(Mandatory=$True)] 
        [String]$RegistrationKey,

        [Parameter(Mandatory=$True)] 
        [String[]]$ComputerName,

        [Int]$RefreshFrequencyMins = 30, 

        [Int]$ConfigurationModeFrequencyMins = 15, 

        [String]$ConfigurationMode = "ApplyAndMonitor", 

        [String]$NodeConfigurationName,

        [Boolean]$RebootNodeIfNeeded= $False,

        [String]$ActionAfterReboot = "ContinueConfiguration",

        [Boolean]$AllowModuleOverwrite = $False,

        [Boolean]$ReportOnly
    )

    if(!$NodeConfigurationName -or $NodeConfigurationName -eq "") 
    { 
        $ConfigurationNames = $null 
    } 
    else 
    { 
        $ConfigurationNames = @($NodeConfigurationName) 
    }

    if($ReportOnly)
    {
       $RefreshMode = "PUSH"
    }
    else
    {
       $RefreshMode = "PULL"
    }

    Node $ComputerName
    {

        Settings 
        { 
            RefreshFrequencyMins = $RefreshFrequencyMins 
            RefreshMode = $RefreshMode 
            ConfigurationMode = $ConfigurationMode 
            AllowModuleOverwrite = $AllowModuleOverwrite 
            RebootNodeIfNeeded = $RebootNodeIfNeeded 
            ActionAfterReboot = $ActionAfterReboot 
            ConfigurationModeFrequencyMins = $ConfigurationModeFrequencyMins 
        }

        if(!$ReportOnly)
        {
           ConfigurationRepositoryWeb AzureAutomationDSC 
            { 
                ServerUrl = $RegistrationUrl 
                RegistrationKey = $RegistrationKey 
                ConfigurationNames = $ConfigurationNames 
            }

            ResourceRepositoryWeb AzureAutomationDSC 
            { 
               ServerUrl = $RegistrationUrl 
               RegistrationKey = $RegistrationKey 
            }
        }

        ReportServerWeb AzureAutomationDSC 
        { 
            ServerUrl = $RegistrationUrl 
            RegistrationKey = $RegistrationKey 
        }
    } 
}

# Create the metaconfigurations
# TODO: edit the below as needed for your use case
$Params = @{
     RegistrationUrl = 'https://ne-agentservice-prod-1.azure-automation.net/accounts/07aa2739-d8bc-4c79-8592-4009f1a37ba2';
     RegistrationKey = '4N8SMruHa63GhxlzfprL2mNaLOF0hdiB217Jjydahjsad3719skdjasdATlLdoJz0sGBiJkjAay3/hAFqwMw==';
     ComputerName = @('2016C');
     NodeConfigurationName = 'HyperVBuild.localhost';
     RefreshFrequencyMins = 30;
     ConfigurationModeFrequencyMins = 15;
     RebootNodeIfNeeded = $False;
     AllowModuleOverwrite = $False;
     ConfigurationMode = 'ApplyAndMonitor';
     ActionAfterReboot = 'ContinueConfiguration';
     ReportOnly = $False;  # Set to $True to have machines only report to AA DSC but not pull from it
}

# Use PowerShell splatting to pass parameters to the DSC configuration being invoked
# For more info about splatting, run: Get-Help -Name about_Splatting
DscMetaConfigs @Params

#*********************************************************************************************************
#now kick off the LCM:
Set-DscLocalConfigurationManager -Path C:\DscMetaConfigs