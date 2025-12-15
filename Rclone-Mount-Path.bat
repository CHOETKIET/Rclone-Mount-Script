@echo off
setlocal EnableDelayedExpansion

title Rclone Cloud Storage Mount Service (PATH)

echo =====================================================
echo  Initializing Rclone Cloud Storage Mount Service
echo =====================================================

REM -----------------------------
REM CONFIGURATION
REM -----------------------------
set RCLONE_EXE=rclone
REM --- MOUNT_DIR_NAME= (ตั้งชื่อ Drive/Floder)
set MOUNT_DIR_NAME=XX_Drive
REM --- Path ที่ใช้ในการ mount
set MOUNT_POINT=%USERPROFILE%\Desktop\%MOUNT_DIR_NAME%
REM -----------------------------
REM กำหนด Config Cloud Storage
set REMOTE_NAME=XXXX
set REMOTE_PATH=XXXX-XXXXX/XXXX
set LOG_DIR=%USERPROFILE%\scripts
set LOG_FILE=%LOG_DIR%\mount.log
set ACCESS_KEY=XXXXXXXXXXXXXXXXXXXX
set SECRET_KEY=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
set REGION=xx-xxxxxxx-1
REM -----------------------------

REM -----------------------
REM --- ตรวจสอบทรัพยากร
REM -----------------------
if not exist "%LOG_DIR%" mkdir "%LOG_DIR%"

echo [INFO] Cleaning up old processes...
taskkill /F /IM rclone.exe >nul 2>&1
timeout /t 1 >nul

REM --- ลบโฟลเดอร์เก่าทิ้งเพื่อให้ Rclone สร้างขึ้นใหม่เอง ---
if exist "%MOUNT_POINT%" (
    echo [INFO] Removing existing folder to prevent mount conflict...
    rmdir /s /q "%MOUNT_POINT%" >nul 2>&1
)

REM -----------------------
REM Update Rclone Config
REM -----------------------
echo [INFO] Configuring Rclone...
%RCLONE_EXE% config create %REMOTE_NAME% s3 ^
    env_auth=false ^
    access_key_id="%ACCESS_KEY%" ^
    secret_access_key="%SECRET_KEY%" ^
    region="%REGION%" ^
    --non-interactive >nul 2>&1

REM -----------------------
REM --- ชุดคำสั่ง เริ่มการเชื่อมต่อ พร้อมกำหนดโครงสร้าง visual drive/floder
REM -----------------------
echo [INFO] Attempting to mount Cloud Storage to %MOUNT_POINT%...

start "" %RCLONE_EXE% mount "%REMOTE_NAME%:%REMOTE_PATH%" "%MOUNT_POINT%" ^
    --vfs-cache-mode full ^
    --dir-cache-time=5m ^
    --vfs-cache-max-size=1G ^
    --vfs-read-chunk-size=32M ^
    --vfs-read-chunk-size-limit=256M ^
    --buffer-size=64M ^
    --transfers=4 ^
    --use-server-modtime ^
    --no-console ^
    --log-file "%LOG_FILE%" ^
    --log-level INFO

REM -----------------------
REM ตรวจสอบ / รอความพร้อมใช้งาน (SMART VALIDATION)
REM -----------------------
echo Status: Waiting for S3 to initialize...
set /a timeout_counter=0
set max_wait=15

:check_mount
timeout /t 2 >nul
set /a timeout_counter+=2

if exist "%MOUNT_POINT%" (
    goto success_msg
)

if %timeout_counter% geq %max_wait% (
    goto fail_msg
)

echo Still waiting... (%timeout_counter%s)
goto check_mount

:success_msg
echo.
echo =========================================================
echo  SUCCESS: Folder is mounted at Desktop\%MOUNT_DIR_NAME%
echo  (Connect in %timeout_counter% seconds)
echo =========================================================
goto end_script

:fail_msg
echo.
echo [ERROR] Mount failed or took too long.
echo [ERROR!!!] rclone Cannot mount more than one unit.
echo Please check if rclone.exe is still running in Task Manager.
echo Log: %LOG_FILE%
goto end_script

:end_script
pause