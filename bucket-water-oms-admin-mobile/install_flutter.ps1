# Flutter SDK 安装脚本
# 请以管理员权限运行此脚本

Write-Host "=== Flutter SDK 安装脚本 ===" -ForegroundColor Cyan
Write-Host ""

# 检查Flutter是否已安装
if (Get-Command flutter -errorAction SilentlyContinue) {
    Write-Host "✓ Flutter 已安装" -ForegroundColor Green
    flutter --version
    exit 0
}

# Flutter SDK 安装路径
$flutterInstallPath = "$env:USERPROFILE\AppData\Local\Flutter"
$flutterZipPath = "$env:USERPROFILE\Downloads\flutter_windows_stable.zip"

# 1. 创建安装目录
Write-Host "[1/6] 创建安装目录..." -ForegroundColor Yellow
if (-not (Test-Path $flutterInstallPath)) {
    New-Item -ItemType Directory -Path $flutterInstallPath -Force | Out-Null
    Write-Host "  ✓ 创建目录: $flutterInstallPath" -ForegroundColor Green
} else {
    Write-Host "  ✓ 目录已存在: $flutterInstallPath" -ForegroundColor Green
}

# 2. 检查是否已下载
if (-not (Test-Path $flutterZipPath)) {
    Write-Host "[2/6] 下载 Flutter SDK (约550MB)..." -ForegroundColor Yellow
    Write-Host "  提示: 如果下载失败，请手动下载: https://flutter.dev/docs/get-started/install/windows" -ForegroundColor Cyan
    
    try {
        # 使用PowerShell下载（可能有进度条）
        $ProgressPreference = 'Continue'
        Invoke-WebRequest -Uri "https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.24.0-stable.zip" `
                          -OutFile $flutterZipPath `
                          -TimeoutSec 600
        Write-Host "  ✓ 下载完成" -ForegroundColor Green
    } catch {
        Write-Host "  ✗ 下载失败: $_" -ForegroundColor Red
        Write-Host ""
        Write-Host "请手动下载Flutter SDK:" -ForegroundColor Yellow
        Write-Host "1. 访问 https://flutter.dev/docs/get-started/install/windows" -ForegroundColor Cyan
        Write-Host "2. 点击 'Download Flutter SDK'" -ForegroundColor Cyan
        Write-Host "3. 解压到 $flutterInstallPath" -ForegroundColor Cyan
        Write-Host "4. 继续步骤3" -ForegroundColor Cyan
        exit 1
    }
} else {
    Write-Host "[2/6] 找到已下载的文件" -ForegroundColor Yellow
}

# 3. 解压Flutter SDK
Write-Host "[3/6] 解压 Flutter SDK..." -ForegroundColor Yellow
try {
    # 使用PowerShell解压
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::ExtractToDirectory($flutterZipPath, $flutterInstallPath)
    
    # 将flutter目录下的内容移动到安装路径
    $flutterExtractedPath = Join-Path $flutterInstallPath "flutter"
    if (Test-Path $flutterExtractedPath) {
        Get-ChildItem -Path $flutterExtractedPath | Move-Item -Destination $flutterInstallPath -Force
        Remove-Item $flutterExtractedPath
    }
    
    Write-Host "  ✓ 解压完成" -ForegroundColor Green
} catch {
    Write-Host "  ✗ 解压失败: $_" -ForegroundColor Red
    exit 1
}

# 4. 配置环境变量
Write-Host "[4/6] 配置环境变量..." -ForegroundColor Yellow
$flutterBinPath = Join-Path $flutterInstallPath "bin"
$currentPath = [System.Environment]::GetEnvironmentVariable("Path", "User")

if ($currentPath -notlike "*$flutterBinPath*") {
    [System.Environment]::SetEnvironmentVariable(
        "Path", 
        "$currentPath;$flutterBinPath", 
        "User"
    )
    Write-Host "  ✓ 添加到 PATH: $flutterBinPath" -ForegroundColor Green
} else {
    Write-Host "  ✓ PATH 已配置" -ForegroundColor Green
}

# 5. 刷新环境变量
Write-Host "[5/6] 刷新环境变量..." -ForegroundColor Yellow
$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
Write-Host "  ✓ 环境变量已刷新" -ForegroundColor Green

# 6. 验证安装
Write-Host "[6/6] 验证安装..." -ForegroundColor Yellow
Start-Sleep -Seconds 2

try {
    $flutterVersion = & flutter --version 2>&1
    Write-Host ""
    Write-Host "=== Flutter 安装成功! ===" -ForegroundColor Green
    Write-Host ""
    Write-Host $flutterVersion
    Write-Host ""
    Write-Host "下一步操作:" -ForegroundColor Cyan
    Write-Host "1. 关闭当前PowerShell窗口" -ForegroundColor White
    Write-Host "2. 打开新的PowerShell窗口" -ForegroundColor White
    Write-Host "3. 运行以下命令检查Flutter状态:" -ForegroundColor White
    Write-Host "   flutter doctor" -ForegroundColor Yellow
    Write-Host "4. 进入项目目录并运行应用:" -ForegroundColor White
    Write-Host "   cd $PSScriptRoot" -ForegroundColor Yellow
    Write-Host "   flutter pub get" -ForegroundColor Yellow
    Write-Host "   flutter run" -ForegroundColor Yellow
} catch {
    Write-Host "  ✗ 验证失败，请重新打开PowerShell窗口后重试" -ForegroundColor Red
    Write-Host "  或者手动运行: flutter doctor" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "按任意键退出..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
