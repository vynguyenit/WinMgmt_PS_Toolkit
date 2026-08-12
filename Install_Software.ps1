#Requires -RunAsAdministrator
#Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
<#
.SYNOPSIS
    Nhom 2: Cai dat phan mem & Cong cu van phong
.DESCRIPTION
    Tu dong hoa cai dat cac phan mem van phong pho bien thong qua winget hoac silent install
#>

function Show-Header {
    param([string]$Title)
    Clear-Host
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  $Title" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
}

function Test-Admin {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Test-Winget {
    try {
        $winget = Get-Command winget -ErrorAction SilentlyContinue
        if ($winget) {
            $ver = winget --version 2>$null
            Write-Host "Winget da duoc cai dat: $ver" -ForegroundColor Green
            return $true
        }
    } catch {}
    Write-Host "Winget chua duoc cai dat hoac khong tim thay!" -ForegroundColor Red
    return $false
}

function Install-WingetIfMissing {
    Show-Header "KIEM TRA WINGET"
    
    if (Test-Winget) { return $true }
    
    Write-Host "Dang cai dat App Installer (chua winget)..." -ForegroundColor Yellow
    try {
        $url = "https://aka.ms/getwinget"
        $output = "$env:TEMP\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
        Invoke-WebRequest -Uri $url -OutFile $output -UseBasicParsing
        Add-AppxPackage -Path $output
        Write-Host "Da cai dat winget thanh cong!" -ForegroundColor Green
        return $true
    } catch {
        Write-Host "Khong the cai dat winget tu dong. Vui long cai dat thu cong." -ForegroundColor Red
        Write-Host "Link: https://github.com/microsoft/winget-cli/releases" -ForegroundColor Yellow
        return $false
    }
}

function Install-SoftwareWinget {
    param([string]$PackageId, [string]$SoftwareName)
    
    Write-Host "Dang cai dat $SoftwareName ($PackageId)..." -ForegroundColor Yellow
    try {
        winget install --id $PackageId --accept-source-agreements --accept-package-agreements --silent
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  -> Da cai dat $SoftwareName thanh cong!" -ForegroundColor Green
        } else {
            Write-Host "  -> Co loi khi cai dat $SoftwareName (ma: $LASTEXITCODE)" -ForegroundColor Red
        }
    } catch {
        Write-Host "  -> Loi: $_" -ForegroundColor Red
    }
}

function Install-Chocolatey {
    Show-Header "CAI DAT CHOCOLATEY"
    
    if (Get-Command choco -ErrorAction SilentlyContinue) {
        Write-Host "Chocolatey da duoc cai dat!" -ForegroundColor Green
        return $true
    }
    
    Write-Host "Dang cai dat Chocolatey..." -ForegroundColor Yellow
    try {
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
        Write-Host "Da cai dat Chocolatey thanh cong!" -ForegroundColor Green
        return $true
    } catch {
        Write-Host "Loi cai dat Chocolatey: $_" -ForegroundColor Red
        return $false
    }
}

