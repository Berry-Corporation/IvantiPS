Describe 'Get-IvantiRecIdByServiceRequestNumber' {
    BeforeAll {
        $repoRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
        . "$repoRoot\IvantiPS\Public\Get-IvantiRecIdByServiceRequestNumber.ps1"
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

        function Invoke-IvantiMethod {}
    }

    It 'returns recid and writes verbose output when service request number is found' {
        Mock -CommandName Invoke-IvantiMethod -MockWith {
            [PSCustomObject]@{ RecID = 'servicereq-recid-123' }
        }

        $output = Get-IvantiRecIdByServiceRequestNumber -ServiceRequestNumber 123 -Verbose 4>&1
        $recid = $output | Where-Object { $_ -isnot [System.Management.Automation.VerboseRecord] }
        $verboseMessages = $output | Where-Object { $_ -is [System.Management.Automation.VerboseRecord] } | ForEach-Object Message

        $recid | Should -Be 'servicereq-recid-123'
        $verboseMessages | Should -Contain '[Get-IvantiRecIdByServiceRequestNumber] ServiceRequestNumber [123] resolved to RecID [servicereq-recid-123]'
    }

    It 'writes warning and returns nothing when service request number is not found' {
        Mock -CommandName Invoke-IvantiMethod -MockWith { $null }
        Mock -CommandName Write-Warning

        $result = Get-IvantiRecIdByServiceRequestNumber -ServiceRequestNumber 999

        $result | Should -BeNullOrEmpty
        Assert-MockCalled -CommandName Write-Warning -Times 1 -ParameterFilter {
            $Message -eq '[Get-IvantiRecIdByServiceRequestNumber] No service request found for ServiceRequestNumber [999]'
        }
    }
}
