
# PowerArubaMC

This is a Powershell module for configure a Aruba Mobility Controller (MC) and Mobility Manager

With this module (version 0.1.0) you can manage:

- Show commands

More functionality will be added later.

Connection can use HTTPS (default)
Tested with Aruba Moblity Controller or Mobility Master (using 8.x.x.x firmware and later...) on Windows/Linux/macOS

<!--
# Usage

All resource management functions are available with the Powershell verbs GET, ADD, SET, REMOVE.
For example, you can manage Vlans with the following commands:
- `Get-ArubaSWVlans`
- `Add-ArubaSWVlans`
- `Set-ArubaSWVlans`
- `Remove-ArubaSWVlans`
-->
# Requirements

- Powershell 5 or 6 (Core) (If possible get the latest version)
- An Aruba Mobility Controller or Mobility Master (with firmware 8.x.x.x)

# Instructions
### Install the module
```powershell
# Automated installation (Powershell 5 or later):
    Install-Module PowerArubaMC

# Import the module
    Import-Module PowerArubaMC

# Get commands in the module
    Get-Command -Module PowerArubaMC

# Get help
    Get-Help Get-ArubaMCShowCmd -Full
```

# Examples
### Connecting to the Aruba Mobility Controller/Master

The first thing to do is to connect to a Aruba Mobility Controller/Master with the command `Connect-ArubaMC` :

```powershell
# Connect to the Aruba Mobility Controller/Master
    Connect-ArubaMC 192.0.2.1

#we get a prompt for credential
```
if you get a warning about `Unable to connect` Look [Issue](#Issue)


### Show command

You can display some command... (CLi to API)

```powershell
# Display AP Database (show ap database)
    Get-ArubaMCShowCmd "show ap database"


    Status               : Success
    Status-code          : 0
    CLI Command executed : show clients

    IAP IP address       : 10.44.55.230
    Command output       : cli output:

                        COMMAND=show clients

                        Client List
                        -----------
                        Name  IP Address  MAC Address  OS  ESSID  Access Point  Channel  Type  Role  IPv6 Address  Signal  Speed (mbps)
                        ----  ----------  -----------  --  -----  ------------  -------  ----  ----  ------------  ------  ------------
                        Number of Clients   :0
                        Info timestamp      :1522412





```


### Disconnecting

```powershell
# Disconnect from the Aruba Mobility Controller/Master
    Disconnect-ArubaMC
```

# Issue

## Unable to connect (certificate)
if you use `Connect-ArubaMC` and get `Unable to Connect (certificate)`

The issue coming from use Self-Signed or Expired Certificate for AP management
Try to connect using `Connect-ArubaMC -SkipCertificateCheck`



# List of available command
```powershell
Connect-ArubaMC
Disconnect-ArubaMC
Get-ArubaMCShowCmd
Invoke-ArubaMCRestMethod
Set-ArubaMCCipherSSL
Set-ArubaMCuntrustedSSL
Show-ArubaMCException
```

# Author

**Alexis La Goutte**
- <https://github.com/alagoutte>
- <https://twitter.com/alagoutte>

# Special Thanks

- Warren F. for his [blog post](http://ramblingcookiemonster.github.io/Building-A-PowerShell-Module/) 'Building a Powershell module'
- Erwan Quelin for help about Powershell

# License

Copyright 2019 Alexis La Goutte and the community.
