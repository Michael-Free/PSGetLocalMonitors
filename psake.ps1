Properties {
  $ModuleName = 'PSGetLocalMonitors'
  $InitialVersion = '1.0.0'
  $Author = 'Michael Free'
  $CompanyName = 'Michael Free'
  $Copyright = '(c) 2025 Michael Free. All rights reserved.'
  $Description = 'Module description'
  $ModuleManifest = 'PSModulePipeline.psd1'
  $projectPath = "$PSScriptRoot"
  $PublicFunctions = @()
  $PrivateFunctions = @()
  $moduleContent = @'
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
'@

}

#Task default -Depends InitializeProject, ScaffoldProject, EnforceSyleRules, AnalyzeAndLintScripts, PerformTests, CheckCommentBasedHelp, BumpModuleVersion
Task default -Depends EnforceSyleRules, BuildDocumentation, ValidateManifest

Task InitializeProject {
  Write-Warning 'Initializing project at:'
  $requiredModules = @('PlatyPS', 'Pester', 'PSScriptAnalyzer')
  foreach ($module in $requiredModules) {
    if (-not (Get-Module -ListAvailable -Name $module)) {
      Write-Warning "$($module) not found. Installing..."
      try {
        Install-Module -Name $module -Scope CurrentUser -Force -ErrorAction Stop
      }
      catch {
        Write-Error "Failed to install $($module) : $_"
        continue
      }
    }
    try {
      Import-Module $module -Force -ErrorAction Stop
    }
    catch {
      Write-Error "Failed to import $($module): $_"
    }
  }
  if (Get-Module -Name $ModuleName) {
    Write-Warning "$ModuleName is currently loaded. Removing it from the session..."
    try {
      Remove-Module -Name $ModuleName -Force -ErrorAction Stop
    }
    catch {
      Write-Error "Failed to remove $($ModuleName): $_"
    }
  }
  $modulePath = "$PSScriptRoot\$ModuleName.psm1"
  if (-not (Test-Path -Path $modulePath)) {
    Write-Warning "$modulePath not found. Creating it..."
    try {
      $moduleContent | Out-File -FilePath $modulePath -Encoding UTF8 -Force
      Write-Warning "$moduleFile created successfully."
    }
    catch {
      Write-Error "Failed to create $($modulePath): $_"
    }
  }
  $requiredDirs = @('Tests', 'Public', 'Private', 'Other')
  foreach ($dir in $requiredDirs) {
    $fullPath = Join-Path -Path $PSScriptRoot -ChildPath $dir
    if (-not (Test-Path -Path $fullPath)) {
      New-Item -ItemType Directory -Path $fullPath -Force | Out-Null
    }
    else {
      Write-Verbose "Directory already exists: $fullPath"
    }
  }
}

Task ScaffoldProject {
  Write-Warning 'Scaffolding Module'
  foreach ($funcName in $PublicFunctions) {
    $filename = "$funcName.ps1"
    $filepath = Join-Path -Path (Join-Path $projectPath 'Public') -ChildPath $filename
    if (-not (Test-Path -Path $filepath)) {
      Write-Output "Creating function file: $filepath"
      $FunctionTemplate = @"
function $funcName {
    return '$false'
}
"@
      $FunctionTemplate | Out-File -FilePath $filepath -Encoding UTF8 -Force
    }
    else {
      Write-Verbose "Function file already exists: $filepath"
    }
  }
  if ($PrivateFunctions.Count -gt 0) {
    foreach ($funcName in $PrivateFunctions) {
      $filename = "$funcName.ps1"
      $filepath = Join-Path -Path (Join-Path $projectPath 'Private') -ChildPath $filename
      if (-not (Test-Path -Path $filepath)) {
        Write-Output "Creating private function file: $filepath"
        $FunctionTemplate = @"
function $funcName {
    return '$false'
}
"@
        $FunctionTemplate | Out-File -FilePath $filepath -Encoding UTF8 -Force
      }
      else {
        Write-Verbose "Private function file already exists: $filepath"
      }
    }
  }
  else {
    Write-Verbose 'No private functions defined. Skipping Private directory scaffolding.'
  }
  $allFunctions = @($PublicFunctions + $PrivateFunctions)
  if ($allFunctions.Count -gt 0) {
    foreach ($funcName in $allFunctions) {
      $testFileName = "$funcName.Tests.ps1"
      $testFilePath = Join-Path -Path (Join-Path $projectPath 'Tests') -ChildPath $testFileName
      if (-not (Test-Path -Path $testFilePath)) {
        $TestTemplate = @"
Describe '$funcName' {
    It 'should be implemented' {
        Throw 'Test not implemented for $funcName'
    }
}
"@
        Write-Output "Creating test file: $($testFilePath)"
        $TestTemplate | Out-File -FilePath $testFilePath -Encoding UTF8 -Force
      }
      else {
        Write-Verbose "Test file already exists: $testFilePath"
      }
    }
  }
  else {
    Write-Verbose 'No public or private functions defined — skipping test scaffolding.'
  }
}

