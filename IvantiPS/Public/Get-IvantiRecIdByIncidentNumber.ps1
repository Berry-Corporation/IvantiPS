function Get-IvantiRecIdByIncidentNumber {
    <#
    .SYNOPSIS
        Resolve an incident number to an Ivanti RecID.

    .DESCRIPTION
        Looks up an incident by IncidentNumber and returns the corresponding RecID.

    .PARAMETER IncidentNumber
        Incident number to resolve.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [int]$IncidentNumber
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"
        Write-DebugMessage "[$($MyInvocation.MyCommand.Name)] Function Started. PSBoundParameters: $($PSBoundParameters | Out-String)"

        $IvantiTenantID = (Get-IvantiPSConfig).IvantiTenantID
        $uri = "https://$IvantiTenantID/api/odata/businessobject/incidents"
    }

    process {
        $IncidentRecID = Invoke-IvantiMethod -Uri $uri -GetParameter @{
            '$select' = 'RecID'
            '$filter' = "IncidentNumber eq $IncidentNumber"
            '$top'    = 1
        }

        if ($IncidentRecID) {
            Write-Verbose "[$($MyInvocation.MyCommand.Name)] IncidentNumber [$IncidentNumber] resolved to RecID [$($IncidentRecID.RecID)]"
            $IncidentRecID.RecID
        } else {
            Write-Warning "[$($MyInvocation.MyCommand.Name)] No incident found for IncidentNumber [$IncidentNumber]"
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function ended"
        Write-DebugMessage "[$($MyInvocation.MyCommand.Name)] Function ended"
    }
}
