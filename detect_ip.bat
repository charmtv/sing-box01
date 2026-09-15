@echo off
chcp 65001 >nul
echo 🚀 Sing-box IP地址检测工具 (Windows版)
echo ═══════════════════════════════════════════════════════════════

echo 🔍 正在检测服务器IP地址...

:: 尝试使用PowerShell获取IP地址
echo 尝试使用PowerShell获取IP地址...
for /f "tokens=*" %%i in ('powershell -Command "try { (Invoke-WebRequest -Uri 'http://api-ipv4.ip.sb' -TimeoutSec 10).Content.Trim() } catch { '' }"') do set DETECTED_IP=%%i

if "%DETECTED_IP%"=="" (
    echo 尝试使用curl获取IP地址...
    for /f "tokens=*" %%i in ('curl -s --max-time 10 http://api-ipv4.ip.sb 2^>nul') do set DETECTED_IP=%%i
)

if "%DETECTED_IP%"=="" (
    echo 尝试使用wget获取IP地址...
    for /f "tokens=*" %%i in ('wget -qO- --timeout=10 http://api-ipv4.ip.sb 2^>nul') do set DETECTED_IP=%%i
)

if "%DETECTED_IP%"=="" (
    echo 尝试从网络接口获取IP地址...
    for /f "tokens=2 delims=:" %%i in ('ipconfig ^| findstr /C:"IPv4"') do (
        set TEMP_IP=%%i
        set TEMP_IP=!TEMP_IP: =!
        if not "!TEMP_IP!"=="" (
            set DETECTED_IP=!TEMP_IP!
            goto :found_ip
        )
    )
)

:found_ip
if "%DETECTED_IP%"=="" (
    echo ❌ 无法检测到服务器IP地址
    echo.
    echo 💡 建议检查：
    echo    1. 网络连接是否正常
    echo    2. 防火墙是否阻止了外网访问
    echo    3. 服务器是否有公网IP地址
    echo.
    echo 🔧 手动设置示例：
    echo    set SERVER_IP=你的服务器IP地址
    exit /b 1
) else (
    echo ✅ 检测到服务器IP地址: %DETECTED_IP%
    echo.
    echo 📋 检测结果：
    echo    IP地址: %DETECTED_IP%
    echo.
    echo 🔧 使用方法：
    echo    set SERVER_IP=%DETECTED_IP%
    echo    # 或者在Docker运行时使用：
    echo    docker run -e SERVER_IP=%DETECTED_IP% ...
    echo.
    echo 💾 保存到文件...
    echo SERVER_IP=%DETECTED_IP% > detected_ip.conf
    echo ✅ IP地址已保存到 detected_ip.conf
)

echo.
echo 🎉 IP地址检测完成！
pause
