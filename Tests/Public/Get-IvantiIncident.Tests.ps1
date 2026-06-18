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
    }

    It 'resolves IncidentNumber to RecID and uses RecID filter internally' {
        $script:invokeCalls = @()
        function Invoke-IvantiMethod {
            param([string]$Uri, [hashtable]$GetParameter)
            $script:invokeCalls += [PSCustomObject]@{
                Uri          = $Uri
                GetParameter = $GetParameter
            }

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

        ($script:invokeCalls | Where-Object {
            $_.GetParameter['$select'] -eq 'RecID' -and
            $_.GetParameter['$filter'] -eq 'IncidentNumber eq 123456' -and
            $_.GetParameter['$top'] -eq 1
        }).Count | Should -Be 1

        ($script:invokeCalls | Where-Object {
            $_.GetParameter['$filter'] -eq "RecID eq 'incident-recid-123'"
        }).Count | Should -Be 1

        $verboseMessages | Should -Contain '[Get-IvantiIncident] IncidentNumber [123456] resolved to RecID [incident-recid-123]'
    }

    It 'warns and stops when IncidentNumber does not resolve to a RecID' {
        $script:invokeCalls = @()
        function Invoke-IvantiMethod {
            param([string]$Uri, [hashtable]$GetParameter)
            $script:invokeCalls += [PSCustomObject]@{
                Uri          = $Uri
                GetParameter = $GetParameter
            }
            $null
        }
        $script:warningMessages = @()
        function Write-Warning {
            param([string]$Message)
            $script:warningMessages += $Message
        }

        $result = Get-IvantiIncident -IncidentNumber 999999

        $result | Should -BeNullOrEmpty

        ($script:invokeCalls | Where-Object {
            $_.GetParameter['$filter'] -eq 'IncidentNumber eq 999999'
        }).Count | Should -Be 1

        $script:warningMessages | Should -Contain '[Get-IvantiIncident] No incident found for IncidentNumber [999999]'
    }
}
