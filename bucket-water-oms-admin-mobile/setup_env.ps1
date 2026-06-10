# Flutter环境配置脚本
# 以管理员权限运行此脚本

Write-Host "=== Flutter 环境变量配置 ===" -ForegroundColor Cyan
Write-Host ""

# Flutter bin目录
$flutterBinPath = "C:\Users\Wishtohear\AppData\Local\Flutter\bin"

# 检查Flutter是否存在
if (-not (Test-Path $flutterBinPath)) {
    Write-Host "✗ Flutter SDK未找到" -ForegroundColor Red
    Write-Host "请先安装Flutter SDK" -ForegroundColor Yellow
    exit 1
}

# 获取当前用户Path
$currentUserPath = [System.Environment]::GetEnvironmentVariable("Path", "User")

# 检查是否已添加
if ($currentUserPath -like "*$flutterBinPath*") {
    Write-Host "✓ Flutter已添加到PATH" -ForegroundColor Green
} else {
    # 添加到Path
    Write-Host "正在添加Flutter到环境变量..." -ForegroundColor Yellow
    $newPath = "$currentUserPath;$flutterBinPath"
    [System.Environment]::SetEnvironmentVariable("Path", $newPath, "User")
    Write-Host "✓ Flutter已添加到PATH" -ForegroundColor Green
}

Write-Host ""
Write-Host "=== 刷新环境变量 ===" -ForegroundColor Cyan

# 刷新当前会话的Path
$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")

Write-Host ""
Write-Host "=== 验证Flutter安装 ===" -ForegroundColor Cyan
Write-Host ""

# 等待环境变量生效
Start-Sleep -Seconds 2

# 使用cmd调用flutter（更可靠）
try {
    $flutterVersion = & cmd /c "flutter --version" 2>&1
    Write-Host "✓ Flutter版本：" -ForegroundColor Green
    Write-Host $flutterVersion -ForegroundColor White
} catch {
    Write-Host "✗ Flutter验证失败" -ForegroundColor Red
    Write-Host "请关闭此窗口，重新打开PowerShell后再次运行flutter --version" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "=== 下一步操作 ===" -ForegroundColor Cyan
Write-Host "1. 关闭此PowerShell窗口" -ForegroundColor White
Write-Host "2. 重新打开PowerShell" -ForegroundColor White
Write-Host "3. 进入项目目录并运行：" -ForegroundColor White
Write-Host "   cd 'c:\Users\Wishtohear\Documents\bucket-water-oms\bucket-water-oms-admin-mobile'" -ForegroundColor Yellow
Write-Host "   flutter pub get" -ForegroundColor Yellow
Write-Host "   flutter run" -ForegroundColor Yellow

Write-Host ""
Write-Host "按任意键退出..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