function Install-SingleSoftware {
    Show-Header "CAI DAT DON LE"
    
    $softwareList = @(
        @{Id="Microsoft.Office"; Name="Microsoft Office"; Winget="Microsoft.Office"; Choco="office365business"},
        @{Id="Google.Chrome"; Name="Google Chrome"; Winget="Google.Chrome"; Choco="googlechrome"},
        @{Id="Mozilla.Firefox"; Name="Mozilla Firefox"; Winget="Mozilla.Firefox"; Choco="firefox"},
        @{Id="Adobe.Acrobat.Reader.64-bit"; Name="Adobe Acrobat Reader"; Winget="Adobe.Acrobat.Reader.64-bit"; Choco="adobereader"},
        @{Id="Notepad++.Notepad++"; Name="Notepad++"; Winget="Notepad++.Notepad++"; Choco="notepadplusplus"},
        @{Id="7zip.7zip"; Name="7-Zip"; Winget="7zip.7zip"; Choco="7zip"},
        @{Id="VideoLAN.VLC"; Name="VLC Media Player"; Winget="VideoLAN.VLC"; Choco="vlc"},
        @{Id="TheDocumentFoundation.LibreOffice"; Name="LibreOffice"; Winget="TheDocumentFoundation.LibreOffice"; Choco="libreoffice-fresh"},
        @{Id="Microsoft.Teams"; Name="Microsoft Teams"; Winget="Microsoft.Teams"; Choco="microsoft-teams"},
        @{Id="Zoom.Zoom"; Name="Zoom"; Winget="Zoom.Zoom"; Choco="zoom"},
        @{Id="TeamViewer.TeamViewer"; Name="TeamViewer"; Winget="TeamViewer.TeamViewer"; Choco="teamviewer"},
        @{Id="Foxit.FoxitReader"; Name="Foxit PDF Reader"; Winget="Foxit.FoxitReader"; Choco="foxitreader"},
        @{Id="PuTTY.PuTTY"; Name="PuTTY"; Winget="PuTTY.PuTTY"; Choco="putty"},
        @{Id="WinSCP.WinSCP"; Name="WinSCP"; Winget="WinSCP.WinSCP"; Choco="winscp"},
        @{Id="Microsoft.PowerToys"; Name="Microsoft PowerToys"; Winget="Microsoft.PowerToys"; Choco="powertoys"}
    )
    
    Write-Host "Chon phan mem de cai dat:" -ForegroundColor Yellow
    for ($i = 0; $i -lt $softwareList.Count; $i++) {
        Write-Host "$($i+1). $($softwareList[$i].Name)"
    }
    Write-Host "0. Quay lai"
    Write-Host ""
    
    $choice = Read-Host "Chon"
    if ($choice -eq "0") { return }
    
    $idx = [int]$choice - 1
    if ($idx -ge 0 -and $idx -lt $softwareList.Count) {
        $sw = $softwareList[$idx]
        $method = Read-Host "Chon phuong thuc: 1-Winget, 2-Chocolatey"
        
        if ($method -eq "1") {
            if (Test-Winget) {
                Install-SoftwareWinget -PackageId $sw.Winget -SoftwareName $sw.Name
            }
        } elseif ($method -eq "2") {
            if (Install-Chocolatey) {
                choco install $sw.Choco -y --force
                Write-Host "  -> Da cai dat $($sw.Name) thanh cong!" -ForegroundColor Green
            }
        }
    } else {
        Write-Host "Lua chon khong hop le!" -ForegroundColor Red
    }
    Pause
}

function Install-OfficeBundle {
    Show-Header "CAI DAT BO PHAN MEM VAN PHONG"
    
    Write-Host "Chon goi phan mem:" -ForegroundColor Yellow
    Write-Host "1. Microsoft Office 365 (Winget)"
    Write-Host "2. LibreOffice (Mien phi)"
    Write-Host "3. WPS Office"
    Write-Host "4. OnlyOffice DesktopEditors"
    Write-Host "0. Quay lai"
    Write-Host ""
    
    $choice = Read-Host "Chon"
    switch ($choice) {
        "1" { Install-SoftwareWinget "Microsoft.Office" "Microsoft Office 365" }
        "2" { Install-SoftwareWinget "TheDocumentFoundation.LibreOffice" "LibreOffice" }
        "3" { Install-SoftwareWinget "Kingsoft.WPSOffice" "WPS Office" }
        "4" { Install-SoftwareWinget "ONLYOFFICE.DesktopEditors" "OnlyOffice" }
        "0" { return }
        default { Write-Host "Lua chon khong hop le!" -ForegroundColor Red }
    }
    Pause
}

