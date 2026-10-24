# Select JDK 21 before invoking Maven Wrapper; fail before compiling if unavailable.
param([Parameter(ValueFromRemainingArguments=$true)][string[]]$MavenArguments = @('clean','verify'))
$ErrorActionPreference = 'Stop'
$project = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$wrapper = Join-Path $project 'mvnw.cmd'
if (-not (Test-Path $wrapper)) { throw 'Missing mvnw.cmd. Generate and commit the Maven Wrapper first.' }
$candidates = @()
if ($env:JAVA_HOME) { $candidates += $env:JAVA_HOME }
$adoptium = Join-Path $env:ProgramFiles 'Eclipse Adoptium'
if (Test-Path $adoptium) {
  $candidates += @(Get-ChildItem -Path $adoptium -Directory -Filter 'jdk-21*' | Sort-Object Name -Descending | Select-Object -ExpandProperty FullName)
}
if ($env:ProgramFiles) {
  $jdkRoot = Join-Path $env:ProgramFiles 'Java'
  if (Test-Path $jdkRoot) {
    $candidates += @(Get-ChildItem -Path $jdkRoot -Directory -Filter 'jdk-21*' | Sort-Object Name -Descending | Select-Object -ExpandProperty FullName)
  }
}
$chosen = $null
foreach ($candidate in ($candidates | Select-Object -Unique)) {
  $java = Join-Path $candidate 'bin\java.exe'
  if (-not (Test-Path $java)) { continue }
  # Read the JDK release metadata: avoids PowerShell 5.1 treating java -version stderr as an exception.
  $releaseFile = Join-Path $candidate 'release'
  if (-not (Test-Path $releaseFile)) { continue }
  $releaseInfo = Get-Content -Path $releaseFile -ErrorAction Stop
  if ($releaseInfo -match '^JAVA_VERSION="21(?:\.|")') { $chosen = $candidate; break }
}
if (-not $chosen) { throw 'JDK 21 not found. Install JDK 21 (Eclipse Adoptium), then rerun this script.' }
$env:JAVA_HOME = $chosen
$env:PATH = (Join-Path $chosen 'bin') + ';' + $env:PATH
Write-Host "Using JAVA_HOME=$env:JAVA_HOME"
Push-Location $project
try {
  & $wrapper -version
  if ($LASTEXITCODE -ne 0) { throw 'Maven Wrapper version check failed.' }
  & $wrapper @MavenArguments
  if ($LASTEXITCODE -ne 0) { throw "Maven failed with exit code $LASTEXITCODE" }
} finally { Pop-Location }
