
```markdown
# He Thong Quan Ly Windows - PowerShell Toolkit (Remote Edition)

Bo cong cu quan tri he thong Windows bang PowerShell, ho tro chay **truc tiep tu GitHub** xuong may tram ma **khong de lai file** sau khi su dung.

---

## 📁 Cau truc file tren repo

WinMgmt_PS_Toolkit/
│
├── MainMenu.ps1                  ← Menu chinh (Parent)
├── SystemInfo_License.ps1        ← Nhom 1: Thong tin he thong & Ban quyen
├── Install_Software.ps1          ← Nhom 2: Cai dat phan mem & Cong cu van phong
├── SystemOptimize_Printer.ps1    ← Nhom 3: Toi uu, Xu ly loi & Quan ly may in
├── Remote-Loader.ps1             ← Remote Loader (tai va chay tu xa)
└── README.md                      ← Huong dan su dung

---

## 🚀 Cach su dung
### Cach 1: Chay truc tiep tu GitHub (Khong can tai file ve may)
**Buoc 1:** Mo **PowerShell voi quyen Administrator** tren may tram
**Buoc 2:** Chay 1 trong cac lenh sau:
```
#### Phuong phap A - Dung Remote-Loader.ps1 (Khuyen nghi)
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iex (iwr "https://raw.githubusercontent.com/vynguyenit/WinMgmt_PS_Toolkit/main/Remote-Loader.ps1" -UseBasicParsing).Content
```

#### Phuong phap B - One-liner truc tiep (khong can Remote-Loader.ps1)
```powershell
$tmp=Join-Path $env:LOCALAPPDATA "WinMgmt_PS_$(Get-Random -Minimum 1000 -Maximum 9999)";New-Item -ItemType Directory -Path $tmp -Force|Out-Null;$base="https://raw.githubusercontent.com/vynguyenit/WinMgmt_PS_Toolkit/main";@("MainMenu.ps1","SystemInfo_License.ps1","Install_Software.ps1","SystemOptimize_Printer.ps1")|ForEach-Object{Invoke-WebRequest -Uri "$base/$_" -OutFile "$tmp\$_" -UseBasicParsing -TimeoutSec 30};& "$tmp\MainMenu.ps1";Remove-Item -Path $tmp -Recurse -Force
```

#### Phuong phap C - De doc (tung buoc)
```powershell
# 1. Tao thu muc tai AppData\Local
$tmp = Join-Path $env:LOCALAPPDATA "WinMgmt_PS_$(Get-Random -Minimum 1000 -Maximum 9999)"
New-Item -ItemType Directory -Path $tmp -Force | Out-Null

# 2. Tai 4 file tu GitHub
$base = "https://raw.githubusercontent.com/vynguyenit/WinMgmt_PS_Toolkit/main"
@("MainMenu.ps1","SystemInfo_License.ps1","Install_Software.ps1","SystemOptimize_Printer.ps1") | ForEach-Object {
    Invoke-WebRequest -Uri "$base/$_" -OutFile "$tmp\$_" -UseBasicParsing
}

# 3. Chay MainMenu
& "$tmp\MainMenu.ps1"

