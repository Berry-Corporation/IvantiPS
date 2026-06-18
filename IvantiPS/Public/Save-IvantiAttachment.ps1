function Save-IvantiAttachment {
    <#
    .SYNOPSIS
        Download an attachment by RecID.

    .DESCRIPTION
        Downloads attachment content from Ivanti and saves it to a local file path.

    .PARAMETER RecID
        Ivanti Record ID for the attachment.

    .PARAMETER Path
        Destination file path.

    .NOTES
        https://help.ivanti.com/ht/help/en_US/ISM/2020/admin/Content/Configure/API/Get-Business-Object-by-Reference.htm
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$RecID,
        [Parameter(Mandatory)]
        [string]$Path
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"
        Write-DebugMessage "[$($MyInvocation.MyCommand.Name)] Function started. PSBoundParameters: $($PSBoundParameters | Out-String)"

        $IvantiTenantID = (Get-IvantiPSConfig).IvantiTenantID
        $session = Get-IvantiSession
        if (-not $session) {
            Write-Warning "[$($MyInvocation.MyCommand.Name)] Must first establish session with Connect-IvantiTenant. Exiting..."
            break
        }

        $uri = "https://{0}/api/odata/businessobject/attachments('{1}')/Data" -f $IvantiTenantID, $RecID
        $headers = @{Authorization = $session}

        $directory = Split-Path -Path $Path -Parent
        if ($directory -and -not (Test-Path -Path $directory)) {
            $null = New-Item -Path $directory -ItemType Directory -Force
        }
    }

    process {
        $splatParameters = @{
            Uri         = $uri
            Method      = 'GET'
            Headers     = $headers
            OutFile     = $Path
            ErrorAction = 'Stop'
        }
        Invoke-WebRequest @splatParameters | Out-Null
        Get-Item -Path $Path
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function ended"
        Write-DebugMessage "[$($MyInvocation.MyCommand.Name)] Function ended"
    }
}
