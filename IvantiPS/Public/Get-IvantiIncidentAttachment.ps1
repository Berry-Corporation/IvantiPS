function Get-IvantiIncidentAttachment {
    <#
    .SYNOPSIS
        List attachments for an incident.

    .DESCRIPTION
        Returns attachments for an incident by incident RecID.

    .PARAMETER RecID
        Ivanti Record ID for the incident.

    .NOTES
        https://help.ivanti.com/ht/help/en_US/ISM/2022/admin/Content/Configure/API/Get-Attachments.htm
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
        $uri = "https://{0}/api/rest/Attachment" -f $IvantiTenantID
        $GetParameter = @{ ID = $RecID }
    }

    process {
        Invoke-IvantiMethod -URI $uri -GetParameter $GetParameter
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function ended"
        Write-DebugMessage "[$($MyInvocation.MyCommand.Name)] Function ended"
    }
}
