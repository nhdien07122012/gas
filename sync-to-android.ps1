#!/usr/bin/env pwsh
# sync-to-android.ps1 — Chạy script này mỗi khi bạn sửa HTML/JS/CSS
# Usage: .\sync-to-android.ps1

$root = "C:\Users\NGUYENDIEN\Documents\VSCODE\gas"
Set-Location $root

Write-Host "🔄 Copying web files to www/..." -ForegroundColor Cyan

# Tạo thư mục nếu chưa có
New-Item -ItemType Directory -Force -Path "www" | Out-Null
New-Item -ItemType Directory -Force -Path "www\assets" | Out-Null

# Copy HTML files
Get-ChildItem -Path $root -Filter "*.html" | Copy-Item -Destination "www\" -Force
Write-Host "  ✅ HTML files copied"

# Copy images
Get-ChildItem -Path $root -Filter "*.png" | Copy-Item -Destination "www\" -Force
Write-Host "  ✅ Image files copied"

# Copy assets
if (Test-Path "assets") {
    Copy-Item "assets\*" "www\assets\" -Force -Recurse
    Write-Host "  ✅ Assets copied"
}

Write-Host ""
Write-Host "🔄 Syncing to Android project..." -ForegroundColor Cyan
npx cap sync android

Write-Host ""
Write-Host "✅ Done! Bây giờ vào Android Studio → Build → Build APK(s)" -ForegroundColor Green
Write-Host "   Hoặc chạy: npx cap open android" -ForegroundColor Yellow
