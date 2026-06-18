Describe 'New Ivanti feature cmdlets' {

    BeforeAll {
        $repoRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
        . "$repoRoot/IvantiPS/Public/Get-IvantiIncidentMemo.ps1"
        . "$repoRoot/IvantiPS/Public/Get-IvantiServiceRequestMemo.ps1"
        . "$repoRoot/IvantiPS/Public/Get-IvantiIncidentAttachment.ps1"
        . "$repoRoot/IvantiPS/Public/Get-IvantiServiceRequestAttachment.ps1"
        . "$repoRoot/IvantiPS/Public/Save-IvantiAttachment.ps1"
    }

    BeforeEach {
        function Get-IvantiPSConfig { [pscustomobject]@{ IvantiTenantID = 'tenant.ivanticloud.com' } }
        function Get-IvantiSession { 'test-session' }
        function Invoke-IvantiMethod { param([Uri]$Uri, [hashtable]$GetParameter) @() }
        function Write-DebugMessage { param([string]$Message) }
    }

    It 'builds incident memo relationship request with default note/memo filter' {
        Mock -CommandName Invoke-IvantiMethod -MockWith { @() }

        Get-IvantiIncidentMemo -RecID 'INC-RECID' | Out-Null

        Assert-MockCalled -CommandName Invoke-IvantiMethod -Times 1 -Exactly -ParameterFilter {
            $Uri -eq "https://tenant.ivanticloud.com/api/odata/businessobject/incidents('INC-RECID')/IncidentContainsJournal" -and
            $GetParameter['$filter'] -eq "(JournalType eq 'Note' or JournalType eq 'Memo')"
        }
    }

    It 'omits memo filter when all journal types are requested' {
        Mock -CommandName Invoke-IvantiMethod -MockWith { @() }

        Get-IvantiServiceRequestMemo -RecID 'SR-RECID' -AllJournalTypes | Out-Null

        Assert-MockCalled -CommandName Invoke-IvantiMethod -Times 1 -Exactly -ParameterFilter {
            $Uri -eq "https://tenant.ivanticloud.com/api/odata/businessobject/servicereqs('SR-RECID')/ServiceReqContainsJournal" -and
            -not $GetParameter.ContainsKey('$filter')
        }
    }

    It 'builds incident attachment relationship request' {
        Mock -CommandName Invoke-IvantiMethod -MockWith { @() }

        Get-IvantiIncidentAttachment -RecID 'INC-RECID' | Out-Null

        Assert-MockCalled -CommandName Invoke-IvantiMethod -Times 1 -Exactly -ParameterFilter {
            $Uri -eq "https://tenant.ivanticloud.com/api/rest/Attachment" -and
            $GetParameter['ID'] -eq 'INC-RECID'
        }
    }

    It 'builds service request attachment relationship request' {
        Mock -CommandName Invoke-IvantiMethod -MockWith { @() }

        Get-IvantiServiceRequestAttachment -RecID 'SR-RECID' | Out-Null

        Assert-MockCalled -CommandName Invoke-IvantiMethod -Times 1 -Exactly -ParameterFilter {
            $Uri -eq "https://tenant.ivanticloud.com/api/rest/Attachment" -and
            $GetParameter['ID'] -eq 'SR-RECID'
        }
    }

    It 'downloads attachment data to the requested path' {
        Mock -CommandName Invoke-WebRequest -MockWith { @{ StatusCode = 200 } }
        Mock -CommandName Get-Item -MockWith { [pscustomobject]@{ FullName = '/tmp/out.bin' } }

        Save-IvantiAttachment -RecID 'ATT-RECID' -Path '/tmp/out.bin' | Out-Null

        Assert-MockCalled -CommandName Invoke-WebRequest -Times 1 -Exactly -ParameterFilter {
            $Uri -eq "https://tenant.ivanticloud.com/api/rest/Attachment?ID=ATT-RECID" -and
            $Method -eq 'GET' -and
            $OutFile -eq '/tmp/out.bin' -and
            $Headers.Authorization -eq 'test-session'
        }
    }
}
