# Get-LocalMonitor.Tests.ps1
BeforeAll {
  . "$PSScriptRoot\..\Public\Get-LocalMonitor.ps1"
}

Describe 'Get-LocalMonitor Function Tests' {

  Context 'General Function Behavior' {
    BeforeEach {
      Mock -CommandName Get-CimInstance -MockWith {
        @(
          [PSCustomObject]@{
            ManufacturerName = [byte[]](65, 65, 67) # "AAC"
            UserFriendlyName = [System.Text.Encoding]::ASCII.GetBytes('Some Model')
            SerialNumberID   = [byte[]](49, 50, 51) # "123"
          }
        )
      }
    }

    It 'Should return one or more monitor objects in an array-like structure' {
      $result = @(Get-LocalMonitor)
      $result | Should -BeOfType [System.Object[]]
    }

    It 'Each returned object should have required properties' {
      $results = @(Get-LocalMonitor)
      foreach ($monitor in $results) {
        $monitor.PSObject.Properties.Name | Should -Contain 'Manufacturer'
        $monitor.PSObject.Properties.Name | Should -Contain 'Model'
        $monitor.PSObject.Properties.Name | Should -Contain 'SerialNumber'
        $monitor.PSObject.Properties.Name | Should -Contain 'AttachedComputer'
      }
    }
  }

  Context 'Edge Case Handling' {

    It "Should handle null UserFriendlyName by setting Model to 'Unknown'" {
      Mock -CommandName Get-CimInstance -MockWith {
        @(
          [PSCustomObject]@{
            ManufacturerName = [byte[]](65, 65, 67)
            UserFriendlyName = $null
            SerialNumberID   = [byte[]](49, 50, 51)
          }
        )
      }

      $monitor = @(Get-LocalMonitor)[0]
      $monitor.Model | Should -Be 'Unknown'
    }

    It "Should set Model to 'Unknown' for 8300 AiO type devices" {
      Mock -CommandName Get-CimInstance -MockWith {
        @(
          [PSCustomObject]@{
            ManufacturerName = [byte[]](65, 65, 67)
            UserFriendlyName = [System.Text.Encoding]::ASCII.GetBytes('HP Elite 8300 AiO')
            SerialNumberID   = [byte[]](49, 50, 51)
          }
        )
      }

      $monitor = @(Get-LocalMonitor)[0]
      $monitor.Model | Should -Be 'Unknown'
    }

    It "Should mark manufacturer as 'Unknown' when code is not in hash table" {
      Mock -CommandName Get-CimInstance -MockWith {
        @(
          [PSCustomObject]@{
            ManufacturerName = [byte[]](90, 90, 90) # "ZZZ"
            UserFriendlyName = [System.Text.Encoding]::ASCII.GetBytes('Generic Monitor')
            SerialNumberID   = [byte[]](49, 50, 51)
          }
        )
      }

      $monitor = @(Get-LocalMonitor)[0]
      $monitor.Manufacturer | Should -Be 'Unknown'
    }

    It "Should set serial number to 'Unknown' if null or invalid" {
      Mock -CommandName Get-CimInstance -MockWith {
        @(
          [PSCustomObject]@{
            ManufacturerName = [byte[]](65, 65, 67)
            UserFriendlyName = [System.Text.Encoding]::ASCII.GetBytes('Some Model')
            SerialNumberID   = $null
          }
        )
      }

      $monitor = @(Get-LocalMonitor)[0]
      $monitor.SerialNumber | Should -Be 'Unknown'
    }
  }
}

