#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Nhom 3: Toi uu he thong, Xu ly loi & Quan ly may in
.DESCRIPTION
    Toi uu hieu nang Windows, sua loi ket noi mang/may in/domain, quan ly may in
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

function Optimize-Services {
    Show-Header "TOI UU DICH VU NEN (Services)"
    
    $servicesToDisable = @(
        "DiagTrack",
        "dmwappushservice",
        "MapsBroker",
        "WMPNetworkSvc",
        "XblAuthManager",
        "XblGameSave",
        "XboxNetApiSvc",
        "SysMain",
        "WSearch",
        "Fax",
        "PrintNotify",
        "RemoteRegistry",
        "TapiSrv",
        "TabletInputService",
        "WbioSrvc"
    )
    
    foreach ($svc in $servicesToDisable) {
        try {
            $service = Get-Service -Name $svc -ErrorAction SilentlyContinue
            if ($service) {
                Write-Host "Dang xu ly: $($service.DisplayName) ($svc)..." -ForegroundColor Yellow
                Stop-Service -Name $svc -Force -ErrorAction SilentlyContinue
                Set-Service -Name $svc -StartupType Disabled -ErrorAction SilentlyContinue
                Write-Host "  -> Da tat: $($service.DisplayName)" -ForegroundColor Green
            } else {
                Write-Host "  -> Khong tim thay: $svc" -ForegroundColor Gray
            }
        } catch {
            Write-Host "  -> Loi khi xu ly $svc`: $_" -ForegroundColor Red
        }
    }
    
    Write-Host ""
    Write-Host "Da hoan tat toi uu dich vu!" -ForegroundColor Green
    Pause
}

function Disable-SearchIndexing {
    Show-Header "TAT WINDOWS SEARCH INDEXING"
    
    try {
        Write-Host "Dang tat Windows Search Service..." -ForegroundColor Yellow
        Stop-Service -Name "WSearch" -Force -ErrorAction SilentlyContinue
        Set-Service -Name "WSearch" -StartupType Disabled
        Write-Host "  -> Da tat Windows Search" -ForegroundColor Green
        
        Write-Host ""
        Write-Host "Dang xoa du lieu index cu..." -ForegroundColor Yellow
        Remove-Item -Path "$env:ProgramData\Microsoft\Search\Data\Applications\Windows\Windows.edb" -Force -ErrorAction SilentlyContinue
        Write-Host "  -> Da xoa file index" -ForegroundColor Green
        
        Write-Host ""
        Write-Host "Dang vo hieu hoa indexing tren o dia..." -ForegroundColor Yellow
        $drives = Get-WmiObject Win32_LogicalDisk | Where-Object { $_.DriveType -eq 3 }
        foreach ($drive in $drives) {
            $driveLetter = $drive.DeviceID
            Write-Host "  -> Tat indexing cho o $driveLetter" -ForegroundColor Yellow
            $path = "$driveLetter\"
            $folder = Get-WmiObject -Class Win32_Directory -Filter "Name='$($path -replace '\\','\\\\')'"
            if ($folder) {
                $folder.Indexed = $false
                $folder.Put() | Out-Null
            }
        }
        Write-Host "  -> Da tat indexing tren cac o dia" -ForegroundColor Green
        
    } catch {
        Write-Host "Loi: $_" -ForegroundColor Red
    }
    
    Write-Host ""
    Write-Host "Luu y: Tat Search Indexing se lam chuc nang tim kiem Windows cham hon!" -ForegroundColor Yellow
    Pause
}

