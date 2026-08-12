#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Nhom 1: Thong tin he thong & Thao tac ban quyen Windows
.DESCRIPTION
    Hien thi thong tin phan cung, phan mem, va cac thao tac quan ly ban quyen Windows
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

function Get-SystemInfoFull {
    Show-Header "THONG TIN HE THONG"
    
    $os = Get-CimInstance Win32_OperatingSystem
    $cs = Get-CimInstance Win32_ComputerSystem
    $bios = Get-CimInstance Win32_BIOS
    $cpu = Get-CimInstance Win32_Processor | Select-Object -First 1
    $gpu = Get-CimInstance Win32_VideoController | Where-Object { $_.AdapterRAM -gt 0 } | Select-Object -First 1
    $disk = Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='C:'"
    $net = Get-CimInstance Win32_NetworkAdapterConfiguration | Where-Object { $_.IPEnabled -eq $true } | Select-Object -First 1
    
    Write-Host "--- HE DIEU HANH ---" -ForegroundColor Yellow
    Write-Host "Ten OS        : $($os.Caption)"
    Write-Host "Phien ban     : $($os.Version)"
    Write-Host "Build         : $($os.BuildNumber)"
    Write-Host "Kien truc     : $($os.OSArchitecture)"
    Write-Host "Duong dan     : $($os.WindowsDirectory)"
    Write-Host "Thoi gian chay: $([math]::Round($os.TotalVisibleMemorySize/1024/1024, 2)) GB RAM (Tong)"
    Write-Host ""
    
    Write-Host "--- PHAN CUNG ---" -ForegroundColor Yellow
    Write-Host "Nha san xuat  : $($cs.Manufacturer)"
    Write-Host "Model         : $($cs.Model)"
    Write-Host "Ten may       : $($cs.Name)"
    Write-Host "CPU           : $($cpu.Name)"
    Write-Host "So nhan       : $($cpu.NumberOfCores) cores / $($cpu.NumberOfLogicalProcessors) threads"
    Write-Host "GPU           : $($gpu.Name)"
    Write-Host "RAM vat ly    : $([math]::Round($cs.TotalPhysicalMemory/1GB, 2)) GB"
    Write-Host ""
    
    Write-Host "--- LUU TRU ---" -ForegroundColor Yellow
    Write-Host "O dia C:      : $([math]::Round($disk.Size/1GB, 2)) GB (Tong) / $([math]::Round($disk.FreeSpace/1GB, 2)) GB (Trong)"
    Write-Host ""
    
    Write-Host "--- BIOS ---" -ForegroundColor Yellow
    Write-Host "Phien ban BIOS: $($bios.SMBIOSBIOSVersion)"
    Write-Host "Nha san xuat  : $($bios.Manufacturer)"
    Write-Host "Ngay phat hanh: $($bios.ReleaseDate)"
    Write-Host "Serial Number : $($bios.SerialNumber)"
    Write-Host ""
    
    Write-Host "--- MANG ---" -ForegroundColor Yellow
    Write-Host "Hostname      : $($env:COMPUTERNAME)"
    Write-Host "Domain        : $($cs.Domain)"
    Write-Host "IP Address    : $($net.IPAddress -join ', ')"
    Write-Host "MAC Address   : $($net.MACAddress)"
    Write-Host "Gateway       : $($net.DefaultIPGateway -join ', ')"
    Write-Host "DNS           : $($net.DNSServerSearchOrder -join ', ')"
    Write-Host ""
    
    Pause
}

