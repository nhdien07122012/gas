@echo off
title Build APK VNPost Gas Manager
echo ========================================================
echo        DANG BUILD APK VNPOST GAS MANAGER...
echo ========================================================

set "JAVA_HOME=%USERPROFILE%\scoop\apps\temurin21-jdk\current"
set "ANDROID_HOME=%USERPROFILE%\scoop\apps\android-clt\current"
set "ANDROID_SDK_ROOT=%USERPROFILE%\scoop\apps\android-clt\current"
set "PATH=%JAVA_HOME%\bin;%USERPROFILE%\scoop\shims;%ANDROID_HOME%\cmdline-tools\latest\bin;%ANDROID_HOME%\platform-tools;%PATH%"

echo 1. Dong bo code HTML/CSS/JS vao thu muc www...
if not exist "www" mkdir "www"
if not exist "www\assets" mkdir "www\assets"
xcopy /Y /I *.html www\ >nul
xcopy /Y /I *.png www\ >nul
xcopy /E /Y /I assets www\assets\ >nul

echo 2. Dong bo sang Android project (Capacitor Sync)...
call npx cap sync android

echo 3. Bien dich APK bang Gradle...
cd android
call gradlew.bat assembleDebug
cd ..

if exist "android\app\build\outputs\apk\debug\app-debug.apk" (
    copy /Y "android\app\build\outputs\apk\debug\app-debug.apk" "VNPost-Gas-Manager.apk" >nul
    echo.
    echo ========================================================
    echo  THANH CONG! File APK da duoc tao tai:
    echo  %~dp0VNPost-Gas-Manager.apk
    echo ========================================================
) else (
    echo.
    echo [LOI] Khong tim thay file APK sau khi build.
)

pause
