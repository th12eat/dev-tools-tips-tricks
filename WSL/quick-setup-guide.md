# WSL Developer Environment — Quick Reference

> Platform Engineering · Vim · AWS · IaC

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

## 2. File System Access

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
