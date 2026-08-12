#Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Menu chinh - He thong quan ly Windows (Parent Menu)
.DESCRIPTION
    Menu chinh goi 3 nhom script con:
      - Nhom 1: Thong tin he thong & Ban quyen
      - Nhom 2: Cai dat phan mem & Cong cu van phong
      - Nhom 3: Toi uu he thong, Xu ly loi & Quan ly may in
.NOTES
    Chay voi quyen Administrator. Cac file con phai nam cung thu muc.
#>

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
if ([string]::IsNullOrWhiteSpace($scriptDir)) {
    $scriptDir = Get-Location
}

function Show-MainMenu {
    Clear-Host
    Write-Host ""
    Write-Host "    ================================================" -ForegroundColor Cyan
    Write-Host "         HE THONG QUAN LY WINDOWS - MENU CHINH      " -ForegroundColor Cyan
    Write-Host "    ================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "         [1]  Nhom 1: Thong tin he thong & Ban quyen" -ForegroundColor White
    Write-Host "         [2]  Nhom 2: Cai dat phan mem & Cong cu van phong" -ForegroundColor White
    Write-Host "         [3]  Nhom 3: Toi uu he thong, Xu ly loi & Quan ly may in" -ForegroundColor White
    Write-Host ""
    Write-Host "         [0]  Thoat" -ForegroundColor Red
    Write-Host ""
    Write-Host "    ================================================" -ForegroundColor Cyan
    Write-Host "         Thu muc script: $scriptDir" -ForegroundColor DarkGray
    Write-Host "    ================================================" -ForegroundColor Cyan
    Write-Host ""
}

function Invoke-ChildScript {
    param(
        [string]$ScriptName,
        [string]$DisplayName
    )
    
    $scriptPath = Join-Path $scriptDir $ScriptName
    
    if (-not (Test-Path $scriptPath)) {
        Write-Host ""
        Write-Host "    [!] Khong tim thay file: $ScriptName" -ForegroundColor Red
        Write-Host "    [!] Vui long dam bao file nam trong thu muc: $scriptDir" -ForegroundColor Yellow
        Write-Host ""
        Pause
        return
    }
    
    Write-Host ""
    Write-Host "    >> Dang khoi chay: $DisplayName" -ForegroundColor Green
    Write-Host "    >> Duong dan: $scriptPath" -ForegroundColor DarkGray
    Write-Host ""
    Start-Sleep -Milliseconds 500
    
    & $scriptPath
    
    Write-Host ""
    Write-Host "    << Da hoan tat: $DisplayName" -ForegroundColor Green
    Write-Host "    << Quay ve Menu chinh..." -ForegroundColor Cyan
    Write-Host ""
    Pause
}

function Test-AdminRights {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# ==================== KIEM TRA QUYEN ADMIN ====================
if (-not (Test-AdminRights)) {
    Clear-Host
    Write-Host ""
    Write-Host "    ================================================" -ForegroundColor Red
    Write-Host "         CAN QUYEN ADMINISTRATOR!                     " -ForegroundColor Red
    Write-Host "    ================================================" -ForegroundColor Red
    Write-Host ""
    Write-Host "    Script nay yeu cau quyen Administrator de hoat dong." -ForegroundColor Yellow
    Write-Host "    Vui long chay lai voi quyen Administrator:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "        1. Nhan chuot phai vao file MainMenu.ps1" -ForegroundColor White
    Write-Host "        2. Chon 'Run with PowerShell'" -ForegroundColor White
    Write-Host "        3. Hoac mo PowerShell voi quyen Admin va chay:" -ForegroundColor White
    Write-Host "           .\MainMenu.ps1" -ForegroundColor Cyan
    Write-Host ""
    Pause
    exit 1
}

# ==================== KIEM TRA CAC FILE CON ====================
$requiredFiles = @(
    "SystemInfo_License.ps1",
    "Install_Software.ps1",
    "SystemOptimize_Printer.ps1"
)

$missingFiles = @()
foreach ($file in $requiredFiles) {
    $path = Join-Path $scriptDir $file
    if (-not (Test-Path $path)) {
        $missingFiles += $file
    }
}

if ($missingFiles.Count -gt 0) {
    Clear-Host
    Write-Host ""
    Write-Host "    ================================================" -ForegroundColor Red
    Write-Host "         THIEU FILE SCRIPT CON!                       " -ForegroundColor Red
    Write-Host "    ================================================" -ForegroundColor Red
    Write-Host ""
    Write-Host "    Cac file sau khong tim thay trong thu muc:" -ForegroundColor Yellow
    Write-Host "    $scriptDir" -ForegroundColor DarkGray
    Write-Host ""
    foreach ($f in $missingFiles) {
        Write-Host "        - $f" -ForegroundColor Red
    }
    Write-Host ""
    Write-Host "    Vui long dam bao tat ca 3 file script con nam cung thu muc" -ForegroundColor Yellow
    Write-Host "    voi file MainMenu.ps1 nay." -ForegroundColor Yellow
    Write-Host ""
    Pause
    exit 1
}

# ==================== VONG LAP MENU CHINH ====================
do {
    Show-MainMenu
    $choice = Read-Host "    Nhap lua chon cua ban"
    
    switch ($choice) {
        "1" {
            Invoke-ChildScript -ScriptName "SystemInfo_License.ps1" -DisplayName "Nhom 1: Thong tin he thong & Ban quyen"
        }
        "2" {
            Invoke-ChildScript -ScriptName "Install_Software.ps1" -DisplayName "Nhom 2: Cai dat phan mem & Cong cu van phong"
        }
        "3" {
            Invoke-ChildScript -ScriptName "SystemOptimize_Printer.ps1" -DisplayName "Nhom 3: Toi uu he thong, Xu ly loi & Quan ly may in"
        }
        "0" {
            Clear-Host
            Write-Host ""
            Write-Host "    ================================================" -ForegroundColor Green
            Write-Host "         CAM ON BAN DA SU DUNG HE THONG!            " -ForegroundColor Green
            Write-Host "    ================================================" -ForegroundColor Green
            Write-Host ""
            Start-Sleep -Seconds 1
            exit 0
        }
        default {
            Write-Host ""
            Write-Host "    [!] Lua chon khong hop le. Vui long chon lai." -ForegroundColor Red
            Start-Sleep -Seconds 1
        }
    }
} while ($true)