Task EnforceSyleRules {
  $ruleset = @{
    IncludeRules = @(
      'PSPlaceOpenBrace',
      'PSPlaceCloseBrace',
      'PSUseConsistentWhitespace',
      'PSUseConsistentIndentation',
      'PSAlignAssignmentStatement',
      'PSUseCorrectCasing',
      'PSAvoidTrailingWhitespace',
      'PSAvoidUsingDoubleQuotesForConstantString'
    )
    Rules        = @{
      PSPlaceOpenBrace                          = @{
        Enable       = $true
        OnSameLine   = $true
        NewLineAfter = $true
      }
      PSPlaceCloseBrace                         = @{
        Enable            = $true
        NoEmptyLineBefore = $false
      }
      PSUseConsistentIndentation                = @{
        Enable          = $true
        Kind            = 'space'
        IndentationSize = 2
      }
      PSUseConsistentWhitespace                 = @{
        Enable        = $true
        CheckOperator = $true
      }
      PSAlignAssignmentStatement                = @{
        Enable = $true
      }
      PSUseCorrectCasing                        = @{
        Enable                    = $true
        EnforceAutomaticVariables = $true
      }
      PSAvoidTrailingWhitespace                 = @{
        Enable = $true
      }
      PSAvoidUsingDoubleQuotesForConstantString = @{
        Enable = $true
      }
    }
  }
  $files = Get-ChildItem -Path $PSScriptRoot -Recurse -Include *.ps1, *.psm1 -File
  if ($files.Count -eq 0) {
    Write-Output 'No PowerShell script files found to format.'
    return
  }
  foreach ($file in $files) {
    Write-Output "Formatting $($file.FullName)..."
    try {
      $originalContent = Get-Content -Raw -Path $file.FullName
      $formattedContent = Invoke-Formatter -ScriptDefinition $originalContent -Settings $ruleset
      if ($formattedContent -ne $originalContent) {
        $formattedContent | Set-Content -Path $file.FullName -Encoding UTF8
        Write-Output "Formatted: $($file.FullName)"
      }
      else {
        Write-Output "Already formatted: $($file.FullName)"
      }
    }
    catch {
      Write-Warning "Failed to format $($file.FullName): $_"
    }
  }
}

Task AnalyzeAndLintScripts {
  $files = Get-ChildItem -Path $PSScriptRoot -Recurse -Include *.ps1, *.psm1 -File |
    Where-Object {
      $_.Name -notlike '*.Tests.ps1' -and
      $_.Name -ne 'psake.ps1'
    }
  if ($files.Count -eq 0) {
    Write-Output 'No script files found to analyze.'
    return
  }
  $issuesFound = $false
  foreach ($file in $files) {
    Write-Output "Analyzing $($file.FullName)..."
    $results = Invoke-ScriptAnalyzer -Path $file.FullName -Severity Warning, Error
    if ($results) {
      $issuesFound = $true
      Write-Warning "Issues found in $($file.FullName):"
      foreach ($issue in $results) {
        Write-Warning "  [$($issue.Severity)] Line $($issue.Line): $($issue.RuleName) - $($issue.Message)"
      }
    }
  }
  if ($issuesFound) {
    throw 'Script analysis found issues. Please fix them before continuing.'
  }
}