function Disable-Telemetry {
    Show-Header "TAT TELEMETRY & THEO DOI"
    
    try {
        $telemetryPaths = @{
            "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" = @{
                "AllowTelemetry" = 0
                "DoNotShowFeedbackNotifications" = 1
            }
            "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" = @{
                "AllowTelemetry" = 0
            }
            "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Policies\DataCollection" = @{
                "AllowTelemetry" = 0
            }
            "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat" = @{
                "AITEnable" = 0
                "DisableInventory" = 1
            }
            "HKLM:\SOFTWARE\Policies\Microsoft\SQMClient\Windows" = @{
                "CEIPEnable" = 0
            }
            "HKLM:\SOFTWARE\Policies\Microsoft\Windows\HandwritingErrorReports" = @{
                "PreventHandwritingErrorReports" = 1
            }
        }
        
        foreach ($path in $telemetryPaths.Keys) {
            if (-not (Test-Path $path)) {
                New-Item -Path $path -Force | Out-Null
            }
            foreach ($name in $telemetryPaths[$path].Keys) {
                Set-ItemProperty -Path $path -Name $name -Value $telemetryPaths[$path][$name] -Type DWord -Force
                Write-Host "  -> Da set: $path\$name = $($telemetryPaths[$path][$name])" -ForegroundColor Green
            }
        }
        
        Write-Host ""
        Write-Host "Dang tat Windows Feedback..." -ForegroundColor Yellow
        $feedbackPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"
        Set-ItemProperty -Path $feedbackPath -Name "DoNotShowFeedbackNotifications" -Value 1 -Type DWord -Force
        
        Write-Host "Dang tat Advertising ID..." -ForegroundColor Yellow
        $advPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo"
        if (-not (Test-Path $advPath)) { New-Item -Path $advPath -Force | Out-Null }
        Set-ItemProperty -Path $advPath -Name "DisabledByGroupPolicy" -Value 1 -Type DWord -Force
        
        Write-Host "Dang tat Cortana..." -ForegroundColor Yellow
        $cortanaPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"
        if (-not (Test-Path $cortanaPath)) { New-Item -Path $cortanaPath -Force | Out-Null }
        Set-ItemProperty -Path $cortanaPath -Name "AllowCortana" -Value 0 -Type DWord -Force
        
        Write-Host ""
        Write-Host "Da hoan tat tat Telemetry!" -ForegroundColor Green
        Write-Host "Yeu cau khoi dong lai may de ap dung day du." -ForegroundColor Yellow
        
    } catch {
        Write-Host "Loi: $_" -ForegroundColor Red
    }
    Pause
}

function Optimize-Network {
    Show-Header "SUA LOI KET NOI MANG"
    
    try {
        Write-Host "1. Dang reset Winsock..." -ForegroundColor Yellow
        netsh winsock reset | Out-Null
        Write-Host "   -> Hoan tat" -ForegroundColor Green
        
        Write-Host "2. Dang reset TCP/IP stack..." -ForegroundColor Yellow
        netsh int ip reset | Out-Null
        Write-Host "   -> Hoan tat" -ForegroundColor Green
        
        Write-Host "3. Dang xoa cache DNS..." -ForegroundColor Yellow
        ipconfig /flushdns | Out-Null
        Write-Host "   -> Hoan tat" -ForegroundColor Green
        
        Write-Host "4. Dang renew IP..." -ForegroundColor Yellow
        ipconfig /release | Out-Null
        ipconfig /renew | Out-Null
        Write-Host "   -> Hoan tat" -ForegroundColor Green
        
        Write-Host "5. Dang xoa ARP cache..." -ForegroundColor Yellow
        netsh interface ip delete arpcache | Out-Null
        Write-Host "   -> Hoan tat" -ForegroundColor Green
        
        Write-Host "6. Dang reset Windows Firewall..." -ForegroundColor Yellow
        netsh advfirewall reset | Out-Null
        Write-Host "   -> Hoan tat" -ForegroundColor Green
        
        Write-Host ""
        Write-Host "Da hoan tat sua loi mang!" -ForegroundColor Green
        Write-Host "Vui long khoi dong lai may tinh." -ForegroundColor Yellow
        
    } catch {
        Write-Host "Loi: $_" -ForegroundColor Red
    }
    Pause
}