function Install-BrowserBundle {
    Show-Header "CAI DAT TRINH DUYET"
    
    Write-Host "Chon trinh duyet:" -ForegroundColor Yellow
    Write-Host "1. Google Chrome"
    Write-Host "2. Mozilla Firefox"
    Write-Host "3. Microsoft Edge (neu chua co)"
    Write-Host "4. Brave Browser"
    Write-Host "5. Opera"
    Write-Host "0. Quay lai"
    Write-Host ""
    
    $choice = Read-Host "Chon"
    switch ($choice) {
        "1" { Install-SoftwareWinget "Google.Chrome" "Google Chrome" }
        "2" { Install-SoftwareWinget "Mozilla.Firefox" "Mozilla Firefox" }
        "3" { Install-SoftwareWinget "Microsoft.Edge" "Microsoft Edge" }
        "4" { Install-SoftwareWinget "Brave.Brave" "Brave Browser" }
        "5" { Install-SoftwareWinget "Opera.Opera" "Opera" }
        "0" { return }
        default { Write-Host "Lua chon khong hop le!" -ForegroundColor Red }
    }
    Pause
}

function Install-UtilityBundle {
    Show-Header "CAI DAT CONG CU HO TRO"
    
    Write-Host "Chon cong cu:" -ForegroundColor Yellow
    Write-Host "1. 7-Zip (Nen/giai nen)"
    Write-Host "2. Notepad++ (Code editor)"
    Write-Host "3. VLC Media Player"
    Write-Host "4. ShareX (Chup man hinh)"
    Write-Host "5. PowerToys (Tien ich Windows)"
    Write-Host "6. Everything (Tim kiem file)"
    Write-Host "7. Teracopy (Sao chep file)"
    Write-Host "0. Quay lai"
    Write-Host ""
    
    $choice = Read-Host "Chon"
    switch ($choice) {
        "1" { Install-SoftwareWinget "7zip.7zip" "7-Zip" }
        "2" { Install-SoftwareWinget "Notepad++.Notepad++" "Notepad++" }
        "3" { Install-SoftwareWinget "VideoLAN.VLC" "VLC Media Player" }
        "4" { Install-SoftwareWinget "ShareX.ShareX" "ShareX" }
        "5" { Install-SoftwareWinget "Microsoft.PowerToys" "Microsoft PowerToys" }
        "6" { Install-SoftwareWinget "voidtools.Everything" "Everything" }
        "7" { Install-SoftwareWinget "CodeSector.TeraCopy" "Teracopy" }
        "0" { return }
        default { Write-Host "Lua chon khong hop le!" -ForegroundColor Red }
    }
    Pause
}

function Install-DevBundle {
    Show-Header "CAI DAT CONG CU PHAT TRIEN / REMOTE"
    
    Write-Host "Chon cong cu:" -ForegroundColor Yellow
    Write-Host "1. Git"
    Write-Host "2. Visual Studio Code"
    Write-Host "3. PuTTY"
    Write-Host "4. WinSCP"
    Write-Host "5. FileZilla"
    Write-Host "6. TeamViewer"
    Write-Host "7. AnyDesk"
    Write-Host "8. Windows Terminal"
    Write-Host "0. Quay lai"
    Write-Host ""
    
    $choice = Read-Host "Chon"
    switch ($choice) {
        "1" { Install-SoftwareWinget "Git.Git" "Git" }
        "2" { Install-SoftwareWinget "Microsoft.VisualStudioCode" "VS Code" }
        "3" { Install-SoftwareWinget "PuTTY.PuTTY" "PuTTY" }
        "4" { Install-SoftwareWinget "WinSCP.WinSCP" "WinSCP" }
        "5" { Install-SoftwareWinget "TimKosse.FileZilla.Client" "FileZilla" }
        "6" { Install-SoftwareWinget "TeamViewer.TeamViewer" "TeamViewer" }
        "7" { Install-SoftwareWinget "AnyDeskSoftwareGmbH.AnyDesk" "AnyDesk" }
        "8" { Install-SoftwareWinget "Microsoft.WindowsTerminal" "Windows Terminal" }
        "0" { return }
        default { Write-Host "Lua chon khong hop le!" -ForegroundColor Red }
    }
    Pause
}

