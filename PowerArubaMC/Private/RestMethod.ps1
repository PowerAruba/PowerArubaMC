#
# Copyright 2019, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#

function Invoke-ArubaMCRestMethod {

    <#
      .SYNOPSIS
      Invoke RestMethod with ArubaMC connection (internal) variable

      .DESCRIPTION
      Invoke RestMethod with ArubaMC connection variable (uidaruba...)

      .EXAMPLE
      Invoke-ArubaMCRestMethod -method "get" -uri "configuration/object"

      Invoke-RestMethod with ArubaMC connection for get configuration/object

      .EXAMPLE
      Invoke-ArubaMCRestMethod "configuration/objectp"

      Invoke-RestMethod with ArubaMC connection for get configuration/object uri with default GET method parameter

      .EXAMPLE
      Invoke-ArubaMCRestMethod -method "post" -uri "configuration/object" -body $body

      Invoke-RestMethod with ArubaMC connection for post configuration/object uri with $body payloade
    #>

    [CmdletBinding(DefaultParametersetname = "default")]
    Param(
        [Parameter(Mandatory = $true, position = 1)]
        [String]$uri,
        [Parameter(Mandatory = $false)]
        [ValidateSet("GET", "PUT", "POST", "DELETE")]
        [String]$method = "get",
        [Parameter(Mandatory = $false)]
        [psobject]$body
    )

    Begin {
    }

    Process {

        if ($null -eq $DefaultArubaMCConnection) {
            Throw "Not Connected. Connect to the Mobility Controller with Connect-ArubaMC"
        }

        $Server = ${DefaultArubaMCConnection}.Server
        $headers = ${DefaultArubaMCConnection}.headers
        $invokeParams = ${DefaultArubaMCConnection}.invokeParams
        $uidaruba = ${DefaultArubaMCConnection}.uidaruba
        $port = ${DefaultArubaMCConnection}.port

        $fullurl = "https://${Server}:${port}/${uri}"
        if ($fullurl -NotMatch "\?") {
            $fullurl += "?"
        }

        if ($uidaruba) {
            $fullurl += "&UIDARUBA=$uidaruba"
        }

        $sessionvariable = $DefaultArubaMCConnection.session
        try {
            if ($body) {
                $response = Invoke-RestMethod $fullurl -Method $method -body ($body | ConvertTo-Json) -Headers $headers -WebSession $sessionvariable @invokeParams
            }
            else {
                $response = Invoke-RestMethod $fullurl -Method $method -Headers $headers -WebSession $sessionvariable @invokeParams
            }
        }

        catch {
            Show-ArubaMCException $_
            throw "Unable to use ArubaMC API"
        }
        $response

    }

}