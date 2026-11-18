param(
  [ValidateSet('chrome', 'edge', 'windows', 'web-server')]
  [string]$Device = 'chrome'
)

$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath $PSScriptRoot
$flutter = Join-Path $PSScriptRoot '.tools\flutter\bin\flutter.bat'
if (-not (Test-Path -LiteralPath $flutter)) {
  $command = Get-Command flutter -ErrorAction SilentlyContinue
  if (-not $command) { throw 'Flutter SDK topilmadi. Flutter stable o‘rnating.' }
  $flutter = $command.Source
}
& $flutter pub get
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
if ($Device -eq 'windows') {
  & $flutter run -d windows
} else {
  & $flutter run -d $Device --web-port 8080
}
exit $LASTEXITCODE
