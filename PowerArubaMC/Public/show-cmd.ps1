#
# Copyright 2019, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#

function Get-ArubaMCShowCmd {

    <#
        .SYNOPSIS
        Get the result of a cli command on Aruba Mobility Controller

        .DESCRIPTION
        Get the result of a cli command.

        .EXAMPLE
        Get-ArubaMCShowCmd -cmd "Show running-config"

        This function give you the result of output of cmd parameter

    #>

    Param(
        [Parameter (Mandatory = $true, Position = 1)]
        [string]$cmd
    )

    Begin {
    }

    Process {

        #Replace space by +
        $cmd = $cmd -replace ' ', '+'

        $uri = "v1/configuration/showcommand?command=$cmd"

        $response = Invoke-ArubaMCRestMethod -uri $uri -method 'GET'

        $response
    }

    End {
    }
}