function Fix-FileSharing {
    Show-Header "SUA LOI CHIA SE FILE & MAY IN"
    
    try {
        Write-Host "--- Bat cac dich vu chia se ---" -ForegroundColor Yellow
        $shareServices = @("LanmanServer", "LanmanWorkstation", "FDResPub", "upnphost", "SSDPSRV", "Dnscache")
        foreach ($svc in $shareServices) {
            Set-Service -Name $svc -StartupType Automatic -ErrorAction SilentlyContinue
            Start-Service -Name $svc -ErrorAction SilentlyContinue
            Write-Host "  -> Da bat: $svc" -ForegroundColor Green
        }
        
        Write-Host ""
        Write-Host "--- Bat Network Discovery ---" -ForegroundColor Yellow
        Enable-NetFirewallRule -DisplayGroup "Network Discovery" -ErrorAction SilentlyContinue
        Write-Host "  -> Da bat Network Discovery" -ForegroundColor Green
        
        Write-Host ""
        Write-Host "--- Bat File and Printer Sharing ---" -ForegroundColor Yellow
        Enable-NetFirewallRule -DisplayGroup "File and Printer Sharing" -ErrorAction SilentlyContinue
        Write-Host "  -> Da bat File and Printer Sharing" -ForegroundColor Green
        
        Write-Host ""
        Write-Host "--- Cau hinh Advanced Sharing Settings ---" -ForegroundColor Yellow
        $regPaths = @{
            "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" = @{ "AutoShareServer" = 1; "AutoShareWks" = 1 }
            "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\NetworkSharing" = @{ "DisableFirewall" = 0 }
        }
        foreach ($path in $regPaths.Keys) {
            foreach ($name in $regPaths[$path].Keys) {
                Set-ItemProperty -Path $path -Name $name -Value $regPaths[$path][$name] -Force -ErrorAction SilentlyContinue
            }
        }
        Write-Host "  -> Da cau hinh xong" -ForegroundColor Green
        
        Write-Host ""
        Write-Host "--- Kiem tra SMB ---" -ForegroundColor Yellow
        $smb1 = Get-WindowsOptionalFeature -Online -FeatureName "SMB1Protocol" -ErrorAction SilentlyContinue
        if ($smb1 -and $smb1.State -eq "Disabled") {
            Write-Host "  -> SMB 1.0 dang tat (khuyen nghi de bao mat)" -ForegroundColor Yellow
        }
        
        Write-Host ""
        Write-Host "Da hoan tat sua loi chia se!" -ForegroundColor Green
        Write-Host "Vui long khoi dong lai may va kiem tra." -ForegroundColor Yellow
        
    } catch {
        Write-Host "Loi: $_" -ForegroundColor Red
    }
    Pause
}

function Fix-DomainTrust {
    Show-Header "SUA LOI MAT KET NOI DOMAIN"
    
    Write-Host "Chon phuong phap khac phuc:" -ForegroundColor Yellow
    Write-Host "1. Reset trust relationship (neu van con ket noi domain yeu)"
    Write-Host "2. Rejoin domain (thoat va gia nhap lai)"
    Write-Host "3. Kiem tra trang thai domain hien tai"
    Write-Host "0. Quay lai"
    Write-Host ""
    
    $choice = Read-Host "Chon"
    
    switch ($choice) {
        "1" {
            try {
                Write-Host "Dang reset trust relationship..." -ForegroundColor Yellow
                Test-ComputerSecureChannel -Repair -Credential (Get-Credential -Message "Nhap tai khoan Domain Admin") -ErrorAction Stop
                Write-Host "  -> Da sua trust relationship thanh cong!" -ForegroundColor Green
            } catch {
                Write-Host "  -> Loi: $_" -ForegroundColor Red
                Write-Host "  -> Thu chon phuong phap 2 (Rejoin domain)" -ForegroundColor Yellow
            }
        }
        "2" {
            try {
                $domain = Read-Host "Nhap ten domain (vi du: company.local)"
                $cred = Get-Credential -Message "Nhap tai khoan Domain Admin"
                
                Write-Host "Dang thoat domain..." -ForegroundColor Yellow
                Remove-Computer -UnjoinDomainCredential $cred -PassThru -Force -ErrorAction Stop
                Write-Host "  -> Da thoat domain. May se khoi dong lai..." -ForegroundColor Green
                
                $restart = Read-Host "Khoi dong lai ngay bay gio? (Y/N)"
                if ($restart -eq "Y" -or $restart -eq "y") {
                    Restart-Computer -Force
                }
                
                Write-Host ""
                Write-Host "SAU KHI KHOI DONG LAI:" -ForegroundColor Cyan
                Write-Host "Chay lai script nay va chon 'Gia nhap domain' hoac dung: Add-Computer -DomainName $domain -Credential <domain admin>" -ForegroundColor Yellow
                
            } catch {
                Write-Host "Loi: $_" -ForegroundColor Red
            }
        }
        "3" {
            try {
                $cs = Get-CimInstance Win32_ComputerSystem
                Write-Host "Ten may       : $($cs.Name)" -ForegroundColor Cyan
                Write-Host "Domain        : $($cs.Domain)" -ForegroundColor Cyan
                Write-Host "PartOfDomain  : $($cs.PartOfDomain)" -ForegroundColor Cyan
                Write-Host "Workgroup     : $($cs.Workgroup)" -ForegroundColor Cyan
                
                Write-Host ""
                Write-Host "Kiem tra secure channel..." -ForegroundColor Yellow
                $secureChannel = Test-ComputerSecureChannel -ErrorAction SilentlyContinue
                Write-Host "Secure Channel: $(if($secureChannel){'HOAT DONG'}else{'BI LOI'})" -ForegroundColor $(if($secureChannel){'Green'}else{'Red'})
                
                Write-Host ""
                Write-Host "Kiem tra ket noi DC..." -ForegroundColor Yellow
                $dc = $env:LOGONSERVER -replace "\\\\",""
                if ($dc) {
                    Test-Connection -ComputerName $dc -Count 2 -ErrorAction SilentlyContinue | Out-Null
                    Write-Host "DC (LogonServer): $dc" -ForegroundColor Cyan
                }
            } catch {
                Write-Host "Loi: $_" -ForegroundColor Red
            }
        }
        "0" { return }
        default { Write-Host "Lua chon khong hop le!" -ForegroundColor Red }
    }
    Pause
}

