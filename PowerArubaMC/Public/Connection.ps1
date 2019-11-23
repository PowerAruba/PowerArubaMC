#
# Copyright 2019, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#

function Connect-ArubaAP {

    <#
      .SYNOPSIS
      Connect to a Aruba Mobility Controller

      .DESCRIPTION
      Connect to a Aruba Mobility Controllert

      .EXAMPLE
      Connect-ArubaAP -Server 192.0.2.1

      Connect to a Aruba Mobility Controller with IP 192.0.2.1 using (Get-)credential

      .EXAMPLE
      Connect-ArubaAP -Server 192.0.2.1 -SkipCertificateCheck

      Connect to an ArubaMobility Controller using HTTPS (without check certificate validation) with IP 192.0.2.1 using (Get-)credential

      .EXAMPLE
      Connect-ArubaAP -Server 192.0.2.1 -port 4443

        Connect to an Aruba Mobility Controllerwith port 4443 with IP 192.0.2.1 using (Get-)credential

      .EXAMPLE
      $cred = get-credential
      PS C:\>Connect-ArubaAP -Server 192.0.2.1 -credential $cred

      Connect to a Aruba Mobility Controller with IP 192.0.2.1 and passing (Get-)credential

      .EXAMPLE
      $mysecpassword = ConvertTo-SecureString aruba -AsPlainText -Force
      PS C:\>Connect-ArubaAP -Server 192.0.2.1 -Username admin -Password $mysecpassword

      Connect to a Aruba Mobility Controller with IP 192.0.2.1 using Username and Password
  #>

    Param(
        [Parameter(Mandatory = $true, position = 1)]
        [String]$Server,
        [Parameter(Mandatory = $false)]
        [String]$Username,
        [Parameter(Mandatory = $false)]
        [SecureString]$Password,
        [Parameter(Mandatory = $false)]
        [PSCredential]$Credentials,
        [Parameter(Mandatory = $false)]
        [switch]$SkipCertificateCheck = $false,
        [Parameter(Mandatory = $false)]
        [ValidateRange(1, 65535)]
        [int]$port = 4343
    )

    Begin {
    }

    Process {

        $connection = @{server = ""; session = ""; invokeParams = ""; uidaruba = ""; port = $port }
        $invokeParams = @{DisableKeepAlive = $false; UseBasicParsing = $true; SkipCertificateCheck = $SkipCertificateCheck }

        #If there is a password (and a user), create a credentials
        if ($Password) {
            $Credentials = New-Object System.Management.Automation.PSCredential($Username, $Password)
        }
        #Not Credentials (and no password)
        if ($null -eq $Credentials) {
            $Credentials = Get-Credential -Message 'Please enter administrative credentials for your Aruba Mobility Controller'
        }

        if ("Desktop" -eq $PSVersionTable.PsEdition) {
            #Remove -SkipCertificateCheck from Invoke Parameter (not supported <= PS 5)
            $invokeParams.remove("SkipCertificateCheck")
            #Enable UseUnsafeParsingHeader for fix protocol violation when use PS5 (See Bug #2)
            Set-UseUnsafeHeaderParsing -Enable
        }
        else {
            #Core Edition
            #Remove -UseBasicParsing (Enable by default with PowerShell 6/Core)
            $invokeParams.remove("UseBasicParsing")
        }

        #for PowerShell (<=) 5 (Desktop), Enable TLS 1.1, 1.2 and Disable SSL chain trust (needed/recommanded by ArubaAP)
        if ("Desktop" -eq $PSVersionTable.PsEdition) {
            #Enable TLS 1.1 and 1.2
            Set-ArubaAPCipherSSL
            if ($SkipCertificateCheck) {
                #Disable SSL chain trust...
                Set-ArubaAPuntrustedSSL
            }
        }

        $postParams = "username=" + $Credentials.username + "&password=" + $Credentials.GetNetworkCredential().Password
        $url = "https://${Server}:${port}/v1/api/login"
        $headers = @{ Accept = "application/json"; "Content-type" = "application/json" }

        try {
            $response = Invoke-RestMethod $url -Method POST -Body $postParams -SessionVariable arubaap -headers $headers @invokeParams
        }
        catch {
            Show-ArubaAPException $_
            throw "Unable to connect"
        }

        if ($response._global_result.Status -ne "0" -or $null -eq $response._global_result.uidaruba) {
            $errormsg = $response._global_result.status_str
            throw "Unable to connect ($errormsg)"
        }

        $connection.server = $server
        $connection.session = $arubaap
        $connection.invokeParams = $invokeParams
        $connection.uidaruba = $response._global_result.uidaruba

        set-variable -name DefaultArubaAPConnection -value $connection -scope Global

        $connection
    }

    End {
    }
}

function Disconnect-ArubaAP {

    <#
        .SYNOPSIS
        Disconnect to a Aruba Mobility Controller

        .DESCRIPTION
        Disconnect the connection on Aruba Mobility Controller

        .EXAMPLE
        Disconnect-ArubaAP

        Disconnect the connection

        .EXAMPLE
        Disconnect-ArubaAP -noconfirm

        Disconnect the connection with no confirmation

    #>

    Param(
        [Parameter(Mandatory = $false)]
        [switch]$noconfirm
    )

    Begin {
    }

    Process {

        $url = "v1/api/logout"

        if ( -not ( $Noconfirm )) {
            $message = "Remove Aruba Mobility Controller connection."
            $question = "Proceed with removal of Aruba Mobility Controller connection ?"
            $choices = New-Object Collections.ObjectModel.Collection[Management.Automation.Host.ChoiceDescription]
            $choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&Yes'))
            $choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&No'))

            $decision = $Host.UI.PromptForChoice($message, $question, $choices, 1)
        }
        else { $decision = 0 }
        if ($decision -eq 0) {
            Write-Progress -activity "Remove Aruba Mobility Controller connection"
            Invoke-ArubaAPRestMethod -method "Get" -uri $url | Out-Null
            Write-Progress -activity "Remove Aruba Mobility Controller connection" -completed
            if (Get-Variable -Name DefaultArubaAPConnection -scope global) {
                Remove-Variable -name DefaultArubaAPConnection -scope global
            }
        }

    }

    End {
    }
}
