$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath $PSScriptRoot
$env:JAVA_HOME = (Get-ChildItem -LiteralPath '.tools/java' -Directory | Select-Object -First 1).FullName
$env:ANDROID_HOME = Join-Path $PSScriptRoot '.tools/android-sdk'
$env:ANDROID_SDK_ROOT = $env:ANDROID_HOME
$env:GRADLE_USER_HOME = Join-Path $PSScriptRoot '.tools/gradle'
if (-not (Test-Path -LiteralPath 'android/key.properties')) {
  python tools/signing_key.py
  if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
}
& '.\.tools\flutter\bin\flutter.bat' build apk --release
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
New-Item -ItemType Directory -Path 'release' -Force | Out-Null
Copy-Item -LiteralPath 'build/app/outputs/flutter-apk/app-release.apk' -Destination 'release/Tizimon-1.2.0.apk' -Force
Write-Output 'APK: release/Tizimon-1.2.0.apk'
