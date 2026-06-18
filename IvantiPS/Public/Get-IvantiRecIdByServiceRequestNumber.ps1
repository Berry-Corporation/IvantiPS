function Get-IvantiRecIdByServiceRequestNumber {
    <#
    .SYNOPSIS
        Resolve a service request number to an Ivanti RecID.

    .DESCRIPTION
        Looks up a service request by ServiceReqNumber and returns the corresponding RecID.

    .PARAMETER ServiceRequestNumber
        Service request number to resolve.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [int]$ServiceRequestNumber
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"
        Write-DebugMessage "[$($MyInvocation.MyCommand.Name)] Function Started. PSBoundParameters: $($PSBoundParameters | Out-String)"

        $IvantiTenantID = (Get-IvantiPSConfig).IvantiTenantID
        $uri = "https://$IvantiTenantID/api/odata/businessobject/servicereqs"
    }

    process {
        $ServiceRequestRecID = Invoke-IvantiMethod -Uri $uri -GetParameter @{
            '$select' = 'RecID'
            '$filter' = "ServiceReqNumber eq $ServiceRequestNumber"
            '$top'    = 1
        }

        if ($ServiceRequestRecID) {
            Write-Verbose "[$($MyInvocation.MyCommand.Name)] ServiceRequestNumber [$ServiceRequestNumber] resolved to RecID [$($ServiceRequestRecID.RecID)]"
            $ServiceRequestRecID.RecID
        } else {
            Write-Warning "[$($MyInvocation.MyCommand.Name)] No service request found for ServiceRequestNumber [$ServiceRequestNumber]"
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function ended"
        Write-DebugMessage "[$($MyInvocation.MyCommand.Name)] Function ended"
    }
}
