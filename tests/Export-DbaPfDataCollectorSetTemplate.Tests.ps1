$CommandName = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")
Write-Host -Object "Running $PSCommandPath" -ForegroundColor Cyan
. "$PSScriptRoot\constants.ps1"

Describe "$CommandName Unit Tests" -Tag 'UnitTests' {
    Context "Validate parameters" {
        $paramCount = 6
        $defaultParamCount = 11
        [object[]]$params = (Get-ChildItem function:\Export-DbaPfDataCollectorSetTemplate).Parameters.Keys
        $knownParameters = 'ComputerName','Credential','CollectorSet','Path','InputObject','EnableException'
        It "Should contain our specific parameters" {
            ( (Compare-Object -ReferenceObject $knownParameters -DifferenceObject $params -IncludeEqual | Where-Object SideIndicator -eq "==").Count ) | Should Be $paramCount
        }
        It "Should only contain $paramCount parameters" {
            $params.Count - $defaultParamCount | Should Be $paramCount
        }
    }
}

Describe "$CommandName Integration Tests" -Tags "IntegrationTests" {
    BeforeEach {
        $null = Get-DbaPfDataCollectorSetTemplate -Template 'Long Running Queries' | Import-DbaPfDataCollectorSetTemplate
    }
    AfterAll {
        $null = Get-DbaPfDataCollectorSet -CollectorSet 'Long Running Queries' | Remove-DbaPfDataCollectorSet -Confirm:$false
    }
    Context "Verifying command returns all the required results" {
        It "returns a file system object" {
            $results = Get-DbaPfDataCollectorSet -CollectorSet 'Long Running Queries' | Export-DbaPfDataCollectorSetTemplate
            $results.BaseName | Should Be 'Long Running Queries'
        }
        It "returns a file system object" {
            $results = Export-DbaPfDataCollectorSetTemplate -CollectorSet 'Long Running Queries'
            $results.BaseName | Should Be 'Long Running Queries'
        }
    }
}