Task PerformTests {
  $testsPath = Join-Path $PSScriptRoot 'Tests'
  if (-not (Test-Path $testsPath)) {
    Write-Warning "Tests directory not found at: $testsPath"
    return
  }
  $testFiles = Get-ChildItem -Path $testsPath -Recurse -Filter *.Tests.ps1 -File
  if ($testFiles.Count -eq 0) {
    Write-Warning "No test files found in: $testsPath"
    return
  }
  $hasFailures = $false
  foreach ($testFile in $testFiles) {
    Write-Output "Running Pester test: $($testFile.FullName)"
    $result = Invoke-Pester -Script $testFile.FullName -PassThru -EnableExit
    if ($result.FailedCount -gt 0) {
      Write-Warning "$($result.FailedCount) test(s) failed in: $($testFile.Name)"
      $hasFailures = $true
    }
  }
  if ($hasFailures) {
    throw 'One or more Pester tests failed. See output for details.'
  }
}

Task CheckCommentBasedHelp {
  $missingHelp = @()
  $files = Get-ChildItem -Path $PSScriptRoot -Recurse -Include *.ps1, *.psm1 -File |
    Where-Object {
      $_.Name -notlike '*.Tests.ps1' -and
      $_.Name -ne 'psake.ps1'
    }
  foreach ($file in $files) {
    $lines = Get-Content $file.FullName
    $relativePath = $file.FullName.Replace("$PSScriptRoot\", '')
    $isInPublicOrPrivate = $relativePath -match '^(Public|Private)[\\/]+'
    $inHelpBlock = $false
    $helpBlockEndLine = -10
    $lineNumber = 0
    foreach ($line in $lines) {
      $trimmed = $line.Trim()
      if ($trimmed -like '<#*') {
        $inHelpBlock = $true
      }
      if ($inHelpBlock -and $trimmed -like '*#>') {
        $inHelpBlock = $false
        $helpBlockEndLine = $lineNumber
      }
      if ($trimmed -match '^function\s+([a-zA-Z0-9_-]+)') {
        $funcName = $Matches[1]
        # Function is allowed if it appears within 1 line after the help block ends
        if (($lineNumber - $helpBlockEndLine) -gt 1) {
          Write-Warning "Missing help above function '$funcName' in file: $relativePath"
          $missingHelp += "$($file.FullName):$funcName"
        }
      }
      $lineNumber++
    }
    # For non-function files (outside Public/Private), ensure file-level help exists
    $content = $lines -join "`n"
    $hasFunction = $content -match 'function\s+\w+'
    if (-not $hasFunction -and -not $isInPublicOrPrivate) {
      if ($content -notmatch '^\s*<#') {
        Write-Warning "Missing file-level comment-based help: $relativePath"
        $missingHelp += $file.FullName
      }
    }
  }
  if ($missingHelp.Count -gt 0) {
    Write-Error 'Documentation check failed. Missing comment-based help in the following:'
    $missingHelp | ForEach-Object { Write-Error " - $_" }
    throw "$($missingHelp.Count) file(s)/function(s) missing comment-based help."
  }
}

Task BuildDocumentation {
  $moduleParentFolder = (Get-Item $PSScriptRoot).Parent.FullName
  $moduleFolder = Join-Path $moduleParentFolder $ModuleName
  $docsOutputFolder = Join-Path $moduleFolder 'Docs'
  $helpOutputFolder = Join-Path $moduleFolder 'en-US'
  if (-not ($env:PSModulePath -split ';' | Where-Object { $_ -eq $moduleParentFolder })) {
    $env:PSModulePath += ";$moduleParentFolder"
  }
  if (-not (Test-Path $moduleFolder)) {
    throw "Module folder '$moduleFolder' does not exist."
  }
  if (-not (Test-Path $docsOutputFolder)) {
    New-Item -Path $docsOutputFolder -ItemType Directory | Out-Null
  }
  if (-not (Test-Path $helpOutputFolder)) {
    New-Item -Path $helpOutputFolder -ItemType Directory | Out-Null
  }
  Import-Module -Name $ModuleName -Force -ErrorAction Stop
  $exportedFunctions = (Get-Module -Name $moduleName).ExportedCommands.Keys | Sort-Object
  $existingDocs = Get-ChildItem -Path $docsOutputFolder -Filter '*.md' |
    Select-Object -ExpandProperty BaseName |
    Sort-Object
  if (-not ($exportedFunctions -eq $existingDocs)) {
    Get-ChildItem -Path $docsOutputFolder -Filter '*.md' | Remove-Item -Force
    New-MarkdownHelp -Module $moduleName `
      -OutputFolder $docsOutputFolder `
      -Force `
      -WithModulePage `
      -Encoding ([System.Text.Encoding]::UTF8)
  }
  $aboutMdFile = Join-Path $docsOutputFolder "about_$moduleName.md"
  if (-not (Test-Path $aboutMdFile)) {
    New-MarkdownAboutHelp -OutputFolder $docsOutputFolder -AboutName $moduleName
  }
  if (-not (Test-Path "$helpOutputFolder\$ModuleName-help.xml")) {
    New-ExternalHelp -Path $docsOutputFolder -OutputPath $helpOutputFolder -Force
  }
  Remove-Module -Name $ModuleName -Force
}

Task ValidateManifest {
  if (-not (Test-Path -Path $ModuleManifest)) {
    New-ModuleManifest -Path $ModuleManifest `
      -RootModule "$ModuleName.psm1" `
      -Author $Author `
      -CompanyName $CompanyName `
      -Copyright $Copyright `
      -Description $Description `
      -ModuleVersion $InitialVersion `
      -Tags @() `
      -FunctionsToExport '*' `
      -NestedModules @() `
      -RequiredModules @() `
      -PrivateData @{
      PSData = @{
        LicenseUri   = ''
        ProjectUri   = ''
        IconUri      = ''
        ReleaseNotes = ''
      }
    }
  }
  if (Test-Path -Path $ModuleManifest) {
    $manifestData = Import-PowerShellDataFile -Path $ModuleManifest
    $currentVersionString = $manifestData.ModuleVersion
    $currentVersion = [Version]$currentVersionString
    $build = if ($currentVersion.Build -ge 0) { $currentVersion.Build } else { 0 }
    $newBuild = $build + 1
    $newVersion = New-Object System.Version($currentVersion.Major, $currentVersion.Minor, $newBuild)
    $newVersionString = $newVersion.ToString()
    $manifestText = Get-Content -Path $ModuleManifest -Raw
    $pattern = '(?m)^ModuleVersion\s*=\s*''.*?'''
    $replacement = "ModuleVersion = '$newVersionString'"
    if ($manifestText -match $pattern) {
      $newManifestText = $manifestText -replace $pattern, $replacement
      Set-Content -Path $ModuleManifest -Value $newManifestText -Encoding UTF8
    }
  }
  #Import-Module .\PSModulePipeline.psd1 -Verbose -Force
  #Test-ModuleManifest -Path .\PSModulePipeline.psd1
  #  try {
  #    Test-ModuleManifest -Path .\PSModulePipeline.psd1
  #    Write-Host "Manifest validation passed."
  #}
  #catch {
  #    Write-Error "Manifest validation failed: $_"
  #}
}