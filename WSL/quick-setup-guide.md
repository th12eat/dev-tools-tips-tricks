# WSL Developer Environment — Quick Reference

> Platform Engineering · AWS · IaC

---

## 1. WSL Installation

Run in **PowerShell (Administrator)**:

```powershell
wsl --install
wsl --install -d Ubuntu
```

> Reboot when prompted. After reboot, open Ubuntu from the Start Menu and set your UNIX username and password.

### First-time WSL Setup

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y git curl wget unzip zsh
```

### Switch to Zsh

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

> All shell config lives in `~/.zshrc`. Substitute `~/.bashrc` if you are using bash.

---

## 2. Windows Terminal Settings

All of these are set per-profile under **Settings → Ubuntu → Appearance**:

| Setting | Recommended Value |
|---------|------------------|
| Color scheme | `Solarized Dark` |
| Font face | `MesloLGS NF` |
| Font size | `11` or `12` |
| Cursor shape | `Bar` |
| Background opacity | `100%` (or adjust to taste) |

> Solarized Dark is built into Windows Terminal — no import required. Select it from the dropdown.

## 3. File System Access

### Windows files from WSL

```bash
ls /mnt/c/Users/YourWindowsUsername/
vim /mnt/c/Users/YourWindowsUsername/file.tf
```

> ⚠️ Keep active project files in `~/` (WSL native), not `/mnt/c/`. Cross-boundary I/O is significantly slower.

### WSL files from Windows Explorer

Type in the Explorer address bar:

```
\\wsl$\Ubuntu\home\yourusername
```

Bookmark this path in Quick Access for easy navigation.

### Open current WSL directory in Explorer

```bash
explorer.exe .
```

---
