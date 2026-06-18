Describe 'Get-IvantiIncident' {
    BeforeAll {
        $repoRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
        . "$repoRoot\IvantiPS\Public\Get-IvantiIncident.ps1"
    }

    BeforeEach {
        function Get-IvantiPSConfig {
            [PSCustomObject]@{
                IvantiTenantID = 'example.ivanticloud.com'
            }
        }

        function Write-DebugMessage {
            param([string]$Message)
        }

        function Get-IvantiAgency {
            [PSCustomObject]@{
                RecID = 'agency-recid'
            }
        }

        function Invoke-IvantiMethod {}
    }

    It 'resolves IncidentNumber to RecID and uses RecID filter internally' {
        Mock -CommandName Invoke-IvantiMethod -MockWith {
            param([string]$Uri, [hashtable]$GetParameter)

            if ($GetParameter['$filter'] -eq 'IncidentNumber eq 123456') {
                return [PSCustomObject]@{ RecID = 'incident-recid-123' }
            }

            if ($GetParameter['$filter'] -eq "RecID eq 'incident-recid-123'") {
                return [PSCustomObject]@{
                    RecID          = 'incident-recid-123'
                    IncidentNumber = 123456
                }
            }
        }

        $output = Get-IvantiIncident -IncidentNumber 123456 -Verbose 4>&1
        $verboseMessages = $output | Where-Object { $_ -is [System.Management.Automation.VerboseRecord] } | ForEach-Object Message

        Assert-MockCalled -CommandName Invoke-IvantiMethod -Times 1 -ParameterFilter {
            $GetParameter['$select'] -eq 'RecID' -and
            $GetParameter['$filter'] -eq 'IncidentNumber eq 123456' -and
            $GetParameter['$top'] -eq 1
        }

        Assert-MockCalled -CommandName Invoke-IvantiMethod -Times 1 -ParameterFilter {
            $GetParameter['$filter'] -eq "RecID eq 'incident-recid-123'"
        }

        $verboseMessages | Should -Contain '[Get-IvantiIncident] IncidentNumber [123456] resolved to RecID [incident-recid-123]'
    }

    It 'warns and stops when IncidentNumber does not resolve to a RecID' {
        Mock -CommandName Invoke-IvantiMethod -MockWith { $null }
        Mock -CommandName Write-Warning

        $result = Get-IvantiIncident -IncidentNumber 999999

        $result | Should -BeNullOrEmpty

        Assert-MockCalled -CommandName Invoke-IvantiMethod -Times 1 -ParameterFilter {
            $GetParameter['$filter'] -eq 'IncidentNumber eq 999999'
        }

        Assert-MockCalled -CommandName Write-Warning -Times 1 -ParameterFilter {
            $Message -eq '[Get-IvantiIncident] No incident found for IncidentNumber [999999]'
        }
    }
}
