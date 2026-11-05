#!/usr/bin/env pwsh
# setup-android-sdk.ps1
# Chạy script này SAU KHI Android Studio đã cài xong và mở lần đầu
# Dùng sdkmanager để cài Android SDK components không cần GUI

$env:PATH = "$env:USERPROFILE\scoop\shims;$env:USERPROFILE\scoop\apps\temurin17-jdk\current\bin;$env:PATH"
$env:JAVA_HOME = "$env:USERPROFILE\scoop\apps\temurin17-jdk\current"
$env:ANDROID_HOME = "$env:LOCALAPPDATA\Android\Sdk"

$sdkManager = "$env:ANDROID_HOME\cmdline-tools\latest\bin\sdkmanager.bat"

if (-not (Test-Path $sdkManager)) {
    Write-Host "⚠️  sdkmanager chưa có. Hãy mở Android Studio lần đầu để nó tự cài SDK." -ForegroundColor Yellow
    Write-Host "    Sau đó chạy lại script này." -ForegroundColor Yellow
    exit 1
}

Write-Host "📦 Cài Android SDK components..." -ForegroundColor Cyan

# Accept licenses
echo "y" | & $sdkManager --licenses 2>&1 | Out-Null

# Install required components
& $sdkManager "platform-tools" "platforms;android-34" "build-tools;34.0.0" 2>&1
& $sdkManager "emulator" "system-images;android-34;google_apis;x86_64" 2>&1

Write-Host ""
Write-Host "✅ Android SDK components cài xong!" -ForegroundColor Green
Write-Host "   Tiếp tục chạy: npx cap add android" -ForegroundColor Yellow
