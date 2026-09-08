@echo off
setlocal enabledelayedexpansion

:: Duong dan folder nguon va folder dich
set "SOURCE_DIR=%~dp0"
set "DEST_DIR=%~dp0.."

echo Dang liet ke cac file trong thu muc: %SOURCE_DIR%
echo ------------------------------------------

:: Tao danh sach file (loai bo cac file .bat, .sh va folder)
set count=0
for %%F in (*) do (
    if not "%%~xF"==".bat" (
        if not "%%~xF"==".sh" (
            set /a count+=1
            set "file!count!=%%F"
            echo !count!. %%F
        )
    )
)

if %count%==0 (
    echo Khong tim thay file nao de sao chep.
    pause
    exit /b
)

echo.
set /p "selection=Nhap so thu tu file ban muon sao chep (hoac 'a' de chon tat ca): "

if /i "%selection%"=="a" (
    for /L %%i in (1,1,%count%) do (
        call :copy_file "!file%%i!"
    )
) else (
    if defined file%selection% (
        call :copy_file "!file%selection%!"
    ) else (
        echo Lua chon khong hop le.
    )
)

echo.
set /p "run_push=Sao chep hoan tat. Ban co muon chay push.sh de day len GitHub khong? (y/n): "
if /i "%run_push%"=="y" (
    echo Dang chay push.sh...
    if exist "C:\Program Files\Git\bin\sh.exe" (
        "C:\Program Files\Git\bin\sh.exe" push.sh
    ) else (
        sh push.sh
    )
) else (
    echo Da huy chay push.sh.
)

pause
exit /b

:: Ham thuc hien copy
:copy_file
set "filename=%~1"
if exist "%DEST_DIR%\%filename%" (
    echo.
    echo Phat hien file ton tai: %filename% trong folder cha.
    set /p "confirm=Ban co muon ghi de %filename%? (y/n): "
    if /i "!confirm!"=="y" (
        echo Dang sao luu %filename% thanh %filename%.bak...
        copy /y "%DEST_DIR%\%filename%" "%DEST_DIR%\%filename%.bak" >nul
        echo Dang ghi de %filename%...
        copy /y "%filename%" "%DEST_DIR%\"
    ) else (
        echo Bo qua %filename%.
    )
) else (
    echo Dang copy file moi: %filename%...
    copy "%filename%" "%DEST_DIR%\"
)
goto :eof
