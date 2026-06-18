function Save-IvantiAttachment {
    <#
    .SYNOPSIS
        Download attachments for a business object RecID.

    .DESCRIPTION
        Downloads attachment response content from Ivanti and saves it to a local file path.

    .PARAMETER RecID
        Ivanti Record ID for the parent business object.

    .PARAMETER Path
        Destination file path.

    .NOTES
        https://help.ivanti.com/ht/help/en_US/ISM/2022/admin/Content/Configure/API/Get-Attachments.htm
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

        $uri = "https://{0}/api/rest/Attachment?ID={1}" -f $IvantiTenantID, $RecID
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
