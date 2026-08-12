#Requires -RunAsAdministrator
#Set-ExecutionPolicy Bypass -Scope Process -Force
<#
.SYNOPSIS
    Remote Loader - Tai va chay WinMgmt_PS_Toolkit tu GitHub
.DESCRIPTION
    Tu dong tai 4 file script tu GitHub raw ve thu muc tam,
    chay MainMenu.ps1, sau do xoa sach toan bo file da tai.
#>
param(
    [string]$RepoUrl = "https://raw.githubusercontent.com/vynguyenit/WinMgmt_PS_Toolkit/main"
)

$ErrorActionPreference = "Stop"

# Kiem tra Admin
$currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "[!] Yeu cau quyen Administrator!" -ForegroundColor Red
    exit 1
}

# Tao thu muc tam
$tmpDir = Join-Path $env:TEMP "WinMgmt_PS_$(Get-Random -Minimum 1000 -Maximum 9999)"
New-Item -ItemType Directory -Path $tmpDir -Force | Out-Null

Write-Host ""
Write-Host "    ================================================" -ForegroundColor Cyan
Write-Host "         REMOTE LOADER - WinMgmt_PS_Toolkit         " -ForegroundColor Cyan
Write-Host "    ================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "    [*] Thu muc tam: $tmpDir" -ForegroundColor DarkGray
Write-Host "    [*] Nguon: $RepoUrl" -ForegroundColor DarkGray
Write-Host ""

# Danh sach file
$files = @("MainMenu.ps1", "SystemInfo_License.ps1", "Install_Software.ps1", "SystemOptimize_Printer.ps1")

# Tai file
$allOk = $true
try {
    foreach ($file in $files) {
        $url = "$RepoUrl/$file"
        $outFile = Join-Path $tmpDir $file
        Write-Host "    [*] Dang tai: $file ..." -ForegroundColor Yellow -NoNewline
        Invoke-WebRequest -Uri $url -OutFile $outFile -UseBasicParsing -TimeoutSec 30
        $size = (Get-Item $outFile).Length
        Write-Host " OK ($size bytes)" -ForegroundColor Green
    }
} catch {
    Write-Host ""
    Write-Host "    [!] Loi khi tai file: $_" -ForegroundColor Red
    $allOk = $false
}

# Chay Menu chinh
if ($allOk) {
    Write-Host ""
    Write-Host "    [*] Dang khoi chay MainMenu.ps1..." -ForegroundColor Green
    Write-Host "    ================================================" -ForegroundColor Cyan
    Write-Host ""
    & (Join-Path $tmpDir "MainMenu.ps1")
    Write-Host ""
    Write-Host "    ================================================" -ForegroundColor Cyan
    Write-Host "    [*] MainMenu.ps1 da ket thuc." -ForegroundColor Green
}

# Don dep - xoa toan bo thu muc tam
Write-Host ""
Write-Host "    [*] Dang don dep file tam..." -ForegroundColor Yellow
if (Test-Path $tmpDir) {
    Remove-Item -Path $tmpDir -Recurse -Force
    Write-Host "    [*] Da xoa thu muc tam: $tmpDir" -ForegroundColor Green
}
Write-Host ""
Write-Host "    ================================================" -ForegroundColor Cyan
Write-Host "         HOAN TAT - KHONG CON FILE LUU TREN MAY     " -ForegroundColor Cyan
Write-Host "    ================================================" -ForegroundColor Cyan
Write-Host ""

Pause