# 4. Xoa sach thu muc sau khi dung xong
Remove-Item -Path $tmp -Recurse -Force
```

### Cach 2: Chay offline (dat 5 file vao cung thu muc)
Neu muon chay offline hoac tu chinh sua:
1. Tai ca 5 file ve cung 1 thu muc
2. Nhan chuot phai `MainMenu.ps1` → **Run with PowerShell**

---

## 📂 Vi tri luu tru tam thoi

Khi chay tu xa, cac file duoc tai ve:
```
C:\Users\<username>\AppData\Local\WinMgmt_PS_<so-ngau-nhien>\
```
Vi du:
```
C:\Users\Admin\AppData\Local\WinMgmt_PS_4336\
```
**Luu y:** Thu muc nay **tu dong bi xoa** sau khi ban thoat khoi Menu chinh hoac khi script ket thuc.

---

## ⚡ Yeu cau he thong

| Yeu to | Chi tiet |
|--------|----------|
| **He dieu hanh** | Windows 10 / Windows 11 / Windows Server 2016+ |
| **PowerShell** | 5.1 tro len |
| **Quyen** | **Administrator** (bat buoc) |
| **Mang** | Can ket noi Internet de tai script tu GitHub |

---

## 📋 Chuc nang chi tiet

### Nhom 1 — Thong tin he thong & Ban quyen
`SystemInfo_License.ps1`

| STT | Chuc nang | Mo ta |
|-----|-----------|-------|
| 1 | Xem thong tin he thong | OS, CPU, RAM, Disk, GPU, BIOS, Network, Domain |
| 2 | Kiem tra ban quyen | Trang thai kich hoat Windows |
| 3 | Xem Product Key | Trich xuat key tu firmware/registry |
| 4 | Nhap Product Key moi | Cai dat key bang slmgr |
| 5 | Kich hoat Windows | Chay `slmgr /ato` |
| 6 | Cau hinh KMS Client | Tu dong chon KMS key theo phien ban |
| 7 | Go bo Product Key | Xoa key hien tai |

### Nhom 2 — Cai dat phan mem & Cong cu van phong
`Install_Software.ps1`

| STT | Chuc nang | Mo ta |
|-----|-----------|-------|
| 1 | Cai dat don le | 15+ ung dung tu danh sach |
| 2 | Cai dat bo Office | Office 365, LibreOffice, WPS, OnlyOffice |
| 3 | Cai dat trinh duyet | Chrome, Firefox, Edge, Brave, Opera |
| 4 | Cong cu ho tro | 7-Zip, Notepad++, VLC, PowerToys... |
| 5 | Cong cu phat trien / Remote | Git, VS Code, PuTTY, TeamViewer... |
| 6 | Cai dat toan bo (nhanh) | Chrome + Reader + 7-Zip + Notepad++ + VLC + LibreOffice |
| 7 | Cap nhat tat ca | `winget upgrade --all` |
| 8 | Kiem tra / Cai dat Winget | Tu dong cai Winget neu thieu |

### Nhom 3 — Toi uu he thong, Xu ly loi & Quan ly may in
`SystemOptimize_Printer.ps1`

| STT | Chuc nang | Mo ta |
|-----|-----------|-------|
| 1 | Toi uu dich vu nen | Tat DiagTrack, SysMain, Xbox, Fax... |
| 2 | Tat Search Indexing | Dung WSearch, xoa file index |
| 3 | Tat Telemetry | Vo hieu hoa AllowTelemetry, Feedback, Advertising ID |
| 4 | Sua loi mang | Reset Winsock, TCP/IP, DNS, ARP, Firewall |
| 5 | Sua loi chia se | Bat LanmanServer, Network Discovery |
| 6 | Sua loi Domain | Reset trust, Rejoin domain |
| 7 | Quan ly may in | Xem, Xoa, Them (TCP/IP/UNC), Sao luu, Khoi phuc |

---

## ⚙️ Cai dat lan dau tren may tram

Mo **PowerShell voi quyen Administrator** va chay:

```powershell
Set-ExecutionPolicy RemoteSigned -Scope Process -Force
```

Sau do chay 1 trong cac lenh o muc **Cach 1** ben tren.

---

## 🛠️ Khac phuc su co

| Van de | Cach khac phuc |
|--------|----------------|
| "Cannot be loaded because running scripts is disabled" | Chay `Set-ExecutionPolicy RemoteSigned -Scope Process -Force` |
| "Access denied" | Dam bao chay PowerShell voi quyen Administrator |
| Khong tai duoc file tu GitHub | Kiem tra tuong lua, proxy, hoac ket noi Internet |
| Winget khong tim thay | Chon muc 8 trong Nhom 2 de tu dong cai dat |
| File con khong tim thay | Dam bao ca 4 file `.ps1` nam cung thu muc voi MainMenu.ps1 |

---

## 🔒 Bao mat & Quyen rieng tu

- **Khong de lai file:** Sau khi chay xong, toan bo script trong thu muc `AppData\Local\WinMgmt_PS_*` duoc xoa sach.
- **Khong luu du lieu:** Khong co registry, khong co service, khong co file cau hinh ton tai sau khi dong.
- **Yeu cau Admin:** Tinh nang toi uu he thong va cai dat phan mem bat buoc phai co quyen Administrator.
- **Nguon mo:** Toan bo ma nguon nam tren GitHub, co the kiem tra truoc khi chay.

---

## 📝 Ghi chu ky thuat

- **Cau truc Parent-Child:** `MainMenu.ps1` la Parent, goi cac file con bang toan tu `&`. Sau khi file con ket thuc, dieu khien tu dong tra ve Menu chinh.
- **Bien `$scriptDir`:** Tu dong xac dinh thu muc chua script, ho tro chay tu bat ky vi tri nao.
- **Thu muc tam:** Su dung `$env:LOCALAPPDATA` thay vi `$env:TEMP` de de kiem soat va trainh bi cac cong cu don dep xoa nham.
- **Encoding:** UTF-8 de ho tro tieng Viet.

---

*Duoc xay dung boi chuyen gia he thong Windows — PowerShell Toolkit*

## Ngắn gọn: trên máy trạm, mở PowerShell Admin, chạy:
   ```powershell
   Set-ExecutionPolicy Bypass -Scope Process -Force; iex (iwr "https://raw.githubusercontent.com/vynguyenit/WinMgmt_PS_Toolkit/main/Remote-Loader.ps1" -UseBasicParsing).Content
```
