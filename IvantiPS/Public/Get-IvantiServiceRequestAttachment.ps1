function Get-IvantiServiceRequestAttachment {
    <#
    .SYNOPSIS
        List attachments for a service request.

    .DESCRIPTION
        Returns attachments for a service request by service request RecID.

    .PARAMETER RecID
        Ivanti Record ID for the service request.

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