function Install-AllOffice {
    Show-Header "CAI DAT TOAN BO BO VAN PHONG"
    
    Write-Host "Danh sach se duoc cai dat:" -ForegroundColor Yellow
    Write-Host "- Google Chrome"
    Write-Host "- Adobe Acrobat Reader"
    Write-Host "- 7-Zip"
    Write-Host "- Notepad++"
    Write-Host "- VLC Media Player"
    Write-Host "- LibreOffice"
    Write-Host ""
    
    $confirm = Read-Host "Ban co chac chan muon cai dat toan bo? (Y/N)"
    if ($confirm -ne "Y" -and $confirm -ne "y") { return }
    
    if (-not (Test-Winget)) {
        Write-Host "Winget khong kha dung, khong the tiep tuc!" -ForegroundColor Red
        Pause
        return
    }
    
    Install-SoftwareWinget "Google.Chrome" "Google Chrome"
    Install-SoftwareWinget "Adobe.Acrobat.Reader.64-bit" "Adobe Acrobat Reader"
    Install-SoftwareWinget "7zip.7zip" "7-Zip"
    Install-SoftwareWinget "Notepad++.Notepad++" "Notepad++"
    Install-SoftwareWinget "VideoLAN.VLC" "VLC Media Player"
    Install-SoftwareWinget "TheDocumentFoundation.LibreOffice" "LibreOffice"
    
    Write-Host ""
    Write-Host "Da hoan tat cai dat bo phan mem van phong!" -ForegroundColor Green
    Pause
}

function Update-AllSoftware {
    Show-Header "CAP NHAT TAT CA PHAN MEM"
    
    if (-not (Test-Winget)) {
        Write-Host "Winget khong kha dung!" -ForegroundColor Red
        Pause
        return
    }
    
    Write-Host "Dang kiem tra va cap nhat tat ca phan mem..." -ForegroundColor Yellow
    winget upgrade --all --accept-source-agreements --accept-package-agreements --silent
    Write-Host ""
    Write-Host "Hoan tat cap nhat!" -ForegroundColor Green
    Pause
}

# ==================== MAIN MENU ====================
if (-not (Test-Admin)) {
    Write-Host "Vui long chay script voi quyen Administrator!" -ForegroundColor Red
    Pause
    exit
}

do {
    Show-Header "NHOM 2: CAI DAT PHAN MEM & CONG CU VAN PHONG"
    Write-Host "1. Cai dat phan mem don le"
    Write-Host "2. Cai dat bo Office"
    Write-Host "3. Cai dat trinh duyet"
    Write-Host "4. Cai dat cong cu ho tro"
    Write-Host "5. Cai dat cong cu phat trien / remote"
    Write-Host "6. Cai dat toan bo bo van phong (nhanh)"
    Write-Host "7. Cap nhat tat ca phan mem (winget upgrade --all)"
    Write-Host "8. Kiem tra/Cai dat winget"
    Write-Host "0. Thoat"
    Write-Host ""
    
    $choice = Read-Host "Chon chuc nang"
    
    switch ($choice) {
        "1" { Install-SingleSoftware }
        "2" { Install-OfficeBundle }
        "3" { Install-BrowserBundle }
        "4" { Install-UtilityBundle }
        "5" { Install-DevBundle }
        "6" { Install-AllOffice }
        "7" { Update-AllSoftware }
        "8" { Install-WingetIfMissing; Pause }
        "0" { Write-Host "Tam biet!" -ForegroundColor Green; exit }
        default { Write-Host "Lua chon khong hop le!" -ForegroundColor Red; Start-Sleep -Seconds 1 }
    }
} while ($choice -ne "0")