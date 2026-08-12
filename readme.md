```markdown
# He Thong Quan Ly Windows - PowerShell Toolkit
Bo cong cu quan tri he thong Windows bang PowerShell, bao gom **1 Menu chinh** (Parent) va **3 nhom chuc nang** (Child).
---
## 📁 Cau truc file
```
[Thu muc chua script]
│
├── MainMenu.ps1                  ← Menu chinh (Parent)
├── SystemInfo_License.ps1        ← Nhom 1: Thong tin he thong & Ban quyen
├── Install_Software.ps1          ← Nhom 2: Cai dat phan mem & Cong cu van phong
└── SystemOptimize_Printer.ps1    ← Nhom 3: Toi uu, Xu ly loi & Quan ly may in
```

> **Quan trong:** Ca 4 file phai dat trong cung mot thu muc de MainMenu co the goi duoc cac file con.

---

## 🚀 Cach su dung

### Cach 1: Chay qua Menu chinh (Khuyen nghi)

1. Nhan **chuot phai** vao file `MainMenu.ps1`
2. Chon **"Run with PowerShell"**
3. Menu chinh se hien thi 4 lua chon:
   - `[1]` Mo Nhom 1
   - `[2]` Mo Nhom 2
   - `[3]` Mo Nhom 3
   - `[0]` Thoat
4. Sau khi chay xong nhom nao do, he thong **tu dong quay ve Menu chinh**.

### Cach 2: Chay tung file rieng le

Neu muon chay truc tiep mot nhom cu the ma khong qua Menu chinh:

```powershell
# Mo PowerShell voi quyen Administrator
# Sau do chay tung lenh:
.\SystemInfo_License.ps1
.\Install_Software.ps1
.\SystemOptimize_Printer.ps1
```

---

## ⚡ Yeu cau he thong

| Yeu to | Chi tiet |
|--------|----------|
| **He dieu hanh** | Windows 10 / Windows 11 / Windows Server 2016+ |
| **PowerShell** | 5.1 tro len (khuyen nghi 7.x) |
| **Quyen** | **Administrator** (bat buoc) |
| **Mang** | Can ket noi Internet de cai dat phan mem qua Winget |

---

## 📋 Chuc nang chi tiet

### Nhom 1 — Thong tin he thong & Ban quyen
`SystemInfo_License.ps1`

| STT | Chuc nang | Mo ta |
|-----|-----------|-------|
| 1 | Xem thong tin he thong | OS, CPU, RAM, Disk, GPU, BIOS, Network, Domain |
| 2 | Kiem tra ban quyen | Trang thai kich hoat Windows, License Status |
| 3 | Xem Product Key | Trich xuat key tu firmware/registry |
| 4 | Nhap Product Key moi | Cai dat key bang slmgr |
| 5 | Kich hoat Windows | Chay `slmgr /ato` |
| 6 | Cau hinh KMS Client | Tu dong chon KMS key theo phien ban Windows |
| 7 | Go bo Product Key | Xoa key hien tai |

### Nhom 2 — Cai dat phan mem & Cong cu van phong
`Install_Software.ps1`

| STT | Chuc nang | Mo ta |
|-----|-----------|-------|
| 1 | Cai dat don le | Chon tung phan mem tu danh sach 15+ ung dung |
| 2 | Cai dat bo Office | Office 365, LibreOffice, WPS, OnlyOffice |
| 3 | Cai dat trinh duyet | Chrome, Firefox, Edge, Brave, Opera |
| 4 | Cong cu ho tro | 7-Zip, Notepad++, VLC, ShareX, PowerToys... |
| 5 | Cong cu phat trien / Remote | Git, VS Code, PuTTY, WinSCP, TeamViewer... |
| 6 | Cai dat toan bo (nhanh) | Cai 1 luc: Chrome + Reader + 7-Zip + Notepad++ + VLC + LibreOffice |
| 7 | Cap nhat tat ca | `winget upgrade --all` |
| 8 | Kiem tra / Cai dat Winget | Tu dong cai Winget neu thieu |

**Danh sach phan mem ho tro:**
- Van phong: Microsoft Office, LibreOffice, WPS, OnlyOffice, Adobe Acrobat Reader, Foxit Reader
- Trinh duyet: Google Chrome, Firefox, Edge, Brave, Opera
- Tien ich: 7-Zip, Notepad++, VLC, ShareX, PowerToys, Everything, Teracopy
- Remote/Dev: Git, VS Code, PuTTY, WinSCP, FileZilla, TeamViewer, AnyDesk, Windows Terminal

### Nhom 3 — Toi uu he thong, Xu ly loi & Quan ly may in
`SystemOptimize_Printer.ps1`

#### Toi uu he thong
| STT | Chuc nang | Mo ta |
|-----|-----------|-------|
| 1 | Toi uu dich vu nen | Tat: DiagTrack, SysMain, Xbox services, Fax, Remote Registry... |
| 2 | Tat Search Indexing | Dung WSearch, xoa file index, tat indexing o dia |
| 3 | Tat Telemetry | Vo hieu hoa: AllowTelemetry, Feedback, Advertising ID, Cortana |

#### Sua loi ket noi
| STT | Chuc nang | Mo ta |
|-----|-----------|-------|
| 4 | Sua loi mang | Reset Winsock, TCP/IP, flush DNS, renew IP, xoa ARP, reset Firewall |
| 5 | Sua loi chia se | Bat LanmanServer/Workstation, Network Discovery, File & Printer Sharing |
| 6 | Sua loi Domain | Reset trust, Rejoin domain, kiem tra trang thai ket noi DC |

#### Quan ly may in
| STT | Chuc nang | Mo ta |
|-----|-----------|-------|
| 7.1 | Xem danh sach | Liet ke may in, driver, port, trang thai |
| 7.2 | Xoa toan bo | Xoa tat ca may in + driver (yeu cau xac nhan "XOA") |
| 7.3 | Them may in mang | Ket noi TCP/IP (port 9100) |
| 7.4 | Them may in chia se | Ket noi qua UNC path (`\\SERVER\Printer`) |
| 7.5 | Sao luu | Export cau hinh ra XML (dung PrintBrm hoac PowerShell) |
| 7.6 | Khoi phuc | Import cau hinh tu file sao luu |

---

## ⚙️ Cai dat lan dau

### Buoc 1: Bat thuc thi script PowerShell

Mo **PowerShell voi quyen Administrator** va chay:

```powershell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
```

### Buoc 2: Dat 4 file vao cung thu muc

Tat ca cac file `.ps1` phai nam chung mot thu muc.

### Buoc 3: Chay Menu chinh

Nhan chuot phai `MainMenu.ps1` -> **Run with PowerShell**.

---

## 🔒 Luu y bao mat

- Tat ca script yeu cau **quyen Administrator**.
- Nhom 2 (cai dat phan mem) su dung **Winget** hoac **Chocolatey** — cac nguon nay duoc Microsoft kiem duyet.
- Nhom 3 co the **tat dich vu he thong** — chi chay khi ban hieu ro tac dong.
- Sao luu may in (Nhom 3) chi hoat dong tot neu driver van con tren he thong.

---

## 🛠️ Khac phuc su co

| Van de | Cach khac phuc |
|--------|----------------|
| "Khong tim thay file script con" | Dam bao ca 4 file `.ps1` nam cung thu muc |
| "Cannot be loaded because running scripts is disabled" | Chay `Set-ExecutionPolicy RemoteSigned -Scope CurrentUser` |
| Winget khong tim thay | Chon muc 8 trong Nhom 2 de tu dong cai dat |
| "Access denied" | Dam bao chay voi quyen Administrator |
| Khong cai duoc phan mem | Kiem tra ket noi Internet va tuong lua |

---

## 📝 Ghi chu ky thuat

- **Cau truc Parent-Child:** `MainMenu.ps1` la Parent, goi cac file con bang toan tu `&` (call operator). Sau khi file con ket thuc, dieu khien tu dong tra ve vong lap `do-while` cua Menu chinh.
- **Bien `$scriptDir`:** Tu dong xac dinh thu muc chua script, ho tro chay tu bat ky vi tri nao.
- **Kiem tra tien dieu kien:** Menu chinh tu dong kiem tra quyen Admin va su ton tai cua 3 file con truoc khi hien thi menu.
- **Encoding:** Cac file duoc luu voi encoding UTF-8 de ho tro tieng Viet.

---

*Duoc xay dung boi chuyen gia he thong Windows — PowerShell Toolkit*
```