function Get-PrinterList {
    Show-Header "DANH SACH MAY IN"
    
    try {
        $printers = Get-Printer -ErrorAction SilentlyContinue
        if (-not $printers) {
            Write-Host "Khong co may in nao duoc cai dat!" -ForegroundColor Yellow
            Pause
            return
        }
        
        Write-Host "{0,-5} {1,-30} {2,-20} {3,-15} {4,-10}" -f "STT", "Ten may in", "Driver", "Port", "Trang thai" -ForegroundColor Cyan
        Write-Host ("-" * 85)
        
        $i = 1
        foreach ($p in $printers) {
            $status = if ($p.Shared) { "Shared" } else { "Local" }
            $default = if ($p.Default) { " [MAC DINH]" } else { "" }
            Write-Host ("{0,-5} {1,-30} {2,-20} {3,-15} {4,-10}" -f $i, ($p.Name + $default).Substring(0,[Math]::Min(30, ($p.Name + $default).Length)), $p.DriverName, $p.PortName, $status)
            $i++
        }
    } catch {
        Write-Host "Loi: $_" -ForegroundColor Red
    }
}

function Remove-AllPrinters {
    Show-Header "XOA TOAN BO MAY IN"
    
    Get-PrinterList
    Write-Host ""
    
    $confirm = Read-Host "BAN CO CHAC CHAN MUON XOA TOAN BO MAY IN? (GO 'XOA' DE XAC NHAN)"
    if ($confirm -ne "XOA") {
        Write-Host "Da huy thao tac!" -ForegroundColor Yellow
        Pause
        return
    }
    
    try {
        $printers = Get-Printer -ErrorAction SilentlyContinue
        foreach ($p in $printers) {
            Write-Host "Dang xoa: $($p.Name)..." -ForegroundColor Yellow
            Remove-Printer -Name $p.Name -ErrorAction SilentlyContinue
            
            if ($p.PortName -notlike "*USB*" -and $p.PortName -notlike "*WSD*" -and $p.PortName -notlike "*TCP*") {
                Remove-PrinterPort -Name $p.PortName -ErrorAction SilentlyContinue
            }
            
            Write-Host "  -> Da xoa: $($p.Name)" -ForegroundColor Green
        }
        
        $drivers = Get-PrinterDriver -ErrorAction SilentlyContinue | Where-Object { $_.Name -notlike "*Microsoft*" -and $_.Name -notlike "*Fax*" }
        foreach ($d in $drivers) {
            Write-Host "Dang xoa driver: $($d.Name)..." -ForegroundColor Yellow
            Remove-PrinterDriver -Name $d.Name -RemoveFromDriverStore -ErrorAction SilentlyContinue
            Write-Host "  -> Da xoa driver" -ForegroundColor Green
        }
        
        Write-Host ""
        Write-Host "Da xoa toan bo may in va driver!" -ForegroundColor Green
        
    } catch {
        Write-Host "Loi: $_" -ForegroundColor Red
    }
    Pause
}

