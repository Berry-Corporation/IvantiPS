function Get-IvantiServiceRequestMemo {
    <#
    .SYNOPSIS
        Get analyst memos/notes for a service request.

    .DESCRIPTION
        Returns related journal records for a service request. By default, only Note and Memo journal types are returned.

    .PARAMETER RecID
        Ivanti Record ID for the service request.

    .PARAMETER AllJournalTypes
        Return all related journal records instead of filtering to Note and Memo.

    .NOTES
        https://help.ivanti.com/ht/help/en_US/ISM/2020/admin/Content/Configure/API/Get-Related-Business-Objects-API.htm
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$RecID,
        [switch]$AllJournalTypes
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"
        Write-DebugMessage "[$($MyInvocation.MyCommand.Name)] Function started. PSBoundParameters: $($PSBoundParameters | Out-String)"

        $IvantiTenantID = (Get-IvantiPSConfig).IvantiTenantID
        $uri = "https://{0}/api/odata/businessobject/servicereqs('{1}')/ServiceReqHasJournal" -f $IvantiTenantID, $RecID

        $GetParameter = @{}
        if (-not $AllJournalTypes) {
            $GetParameter['$filter'] = "(JournalType eq 'Note' or JournalType eq 'Memo')"
        }
    }

    process {
        Invoke-IvantiMethod -URI $uri -GetParameter $GetParameter
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function ended"
        Write-DebugMessage "[$($MyInvocation.MyCommand.Name)] Function ended"
    }
}
