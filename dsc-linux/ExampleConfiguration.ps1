Configuration ExampleConfiguration{

    Import-DscResource -Module nx

    Node  "192.168.1.104"{
    nxFile ExampleFile {

        DestinationPath = "/tmp/example"
        Contents = "hello world `n"
        Ensure = "Present"
        Type = "File"
    }

    nxUser NewAccount
    {
        UserName = 'user01'
        Ensure = 'Present'
        FullName = 'A User'
        Password = 'P@ssw0rd!'
        HomeDirectory = '/home/user01'
    }

    nxPackage httpd
    {
        Name = "httpd"
        Ensure = "Present"
        PackageManager = "Yum"
    }

    nxService ApacheService 
    {
        Name = "httpd"
        State = "running"
        Enabled = $true
        Controller = "systemd"
    }

    }
}
ExampleConfiguration -OutputPath:"C:\temp"