function Add-NetworkPrinter {
    Show-Header "THEM MAY IN MANG (TCP/IP)"
    
    try {
        $printerName = Read-Host "Nhap ten may in (hien thi)"
        $ipAddress = Read-Host "Nhap dia chi IP may in"
        $driverName = Read-Host "Nhap ten driver (vi du: HP LaserJet P2055dn)"
        
        if (-not ($ipAddress -match "^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$")) {
            Write-Host "Dia chi IP khong hop le!" -ForegroundColor Red
            Pause
            return
        }
        
        $portName = "IP_$ipAddress"
        Write-Host "Dang tao port $portName..." -ForegroundColor Yellow
        
        $portExists = Get-PrinterPort -Name $portName -ErrorAction SilentlyContinue
        if (-not $portExists) {
            Add-PrinterPort -Name $portName -PrinterHostAddress $ipAddress -PortNumber 9100 -ErrorAction Stop
            Write-Host "  -> Da tao port" -ForegroundColor Green
        } else {
            Write-Host "  -> Port da ton tai" -ForegroundColor Yellow
        }
        
        Write-Host "Dang them may in..." -ForegroundColor Yellow
        Add-Printer -Name $printerName -DriverName $driverName -PortName $portName -ErrorAction Stop
        Write-Host "  -> Da them may in thanh cong!" -ForegroundColor Green
        
        $setDefault = Read-Host "Dat lam may in mac dinh? (Y/N)"
        if ($setDefault -eq "Y" -or $setDefault -eq "y") {
            Set-Printer -Name $printerName -IsDefault $true
            Write-Host "  -> Da dat mac dinh" -ForegroundColor Green
        }
        
    } catch {
        Write-Host "Loi: $_" -ForegroundColor Red
        Write-Host "Goi y: Kiem tra xem driver '$driverName' da duoc cai dat chua." -ForegroundColor Yellow
    }
    Pause
}

function Add-SharedPrinter {
    Show-Header "THEM MAY IN CHIA SE (\\SERVER\PRINTER)"
    
    try {
        $uncPath = Read-Host "Nhap duong dan may in chia se (vi du: \\SERVER\Printer01)"
        $printerName = Read-Host "Nhap ten hien thi cho may in (de trong de dung ten goc)"
        
        if ([string]::IsNullOrWhiteSpace($printerName)) {
            $printerName = Split-Path $uncPath -Leaf
        }
        
        Write-Host "Dang ket noi toi $uncPath..." -ForegroundColor Yellow
        Add-Printer -ConnectionName $uncPath -Name $printerName -ErrorAction Stop
        Write-Host "  -> Da them may in chia se thanh cong!" -ForegroundColor Green
        
        $setDefault = Read-Host "Dat lam may in mac dinh? (Y/N)"
        if ($setDefault -eq "Y" -or $setDefault -eq "y") {
            Set-Printer -Name $printerName -IsDefault $true
            Write-Host "  -> Da dat mac dinh" -ForegroundColor Green
        }
        
    } catch {
        Write-Host "Loi: $_" -ForegroundColor Red
        Write-Host "Goi y: Kiem tra quyen truy cap va xem may in co dang duoc chia se khong." -ForegroundColor Yellow
    }
    Pause
}

function Export-PrinterConfig {
    Show-Header "SAO LUU CAU HINH MAY IN"
    
    try {
        $exportPath = Read-Host "Nhap duong dan luu file (vi du: C:\Printers_Backup.xml)"
        if ([string]::IsNullOrWhiteSpace($exportPath)) {
            $exportPath = "C:\Printers_Backup.xml"
        }
        
        Write-Host "Dang xuat cau hinh may in..." -ForegroundColor Yellow
        
        $printBrm = "$env:SystemRoot\System32\spool\tools\PrintBrm.exe"
        if (Test-Path $printBrm) {
            & $printBrm -B -S $env:COMPUTERNAME -F $exportPath
            Write-Host "  -> Da sao luu vao: $exportPath" -ForegroundColor Green
        } else {
            $printers = Get-Printer | Select-Object Name, DriverName, PortName, Shared, ShareName, IsDefault, Comment, Location
            $printers | Export-Clixml -Path $exportPath
            Write-Host "  -> Da sao luu (PowerShell format) vao: $exportPath" -ForegroundColor Green
        }
        
        $driverPath = [System.IO.Path]::ChangeExtension($exportPath, "_Drivers.txt")
        Get-PrinterDriver | Select-Object Name, Manufacturer, Version | Out-File $driverPath
        Write-Host "  -> Da sao luu danh sach driver vao: $driverPath" -ForegroundColor Green
        
    } catch {
        Write-Host "Loi: $_" -ForegroundColor Red
    }
    Pause
}

