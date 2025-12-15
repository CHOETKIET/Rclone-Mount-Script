# Rclone-Mount-Script
Script Batch สำหรับเชื่อมต่อ / Mount Sharedata, Cloud storage เช่น Google Drive ไปยัง Windows ด้วย Rclone และ Winfsp สามารถเชื่อมต่อทั้งแบบไดรฟ์ (Drive Letter) และแบบโฟลเดอร์ (Path)

---------------------------------------------------------------------

# ชื่อไฟล์, การทำงาน
- mount_rclone_driveletter.bat, Mount ในรูปแบบ Drive Letter (เช่น A:)
- mount_rclone_path.bat, Mount ในรูปแบบ Path หรือ Floder (เช่น C:\User\Desktop, %USERPROFILE%\Desktop\%MOUNT_DIR_NAME%)

# สิ่งที่ต้องมีก่อนเริ่ม
1.ติดตั้ง Rclone สำหรับ Windows
2.ติดตั้ง WinFsp (จำเป็นสำหรับการ Mount บน Windows)

# วิธีใช้งาน
1.ดาวน์โหลด/คัดลอก สคริปต์ที่ต้องการไปไว้ในเครื่อง
2.แก้ไข (Edit) ไฟล์ .bat เพื่อตั้งค่าตัวแปรของคุณ เช่น
REM -----------------------------
set RCLONE_EXE=rclone
set MOUNT_DIR_NAME=XX_Drive
set MOUNT_POINT=%USERPROFILE%\Desktop\%MOUNT_DIR_NAME% (--- PATH ที่ใช้ในการ Mount ---)
REM -----------------------------
set REMOTE_NAME=XXXX ( ชื่อ ที่ใช้เรียกการเชื่อมต่อกับ Cloud นั้นๆ)
set REMOTE_PATH=XXXX-XXXXX/XXXX (PATH ที่ต้องการ Mount)
set LOG_DIR=%USERPROFILE%\scripts (พื้นที่เก็บ Log)
set LOG_FILE=%LOG_DIR%\mount.log
set ACCESS_KEY=XXXXXXXXXXXXXXXXXXXX (Key จาก Cloud storage )
set SECRET_KEY=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX (Key จาก Cloud storage )
set REGION=xx-xxxxxxx-1 (พื้นที่ของ Cloud ที่ใช้งาน)
REM -----------------------------

---------------------------------------------------------------------