function Get-LicenseStatus {
    Show-Header "TRANG THAI BAN QUYEN WINDOWS"
    
    try {
        $license = Get-CimInstance SoftwareLicensingProduct | Where-Object { $_.PartialProductKey -and $_.Name -like "*Windows*" } | Select-Object -First 1
        $service = Get-CimInstance SoftwareLicensingService
        
        Write-Host "--- Trang thai kich hoat ---" -ForegroundColor Yellow
        Write-Host "Ten san pham  : $($license.Name)"
        Write-Host "Trang thai    : $(if($license.LicenseStatus -eq 1){'DA KICH HOAT (Licensed)'}elseif($license.LicenseStatus -eq 2){'DANG KICH HOAT...'}elseif($license.LicenseStatus -eq 0){'CHUA KICH HOAT'}else{'Ma trang thai: ' + $license.LicenseStatus})" -ForegroundColor $(if($license.LicenseStatus -eq 1){'Green'}else{'Red'})
        Write-Host "Mo ta         : $($license.LicenseStatusDescription)"
        Write-Host "Partial Key   : $($license.PartialProductKey)"
        Write-Host ""
        
        Write-Host "--- Thong tin License ---" -ForegroundColor Yellow
        Write-Host "Kieu kich hoat: $($license.Description)"
        Write-Host "Channel       : $($license.ProductKeyChannel)"
        Write-Host ""
        
        $kmsClient = cscript //Nologo "$env:SystemRoot\System32\slmgr.vbs" /dlv 2>$null
        if ($kmsClient) {
            Write-Host "--- Chi tiet SLMGR ---" -ForegroundColor Yellow
            $kmsClient | ForEach-Object { Write-Host $_ }
        }
    } catch {
        Write-Host "Loi khi kiem tra ban quyen: $_" -ForegroundColor Red
    }
    
    Write-Host ""
    Pause
}

function Get-ProductKey {
    Show-Header "PRODUCT KEY (NEU CO)"
    
    try {
        $digitalProductId = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name DigitalProductId -ErrorAction SilentlyContinue).DigitalProductId
        if ($digitalProductId) {
            Write-Host "Digital Product ID ton tai trong Registry." -ForegroundColor Green
            Write-Host "Luu y: Windows 10/11 thuong su dung Digital License, khong luu key ro rang." -ForegroundColor Yellow
        }
        
        $oa3Key = (Get-CimInstance SoftwareLicensingService).OA3xOriginalProductKey
        if ($oa3Key) {
            Write-Host "Product Key (Firmware/OEM): $oa3Key" -ForegroundColor Green
        } else {
            Write-Host "Khong tim thay Product Key trong firmware." -ForegroundColor Yellow
        }
        
        $wmiKey = (Get-CimInstance SoftwareLicensingService).OA3xOriginalProductKey
        Write-Host "WMI Product Key: $wmiKey"
        
    } catch {
        Write-Host "Khong the trich xuat Product Key: $_" -ForegroundColor Red
    }
    
    Write-Host ""
    Pause
}

function Install-ProductKey {
    Show-Header "NHAP PRODUCT KEY MOI"
    
    $key = Read-Host "Nhap Product Key (dinh dang XXXXX-XXXXX-XXXXX-XXXXX-XXXXX)"
    if ($key -match "^[A-Z0-9]{5}-[A-Z0-9]{5}-[A-Z0-9]{5}-[A-Z0-9]{5}-[A-Z0-9]{5}$") {
        try {
            $service = Get-CimInstance SoftwareLicensingService
            $service.InstallProductKey($key)
            $service.RefreshLicenseStatus()
            Write-Host "Da cai dat Product Key thanh cong!" -ForegroundColor Green
            
            $activate = Read-Host "Ban co muon kich hoat ngay khong? (Y/N)"
            if ($activate -eq "Y" -or $activate -eq "y") {
                cscript //Nologo "$env:SystemRoot\System32\slmgr.vbs" /ato
                Write-Host "Da gui yeu cau kich hoat!" -ForegroundColor Green
            }
        } catch {
            Write-Host "Loi khi cai dat key: $_" -ForegroundColor Red
        }
    } else {
        Write-Host "Product Key khong hop le!" -ForegroundColor Red
    }
    Pause
}

function Uninstall-ProductKey {
    Show-Header "GO BO PRODUCT KEY"
    
    $confirm = Read-Host "Ban co chac chan muon go bo Product Key hien tai? (Y/N)"
    if ($confirm -eq "Y" -or $confirm -eq "y") {
        try {
            cscript //Nologo "$env:SystemRoot\System32\slmgr.vbs" /upk
            Write-Host "Da go bo Product Key!" -ForegroundColor Green
        } catch {
            Write-Host "Loi: $_" -ForegroundColor Red
        }
    }
    Pause
}

