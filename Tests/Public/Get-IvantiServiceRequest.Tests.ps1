Describe 'Get-IvantiServiceRequest' {
    BeforeAll {
        $repoRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
        . "$repoRoot\IvantiPS\Public\Get-IvantiServiceRequest.ps1"
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

        function Get-IvantiRecIdByServiceRequestNumber {
            param([int]$ServiceRequestNumber)
            "servicereq-recid-$ServiceRequestNumber"
        }

        function Invoke-IvantiMethod {}
    }

    It 'resolves ServiceRequestNumber to RecID and uses RecID filter internally' {
        $script:invokeCalls = @()
        function Invoke-IvantiMethod {
            param([string]$Uri, [hashtable]$GetParameter)
            $script:invokeCalls += [PSCustomObject]@{
                Uri          = $Uri
                GetParameter = $GetParameter
            }

            if ($GetParameter['$filter'] -eq "RecID eq 'servicereq-recid-123456'") {
                return [PSCustomObject]@{
                    RecID            = 'servicereq-recid-123456'
                    ServiceReqNumber = 123456
                }
            }
        }

        $output = Get-IvantiServiceRequest -ServiceRequestNumber 123456 -Verbose 4>&1

        ($script:invokeCalls | Where-Object {
            $_.GetParameter['$filter'] -eq "RecID eq 'servicereq-recid-123456'"
        }).Count | Should -Be 1
    }

    It 'stops when ServiceRequestNumber does not resolve to a RecID' {
        function Get-IvantiRecIdByServiceRequestNumber {
            param([int]$ServiceRequestNumber)
            $null
        }
        Mock -CommandName Invoke-IvantiMethod

        $result = Get-IvantiServiceRequest -ServiceRequestNumber 999999

        $result | Should -BeNullOrEmpty
        Assert-MockCalled -CommandName Invoke-IvantiMethod -Times 0
    }
}
