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

## 2. Core Tool Installation

### Python & pip3

```bash
sudo apt install -y python3-pip python3-dev
```

### Node.js via nvm

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
source ~/.zshrc
nvm install --lts
```

> The `| bash` at the end runs the install script — it does not affect your interactive shell. nvm auto-detects zsh and writes to `~/.zshrc`.

### Terraform

```bash
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

sudo apt update && sudo apt install -y terraform
```

> ⚠️ Do not use `snap` for Terraform in WSL — it is unreliable. Use the apt repo above.

### AWS CLI & boto3

```bash
sudo apt install -y awscli
pip3 install boto3 --break-system-packages
```

### Ansible

```bash
pip3 install ansible ansible-lint --break-system-packages
```

### Docker

```bash
sudo apt install -y docker.io
# Or use Docker Desktop on Windows with WSL2 integration enabled
```

### Utilities

```bash
sudo apt install -y jq yq httpie tmux
pip3 install cfn-lint --break-system-packages
```

### LSP Servers (for Vim)

```bash
pip3 install python-lsp-server flake8 black isort yamllint bashate --break-system-packages
npm install -g bash-language-server yaml-language-server prettier
```

---

## 3. GitHub CLI & Authentication

```bash
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg

sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null

sudo apt update && sudo apt install gh -y

gh auth login
```

When prompted choose: **GitHub.com → SSH → Yes → Login with web browser**

> The CLI generates your SSH key, registers it with GitHub, and configures git automatically.

---

## 4. SSH Tunnel to RDS via Bastion

### Fix .pem file permissions

```bash
chmod 600 /path/to/identity.pem
```

> ⚠️ SSH will refuse a key file that is world-readable. This must be done before attempting any SSH connection.

### ~/.ssh/config entry

```
Host rds-tunnel
    HostName         <ec2-bastion-public-dns-or-ip>
    User             <ec2-username>
    IdentityFile     /path/to/identity.pem
    LocalForward     5432 <rds-endpoint>.rds.amazonaws.com:5432
    ServerAliveInterval 60
    ServerAliveCountMax 3
```

Common EC2 usernames: `ec2-user` (Amazon Linux), `ubuntu` (Ubuntu AMI)

### Tunnel lifecycle

```bash
ssh -N -f rds-tunnel        # bring tunnel up (backgrounds automatically)
lsof -i :5432               # verify it is running
kill $(lsof -ti :5432)      # tear it down
```

### URL-encode special characters in passwords

```bash
python3 -c "import urllib.parse; print(urllib.parse.quote('your-password', safe=''))"
```

| Character | Encoded |
|-----------|---------|
| `@` | `%40` |
| `#` | `%23` |
| `$` | `%24` |
| `/` | `%2F` |
| `:` | `%3A` |
| `?` | `%3F` |
| `+` | `%2B` |
| `%` | `%25` |

---

## 5. Vim Setup

### Install Vundle

```bash
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
```

### Install Solarized theme

```bash
mkdir -p ~/.vim/colors
curl -fLo ~/.vim/colors/solarized.vim \
  https://raw.githubusercontent.com/altercation/vim-colors-solarized/master/colors/solarized.vim
```

> In Windows Terminal, set the color scheme to **Solarized Dark** under Settings → your WSL profile → Appearance for best results.

### Install PostgreSQL client (required for vim-dadbod)

```bash
sudo apt install -y postgresql-client
```

### Install all plugins after editing .vimrc

```bash
vim +PluginInstall +qall
```

### Key plugin commands

| Command | Plugin | What it does |
|---------|--------|--------------|
| `:Git` | vim-fugitive | Interactive git status |
| `:DBUI` | vim-dadbod-ui | Database connection sidebar |
| `:NERDTree` | nerdtree | File tree sidebar |
| `:Buffers` | fzf.vim | Fuzzy search open buffers |
| `:Files` | fzf.vim | Fuzzy search project files |
| `:TagbarToggle` | tagbar | Toggle code outline sidebar |

### Buffer navigation

| Command | Action |
|---------|--------|
| `:bn` / `:bp` | Next / previous buffer |
| `:b#` | Toggle to last used buffer |
| `:b<number>` | Jump to buffer by number |
| `:ls` | List all open buffers |
| `:Buffers` | Fuzzy search buffers (fzf) |

Add to `.vimrc` for Tab-based buffer switching:

```vim
nmap <silent> <Tab>   :bn<CR>
nmap <silent> <S-Tab> :bp<CR>
```

---

## 6. File System Access

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

## 7. Verification Checklist

```bash
terraform --version
which pylsp
which bash-language-server
which yaml-language-server
ansible --version
gh auth status
psql --version
node --version && npm --version
aws --version
```

---

## Vundle Command Reference

| Command | Action |
|---------|--------|
| `:PluginInstall` | Install all listed plugins |
| `:PluginUpdate` | Update installed plugins |
| `:PluginClean` | Remove unlisted plugins |
| `:PluginList` | List installed plugins |

## vim-fugitive Command Reference

| Command | Action |
|---------|--------|
| `:Git` | Open interactive git status |
| `:Git add %` | Stage current file |
| `:Git commit` | Open commit message buffer |
| `:Git push` | Push to remote |
| `:Git pull` | Pull from remote |
| `:Git log` | View commit history |
| `:GBrowse` | Open file on GitHub in browser |
| `:Gdiffsplit` | Diff current file against index |
