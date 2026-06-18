Describe 'Invoke-IvantiMethod' {
    BeforeAll {
        $repoRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
        . "$repoRoot\IvantiPS\Private\Invoke-IvantiMethod.ps1"
        . "$repoRoot\IvantiPS\Private\Test-ServerResponse.ps1"
    }

    BeforeEach {
        function Get-IvantiSession { 'test-session' }
        function Join-Hashtable {
            param([System.Collections.IDictionary[]]$Hashtable)
            $result = @{}
            foreach ($item in $Hashtable) {
                if ($item) {
                    foreach ($key in $item.Keys) {
                        $result[$key] = $item[$key]
                    }
                }
            }
            $result
        }
        function ConvertTo-ParameterHash { @{} }
        function ConvertTo-GetParameter { '?' }
        function Write-DebugMessage { param([string]$Message) }
    }

    It 'throws when the API returns an error code response' {
        Mock -CommandName Invoke-RestMethod -MockWith {
            [PSCustomObject]@{
                Code        = 500
                description = 'server error'
                message     = @('failed request')
            }
        }

        { Invoke-IvantiMethod -URI 'https://example.test/api/odata/incidents' } | Should -Throw
    }

    It 'uses current level in debug output when body is present' {
        $script:capturedMessages = @()
        Mock -CommandName Write-Debug -MockWith {
            param([string]$Message)
            $script:capturedMessages += $Message
        }
        Mock -CommandName Invoke-RestMethod -MockWith {
            [PSCustomObject]@{
                Value         = @()
                '@odata.count' = 0
            }
        }

        Invoke-IvantiMethod -URI 'https://example.test/api/odata/incidents' -Body '{"ping":"pong"}' -Level 1 | Out-Null

        ($script:capturedMessages | Where-Object {
            $_ -match '^\[Invoke-IvantiMethod 1\] Added body to splatparm:'
        }).Count | Should -BeGreaterThan 0
    }
}