function Activate-Windows {
    Show-Header "KICH HOAT WINDOWS"
    
    Write-Host "Dang thuc hien kich hoat..." -ForegroundColor Yellow
    try {
        $result = cscript //Nologo "$env:SystemRoot\System32\slmgr.vbs" /ato
        Write-Host $result
        Write-Host "Hoan tat!" -ForegroundColor Green
    } catch {
        Write-Host "Loi kich hoat: $_" -ForegroundColor Red
    }
    Pause
}

function Set-KMSClient {
    Show-Header "CAU HINH KMS CLIENT"
    
    Write-Host "Chon phien ban Windows de cai dat KMS key:" -ForegroundColor Yellow
    Write-Host "1. Windows 10/11 Pro"
    Write-Host "2. Windows 10/11 Enterprise"
    Write-Host "3. Windows 10/11 Education"
    Write-Host "4. Windows Server 2022 Standard"
    Write-Host "5. Windows Server 2022 Datacenter"
    Write-Host "6. Nhap KMS Server tuy chinh"
    Write-Host "0. Quay lai"
    
    $choice = Read-Host "Chon"
    
    $kmsKeys = @{
        "1" = "W269N-WFGWX-YVC9B-4J6C9-T83GX"
        "2" = "NPPR9-FWDCX-D2C8J-H872K-2YT43"
        "3" = "NW6C2-QMPVW-D7KKK-3GKT6-VCFB2"
        "4" = "VDYBN-27WPP-V4HQT-9VMD4-VMK7H"
        "5" = "WX4NM-KYWYW-QJJR4-XV3QB-6VM33"
    }
    
    if ($kmsKeys.ContainsKey($choice)) {
        $key = $kmsKeys[$choice]
        Write-Host "Dang cai dat key: $key" -ForegroundColor Yellow
        cscript //Nologo "$env:SystemRoot\System32\slmgr.vbs" /ipk $key
        
        $kmsServer = Read-Host "Nhap dia chi KMS Server (de trong neu dang ky tu dong)"
        if ($kmsServer) {
            cscript //Nologo "$env:SystemRoot\System32\slmgr.vbs" /skms $kmsServer
        }
        
        cscript //Nologo "$env:SystemRoot\System32\slmgr.vbs" /ato
        Write-Host "Hoan tat!" -ForegroundColor Green
    } elseif ($choice -eq "6") {
        $kmsServer = Read-Host "Nhap dia chi KMS Server"
        cscript //Nologo "$env:SystemRoot\System32\slmgr.vbs" /skms $kmsServer
        cscript //Nologo "$env:SystemRoot\System32\slmgr.vbs" /ato
        Write-Host "Hoan tat!" -ForegroundColor Green
    }
    Pause
}

# ==================== MAIN MENU ====================
if (-not (Test-Admin)) {
    Write-Host "Vui long chay script voi quyen Administrator!" -ForegroundColor Red
    Pause
    exit
}

do {
    Show-Header "NHOM 1: THONG TIN HE THONG & BAN QUYEN"
    Write-Host "1. Xem thong tin he thong day du"
    Write-Host "2. Kiem tra trang thai ban quyen Windows"
    Write-Host "3. Xem Product Key (neu co the trich xuat)"
    Write-Host "4. Nhap/Cai dat Product Key moi"
    Write-Host "5. Kich hoat Windows (slmgr /ato)"
    Write-Host "6. Cau hinh KMS Client"
    Write-Host "7. Go bo Product Key hien tai"
    Write-Host "0. Thoat"
    Write-Host ""
    
    $choice = Read-Host "Chon chuc nang"
    
    switch ($choice) {
        "1" { Get-SystemInfoFull }
        "2" { Get-LicenseStatus }
        "3" { Get-ProductKey }
        "4" { Install-ProductKey }
        "5" { Activate-Windows }
        "6" { Set-KMSClient }
        "7" { Uninstall-ProductKey }
        "0" { Write-Host "Tam biet!" -ForegroundColor Green; exit }
        default { Write-Host "Lua chon khong hop le!" -ForegroundColor Red; Start-Sleep -Seconds 1 }
    }
} while ($choice -ne "0")