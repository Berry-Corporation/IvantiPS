function Get-IvantiIncidentAttachment {
    <#
    .SYNOPSIS
        List attachments for an incident.

    .DESCRIPTION
        Returns attachment records related to an incident.

    .PARAMETER RecID
        Ivanti Record ID for the incident.

    .NOTES
        https://help.ivanti.com/ht/help/en_US/ISM/2020/admin/Content/Configure/API/Get-Related-Business-Objects-API.htm
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$RecID
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"
        Write-DebugMessage "[$($MyInvocation.MyCommand.Name)] Function started. PSBoundParameters: $($PSBoundParameters | Out-String)"

        $IvantiTenantID = (Get-IvantiPSConfig).IvantiTenantID
        $uri = "https://{0}/api/odata/businessobject/incidents('{1}')/IncidentHasAttachment" -f $IvantiTenantID, $RecID
    }

    process {
        Invoke-IvantiMethod -URI $uri
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function ended"
        Write-DebugMessage "[$($MyInvocation.MyCommand.Name)] Function ended"
    }
}
