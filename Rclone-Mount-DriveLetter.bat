@echo off
setlocal EnableDelayedExpansion

title Rclone Cloud Storage Mount Service (DRIVE LETER)

echo =====================================================
echo  Initializing Rclone Cloud Storage Mount Service
echo =====================================================

REM -----------------------
REM CONFIGURATION
REM -----------------------
set RCLONE_EXE=rclone
set MOUNT_POINT=Y:
set REMOTE_NAME=XXXX
set REMOTE_PATH=XXXX-XXXX/XX/XXXX
set LOG_DIR=%USERPROFILE%
set LOG_FILE=%LOG_DIR%\mount.log
set ACCESS_KEY=XXXXXXXXXXXXXXXXXXXXXXX
set SECRET_KEY=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
set REGION=XXXXXXXXX-1

REM -----------------------
REM ตรวจสอบและสร้าง floder log
REM -----------------------
if not exist "%LOG_DIR%" (
    mkdir "%LOG_DIR%" || (
        echo [ERROR] Cannot create log directory!
        pause
        exit /b
    )
)

echo [%date% %time%] --- STARTING SESSION --- >> "%LOG_FILE%"

REM -----------------------
REM ตรวจสอบความพร้อมใช้งานของ Rclone
where %RCLONE_EXE% >nul 2>&1
if errorlevel 1 (
    echo [ERROR] rclone.exe not found in PATH!
    pause
    exit /b
)

REM -----------------------
REM ล้างค้าเก่าและ Config ใหม่
REM -----------------------
echo Status: Updating configuration...
%RCLONE_EXE% config delete %REMOTE_NAME% >nul 2>&1

%RCLONE_EXE% config create %REMOTE_NAME% s3 ^
    env_auth=false ^
    access_key_id="%ACCESS_KEY%" ^
    secret_access_key="%SECRET_KEY%" ^
    region="%REGION%" ^
    --non-interactive >nul 2>&1

REM -----------------------
REM Cleanup sessions rclone เดิม
REM -----------------------
echo Status: Cleaning up previous mounts...
tasklist | findstr /I "rclone.exe" >nul
if %ERRORLEVEL%==0 (
    taskkill /F /IM rclone.exe >nul
    timeout /t 2 >nul
)

net use %MOUNT_POINT% /delete /y >nul 2>&1

REM -----------------------
REM --- ชุดคำสั่ง เริ่มการเชื่อมต่อ พร้อมกำหนดโครงสร้าง visual drive/floder
REM -----------------------
echo Status: Mounting storage to %MOUNT_POINT%...

REM ใช้ 'start' เพื่อให้ rclone รันแยก และสคริปต์ทำบรรทัดถัดไปได้
start "" %RCLONE_EXE% mount "%REMOTE_NAME%:%REMOTE_PATH%" %MOUNT_POINT% ^
    --vfs-cache-mode full ^
    --buffer-size 64M ^
    --vfs-cache-max-size 1G ^
    --dir-cache-time 30m ^
    --network-mode ^
    --no-modtime ^
    --log-file "%LOG_FILE%" ^
    --log-level INFO

REM -----------------------
REM ตรวจสอบ / รอความพร้อมใช้งาน (VALIDATION)
REM -----------------------
echo Status: Verifying connection...
set retry=0

:wait_loop
timeout /t 2 >nul
set /a retry+=1

REM ตรวจสอบสถานะไดรฟ์โดยตรงด้วยคำสั่ง vol
vol %MOUNT_POINT% >nul 2>&1
if !errorlevel! equ 0 goto success_msg

if %retry% geq 10 (
    echo [ERROR] System timeout: Drive failed to mount.
    echo Please check logs: %LOG_FILE%
    pause
    exit /b 1
)
goto wait_loop

:success_msg
echo.
echo =========================================================
echo  SUCCESS: Drive %MOUNT_POINT% is now ready for use.
echo  IMPORTANT: PLEASE DO NOT CLOSE THIS WINDOW.
echo  Closing this window will disconnect the network drive.
echo =========================================================
echo.
echo Session started at: %DATE% %TIME%
echo.

REM ป้องกันหน้าต่างปิดเอง
pause
endlocal