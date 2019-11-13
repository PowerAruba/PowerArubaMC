#
# Copyright 2019, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#

function Invoke-ArubaAPRestMethod {

    <#
      .SYNOPSIS
      Invoke RestMethod with ArubaAP connection (internal) variable

      .DESCRIPTION
      Invoke RestMethod with ArubaAP connection variable (uidaruba...)

      .EXAMPLE
      Invoke-ArubaAPRestMethod -method "get" -uri "configuration/object"

      Invoke-RestMethod with ArubaAP connection for get configuration/object

      .EXAMPLE
      Invoke-ArubaAPRestMethod "configuration/objectp"

      Invoke-RestMethod with ArubaAP connection for get configuration/object uri with default GET method parameter

      .EXAMPLE
      Invoke-ArubaAPRestMethod -method "post" -uri "configuration/object" -body $body

      Invoke-RestMethod with ArubaAP connection for post configuration/object uri with $body payloade
    #>

    [CmdletBinding(DefaultParametersetname="default")]
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

        $Server = ${DefaultArubaAPConnection}.Server
        $headers = ${DefaultArubaAPConnection}.headers
        $invokeParams = ${DefaultArubaAPConnection}.invokeParams
        $uidaruba = ${DefaultArubaAPConnection}.uidaruba
        $port = ${DefaultArubaAPConnection}.port

        $fullurl = "https://${Server}:${port}/${uri}"
        if ($fullurl -NotMatch "\?") {
            $fullurl += "?"
        }

        if ($uidaruba) {
            $fullurl += "&UIDARUBA=$uidaruba"
        }

        $sessionvariable = $DefaultArubaAPConnection.session
        try {
            if ($body) {
                $response = Invoke-RestMethod $fullurl -Method $method -body ($body | ConvertTo-Json) -Headers $headers -WebSession $sessionvariable @invokeParams
            }
            else {
                $response = Invoke-RestMethod $fullurl -Method $method -Headers $headers -WebSession $sessionvariable @invokeParams
            }
        }

        catch {
            Show-ArubaAPException $_
            throw "Unable to use ArubaAP API"
        }
        $response

    }

}