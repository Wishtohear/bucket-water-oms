# Flutter命令包装脚本
# 自动使用完整路径调用flutter

$flutterPath = "C:\Users\Wishtohear\AppData\Local\Flutter\bin\flutter.bat"

# 检查Flutter是否存在
if (-not (Test-Path $flutterPath)) {
    Write-Host "Flutter未找到，请先运行 setup_env.ps1 配置环境变量" -ForegroundColor Red
    exit 1
}

# 临时添加Flutter到Path（仅当前会话）
$env:Path = "C:\Users\Wishtohear\AppData\Local\Flutter\bin;" + $env:Path

# 执行flutter命令
& cmd /c "flutter.bat $args"
