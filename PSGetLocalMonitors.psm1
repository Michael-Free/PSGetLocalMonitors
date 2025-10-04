<#
.SYNOPSIS

Retrieves information about monitors connected to the local computer using EDID data via WMI

.DESCRIPTION
Queries the WMIMonitorID class to extract monitor manufacturer, model, and serial number.
Translates manufacturer codes to friendly names and handles edge cases like null EDID fields

.OUTPUTS
[PSCustomObject] with properties:
    - Manufacturer
    - Model
    - SerialNumber
    - AttachedComputer
#>
foreach ($folder in @('Private', 'Public')) {
  $root = Join-Path -Path $PSScriptRoot -ChildPath $folder
  if (Test-Path -Path $root) {
    Write-Verbose "processing folder $root"
    $files = Get-ChildItem -Path $root -Filter '*.ps1'
    $files | Where-Object { $_.Name -notlike '*.Tests.ps1' } |
      ForEach-Object {
        Write-Verbose "Dot-sourcing $($_.Name)"
        . $_.FullName
      }
  }
}
$exportedFunctions = (Get-ChildItem -Path (Join-Path $PSScriptRoot 'Public') -Filter '*.ps1').BaseName
Export-ModuleMember -Function $exportedFunctions
