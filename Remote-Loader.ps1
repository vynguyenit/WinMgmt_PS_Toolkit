#Requires -RunAsAdministrator
#Set-ExecutionPolicy Bypass -Scope Process -Force
<#
.SYNOPSIS
    Remote Loader - Tai va chay WinMgmt_PS_Toolkit tu GitHub
.DESCRIPTION
    Tu dong tai 4 file script tu GitHub raw ve thu muc AppData\Local,
    chay MainMenu.ps1, sau do xoa sach toan bo file da tai.
.PARAMETER RepoUrl
    URL raw cua GitHub repo (mac dinh: https://raw.githubusercontent.com/vynguyenit/WinMgmt_PS_Toolkit/main)
.EXAMPLE
    .\Remote-Loader.ps1
    .\Remote-Loader.ps1 -RepoUrl "https://raw.githubusercontent.com/vynguyenit/WinMgmt_PS_Toolkit/main"
.NOTES
    Yeu cau quyen Administrator. Can ket noi Internet.
    File duoc luu tai: C:\Users\<username>\AppData\Local\WinMgmt_PS_<random>
#>
param(
    [string]$RepoUrl = "https://raw.githubusercontent.com/vynguyenit/WinMgmt_PS_Toolkit/main"
)

$ErrorActionPreference = "Stop"

# ==================== KIEM TRA ADMIN ====================
$currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host ""
    Write-Host "    [!] YEU CAU QUYEN ADMINISTRATOR!" -ForegroundColor Red
    Write-Host "    Vui long chay lai PowerShell voi quyen Administrator." -ForegroundColor Yellow
    Write-Host ""
    exit 1
}

# ==================== TAO THU MUC TAM ====================
# Su dung AppData\Local thay vi TEMP de de kiem soat va bao mat hon
$tmpDir = Join-Path $env:LOCALAPPDATA "WinMgmt_PS_$(Get-Random -Minimum 1000 -Maximum 9999)"
New-Item -ItemType Directory -Path $tmpDir -Force | Out-Null

Write-Host ""
Write-Host "    ================================================" -ForegroundColor Cyan
Write-Host "         REMOTE LOADER - WinMgmt_PS_Toolkit         " -ForegroundColor Cyan
Write-Host "    ================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "    [*] Thu muc luu tru: $tmpDir" -ForegroundColor DarkGray
Write-Host "    [*] Nguon: $RepoUrl" -ForegroundColor DarkGray
Write-Host ""

# ==================== DANH SACH FILE ====================
$files = @(
    "MainMenu.ps1",
    "SystemInfo_License.ps1",
    "Install_Software.ps1",
    "SystemOptimize_Printer.ps1"
)

# ==================== TAI FILE ====================
$allOk = $true
try {
    foreach ($file in $files) {
        $url = "$RepoUrl/$file"
        $outFile = Join-Path $tmpDir $file
        Write-Host "    [*] Dang tai: $file ..." -ForegroundColor Yellow -NoNewline
        
        Invoke-WebRequest -Uri $url -OutFile $outFile -UseBasicParsing -TimeoutSec 30
        
        if (Test-Path $outFile) {
            $size = (Get-Item $outFile).Length
            Write-Host " OK ($size bytes)" -ForegroundColor Green
        } else {
            Write-Host " LOI" -ForegroundColor Red
            $allOk = $false
        }
    }
} catch {
    Write-Host ""
    Write-Host "    [!] Loi khi tai file: $_" -ForegroundColor Red
    Write-Host "    [!] Kiem tra lai URL hoac ket noi mang." -ForegroundColor Yellow
    $allOk = $false
}

# ==================== CHAY MENU CHINH ====================
if ($allOk) {
    Write-Host ""
    Write-Host "    [*] Dang khoi chay MainMenu.ps1..." -ForegroundColor Green
    Write-Host "    ================================================" -ForegroundColor Cyan
    Write-Host ""
    
    & (Join-Path $tmpDir "MainMenu.ps1")
    
    Write-Host ""
    Write-Host "    ================================================" -ForegroundColor Cyan
    Write-Host "    [*] MainMenu.ps1 da ket thuc." -ForegroundColor Green
} else {
    Write-Host ""
    Write-Host "    [!] Khong the chay vi tai file that bai." -ForegroundColor Red
}

# ==================== DON DEP - XOA FILE TAM ====================
Write-Host ""
Write-Host "    [*] Dang don dep file da tai..." -ForegroundColor Yellow

if (Test-Path $tmpDir) {
    try {
        Remove-Item -Path $tmpDir -Recurse -Force -ErrorAction Stop
        Write-Host "    [*] Da xoa thu muc: $tmpDir" -ForegroundColor Green
    } catch {
        Write-Host "    [!] Khong the xoa thu muc: $_" -ForegroundColor Red
        Write-Host "    [!] Vui long xoa thu cong: $tmpDir" -ForegroundColor Yellow
    }
} else {
    Write-Host "    [*] Thu muc da duoc xoa truoc do." -ForegroundColor Gray
}

Write-Host ""
Write-Host "    ================================================" -ForegroundColor Cyan
Write-Host "         HOAN TAT - KHONG CON FILE LUU TREN MAY     " -ForegroundColor Cyan
Write-Host "    ================================================" -ForegroundColor Cyan
Write-Host ""

Pause