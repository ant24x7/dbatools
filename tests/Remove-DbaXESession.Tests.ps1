$CommandName = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")
Write-Host -Object "Running $PSCommandPath" -ForegroundColor Cyan
. "$PSScriptRoot\constants.ps1"

Describe "$CommandName Unit Tests" -Tag 'UnitTests' {
    Context "Validate parameters" {
        $paramCount = 6
        $defaultParamCount = 13
        [object[]]$params = (Get-ChildItem function:\Remove-DbaXESession).Parameters.Keys
        $knownParameters = 'SqlInstance','SqlCredential','Session','AllSessions','InputObject','EnableException'
        It "Should contain our specific parameters" {
            ( (Compare-Object -ReferenceObject $knownParameters -DifferenceObject $params -IncludeEqual | Where-Object SideIndicator -eq "==").Count ) | Should Be $paramCount
        }
        It "Should only contain $paramCount parameters" {
            $params.Count - $defaultParamCount | Should Be $paramCount
        }
    }
}

Describe "$CommandName Integration Tests" -Tags "IntegrationTests" {
    BeforeAll {
        $null = Get-DbaXESession -SqlInstance $script:instance2 -Session 'Profiler TSQL Duration' | Remove-DbaXESession
    }
    AfterAll {
        $null = Get-DbaXESession -SqlInstance $script:instance2 -Session 'Profiler TSQL Duration' | Remove-DbaXESession
    }
    Context "Test Importing Session Template" {
        $results = Import-DbaXESessionTemplate -SqlInstance $script:instance2 -Template 'Profiler TSQL Duration'

        It "session should exist" {
            $results.Name | Should Be 'Profiler TSQL Duration'
        }

        $null = Get-DbaXESession -SqlInstance $script:instance2 -Session 'Profiler TSQL Duration' | Remove-DbaXESession
        $results = Get-DbaXESession -SqlInstance $script:instance2 -Session 'Profiler TSQL Duration'

        It "session should no longer exist" {
            $results.Name | Should Be $null
            $results.Status | Should Be $null
        }
    }
}
