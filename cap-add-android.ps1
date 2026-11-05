#!/usr/bin/env pwsh
# cap-add-android.ps1
# Chạy script này sau khi Android Studio đã cài và SDK đã sẵn sàng

$root = "C:\Users\NGUYENDIEN\Documents\VSCODE\gas"
Set-Location $root

# Load env vars
$env:PATH = "$env:USERPROFILE\scoop\shims;$env:USERPROFILE\scoop\apps\temurin17-jdk\current\bin;$env:LOCALAPPDATA\Android\Sdk\platform-tools;$env:PATH"
$env:JAVA_HOME = "$env:USERPROFILE\scoop\apps\temurin17-jdk\current"
$env:ANDROID_HOME = "$env:LOCALAPPDATA\Android\Sdk"
$env:ANDROID_SDK_ROOT = "$env:LOCALAPPDATA\Android\Sdk"

Write-Host "🔄 Thêm platform Android vào Capacitor..." -ForegroundColor Cyan
npx cap add android 2>&1

Write-Host ""
Write-Host "🔄 Sync web files vào Android project..." -ForegroundColor Cyan
npx cap sync android 2>&1

Write-Host ""
Write-Host "🚀 Mở Android Studio..." -ForegroundColor Cyan
npx cap open android 2>&1

Write-Host ""
Write-Host "✅ Xong! Trong Android Studio:" -ForegroundColor Green
Write-Host "   Build → Build Bundle(s) / APK(s) → Build APK(s)" -ForegroundColor Yellow