function Import-PrinterConfig {
    Show-Header "KHOI PHUC CAU HINH MAY IN"
    
    try {
        $importPath = Read-Host "Nhap duong dan file sao luu (vi du: C:\Printers_Backup.xml)"
        if (-not (Test-Path $importPath)) {
            Write-Host "File khong ton tai!" -ForegroundColor Red
            Pause
            return
        }
        
        Write-Host "Dang khoi phuc cau hinh may in..." -ForegroundColor Yellow
        
        $printBrm = "$env:SystemRoot\System32\spool\tools\PrintBrm.exe"
        if (Test-Path $printBrm) {
            & $printBrm -R -S $env:COMPUTERNAME -F $importPath
            Write-Host "  -> Da khoi phuc thanh cong!" -ForegroundColor Green
        } else {
            $printers = Import-Clixml -Path $importPath
            foreach ($p in $printers) {
                try {
                    Add-Printer -Name $p.Name -DriverName $p.DriverName -PortName $p.PortName -ErrorAction SilentlyContinue
                    Write-Host "  -> Da them: $($p.Name)" -ForegroundColor Green
                } catch {
                    Write-Host "  -> Loi them $($p.Name): $_" -ForegroundColor Red
                }
            }
        }
        
    } catch {
        Write-Host "Loi: $_" -ForegroundColor Red
    }
    Pause
}

function Manage-Printers {
    do {
        Show-Header "QUAN LY MAY IN"
        Write-Host "1. Xem danh sach may in"
        Write-Host "2. Xoa TOAN BO may in (va driver)"
        Write-Host "3. Them may in mang (TCP/IP)"
        Write-Host "4. Them may in chia se (UNC)"
        Write-Host "5. Sao luu cau hinh may in"
        Write-Host "6. Khoi phuc cau hinh may in"
        Write-Host "0. Quay lai menu chinh"
        Write-Host ""
        
        $choice = Read-Host "Chon"
        
        switch ($choice) {
            "1" { Get-PrinterList; Pause }
            "2" { Remove-AllPrinters }
            "3" { Add-NetworkPrinter }
            "4" { Add-SharedPrinter }
            "5" { Export-PrinterConfig }
            "6" { Import-PrinterConfig }
            "0" { return }
            default { Write-Host "Lua chon khong hop le!" -ForegroundColor Red; Start-Sleep -Seconds 1 }
        }
    } while ($choice -ne "0")
}

# ==================== MAIN MENU ====================
if (-not (Test-Admin)) {
    Write-Host "Vui long chay script voi quyen Administrator!" -ForegroundColor Red
    Pause
    exit
}

do {
    Show-Header "NHOM 3: TOI UU HE THONG, XU LOI & QUAN LY MAY IN"
    Write-Host "--- TOI UU HE THONG ---" -ForegroundColor Yellow
    Write-Host "1. Toi uu dich vu nen (tat cac dich vu khong can thiet)"
    Write-Host "2. Tat Windows Search Indexing"
    Write-Host "3. Tat Telemetry & Theo doi"
    Write-Host ""
    Write-Host "--- SUA LOI KET NOI ---" -ForegroundColor Yellow
    Write-Host "4. Sua loi ket noi mang (Reset TCP/IP, DNS, Winsock)"
    Write-Host "5. Sua loi chia se file & may in"
    Write-Host "6. Sua loi mat ket noi Domain"
    Write-Host ""
    Write-Host "--- QUAN LY MAY IN ---" -ForegroundColor Yellow
    Write-Host "7. Quan ly may in (Xem/Xoa/Them/Sao luu/Khoi phuc)"
    Write-Host ""
    Write-Host "0. Thoat"
    Write-Host ""
    
    $choice = Read-Host "Chon chuc nang"
    
    switch ($choice) {
        "1" { Optimize-Services }
        "2" { Disable-SearchIndexing }
        "3" { Disable-Telemetry }
        "4" { Optimize-Network }
        "5" { Fix-FileSharing }
        "6" { Fix-DomainTrust }
        "7" { Manage-Printers }
        "0" { Write-Host "Tam biet!" -ForegroundColor Green; exit }
        default { Write-Host "Lua chon khong hop le!" -ForegroundColor Red; Start-Sleep -Seconds 1 }
    }
} while ($choice -ne "0")