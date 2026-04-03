# WSL Developer Environment — White Paper

> A comprehensive reference for Platform Engineers building cloud automation, Infrastructure as Code, and end-to-end AWS solutions using Vim as a primary IDE.

---

## Table of Contents

1. [Overview](#1-overview)
2. [WSL Installation & Initial Configuration](#2-wsl-installation--initial-configuration)
3. [Core Development Tools](#3-core-development-tools)
4. [GitHub CLI & Authentication](#4-github-cli--authentication)
5. [SSH Tunneling to Private AWS RDS](#5-ssh-tunneling-to-private-aws-rds)
6. [Vim Configuration](#6-vim-configuration)
7. [LSP Server Installation](#7-lsp-server-installation)
8. [Appendix](#8-appendix)

---

## 1. Overview

This guide documents the full setup of a Windows Subsystem for Linux (WSL) based development environment optimized for platform and cloud engineering work. It covers everything from enabling WSL on a fresh Windows machine through to a fully configured Vim IDE with language intelligence, database connectivity, version control, and Infrastructure as Code tooling.

The environment described here is designed for engineers working with AWS services (EC2, RDS, ECS/Fargate, Lambda, EventBridge), Terraform, Ansible, Jenkins pipelines, and general cloud automation. Vim serves as the primary editor, supplemented by a curated plugin stack that provides IDE-level features without leaving the terminal.

### Why WSL?

Windows Subsystem for Linux provides a genuine Linux kernel running inside Windows, giving engineers access to native Linux tooling (`apt`, `bash`/`zsh`, `ssh`, `curl`, `git`) without dual-booting or a separate VM. For cloud and infrastructure work this matters because:

- Most cloud tooling (Terraform, Ansible, AWS CLI, kubectl) is designed and tested on Linux first
- SSH key handling, file permissions, and shell scripting behave predictably in a Linux environment
- WSL2 uses a real Linux kernel via Hyper-V, meaning Docker, systemd services, and native binaries all work as expected
- Files stored in the WSL filesystem (`~/`) perform significantly better than files accessed through the Windows mount (`/mnt/c/`)

### Why Vim?

Vim is a terminal-based editor that runs anywhere SSH can reach, requires no GUI, and once configured is extremely fast for navigating and editing code. For platform engineers who spend time in remote sessions, bastion hosts, or constrained environments, Vim's ubiquity is a practical advantage. The plugin ecosystem has matured to the point where Vim can match many features of GUI IDEs while remaining keyboard-driven and lightweight.

---

## 2. WSL Installation & Initial Configuration

### 2.1 Enabling WSL on Windows

WSL2 is available on Windows 10 (version 2004+) and Windows 11. The simplest installation path uses a single PowerShell command run with Administrator privileges:

```powershell
wsl --install
```

This command enables the required Windows features (Virtual Machine Platform, Windows Subsystem for Linux), downloads the WSL2 Linux kernel update, and installs Ubuntu as the default distribution. A reboot is required after this step.

To explicitly install Ubuntu:

```powershell
wsl --install -d Ubuntu
```

> Ubuntu is recommended for this stack. The `apt` package manager, broad community support, and compatibility with HashiCorp, GitHub, and AWS package repositories make it the most straightforward choice.

After rebooting, launch Ubuntu from the Start Menu. On first launch you will be prompted to create a UNIX username and password. This is independent of your Windows credentials.

### 2.2 Initial Package Updates

Before installing any tools, update the package index and upgrade existing packages:

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y git curl wget unzip
```

### 2.3 Shell Configuration — Zsh

The default shell in Ubuntu is bash. Many engineers prefer zsh, which offers better tab completion, prompt customization, and a rich plugin ecosystem via Oh My Zsh:

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

After installation, zsh becomes the default shell and configuration lives in `~/.zshrc`. Any environment variable exports, PATH modifications, or tool initializations (nvm, direnv, etc.) go in this file rather than `~/.bashrc`.

> ⚠️ All subsequent references to shell config in this guide assume `~/.zshrc`. If you are using bash, substitute `~/.bashrc`.

### 2.4 Accessing Files Across WSL and Windows

WSL and Windows share a filesystem bridge. Windows drives are mounted in WSL at `/mnt/`:

```bash
ls /mnt/c/Users/YourWindowsUsername/
```

WSL files are accessible from Windows Explorer using the UNC path:

```
\\wsl$\Ubuntu\home\yourusername
```

You can also open the current WSL directory in Windows Explorer directly from the terminal:

```bash
explorer.exe .
```

> ⚠️ Avoid storing active project repositories under `/mnt/c/`. File I/O performance across the WSL/Windows boundary is significantly slower than native Linux filesystem I/O. Keep code in `~/projects/` or similar WSL-native paths.

---

## 3. Core Development Tools

### 3.1 Python & pip3

Python is used for automation scripting, AWS SDK (boto3) work, and as the runtime for several linting and LSP tools. Install the development headers alongside pip3 to ensure compiled packages build correctly:

```bash
sudo apt install -y python3-pip python3-dev
```

### 3.2 Node.js via nvm

Several Vim LSP servers and CLI tools are distributed as npm packages. Rather than installing Node through apt (which often provides outdated versions), the recommended approach is nvm (Node Version Manager):

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
source ~/.zshrc
nvm install --lts
```

> The `| bash` portion of the curl command runs the downloaded script using bash as an interpreter — it does not affect your interactive shell or write to `~/.bashrc` when you are using zsh. The nvm installer auto-detects zsh and writes its initialization block to `~/.zshrc`.

### 3.3 Terraform

Terraform is the primary Infrastructure as Code tool for defining and provisioning AWS resources. HashiCorp maintains an official apt repository:

```bash
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

sudo apt update && sudo apt install -y terraform
```

> ⚠️ Do not install Terraform via `snap` in WSL. Snap packages have known reliability issues in WSL environments due to `snapd` daemon limitations. The apt repository method above is stable and keeps Terraform current through normal `apt upgrade`.

### 3.4 AWS CLI & boto3

The AWS CLI provides command-line access to AWS services and is a daily driver for querying resources, managing credentials, and scripting operational tasks:

```bash
sudo apt install -y awscli
```

boto3 is the AWS SDK for Python, used when writing automation scripts that interact with AWS APIs:

```bash
pip3 install boto3 --break-system-packages
```

> The `--break-system-packages` flag is required on newer Ubuntu versions (23.04+) that use externally managed Python environments. It is safe to use for development tools.

### 3.5 Ansible

Ansible is an agentless configuration management and orchestration tool. Playbooks define the desired state of systems and Ansible handles execution over SSH:

```bash
pip3 install ansible ansible-lint --break-system-packages
```

### 3.6 Docker

For WSL there are two approaches:

- **Docker Desktop on Windows** (recommended) — enable WSL2 integration in Docker Desktop settings. This shares the Docker daemon between Windows and WSL seamlessly.
- **Direct install in WSL** — `sudo apt install -y docker.io`

### 3.7 Kubernetes Tooling

For working with ECS/Fargate clusters or Kubernetes-based infrastructure:

```bash
sudo snap install kubectl --classic
sudo snap install helm --classic
```

### 3.8 General Utilities

| Tool | Purpose | Install |
|------|---------|---------|
| `jq` | Parse and query JSON — essential for AWS CLI output | `sudo apt install -y jq` |
| `yq` | Same as jq but for YAML files | `sudo apt install -y yq` |
| `httpie` | Human-friendly HTTP client for API testing | `sudo apt install -y httpie` |
| `cfn-lint` | CloudFormation template linter | `pip3 install cfn-lint --break-system-packages` |
| `tmux` | Terminal multiplexer — multiple panes in one window | `sudo apt install -y tmux` |

`tmux` deserves special mention: it allows splitting a terminal window into panes, so Vim can occupy one pane while a shell running Terraform, AWS CLI, or Ansible occupies another. This is the closest equivalent to a multi-panel IDE layout in a terminal environment.

---

## 4. GitHub CLI & Authentication

### 4.1 Why GitHub CLI

The GitHub CLI (`gh`) provides authenticated git operations from the command line. Git on modern GitHub requires either SSH keys or Personal Access Tokens — plain password authentication has been removed. The CLI handles SSH key generation and registration automatically.

### 4.2 Installation

GitHub maintains an official apt repository for the CLI:

```bash
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg

sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null

sudo apt update && sudo apt install gh -y
```

### 4.3 Authentication

```bash
gh auth login
```

Select the following options when prompted:

- **Where do you use GitHub?** → `GitHub.com`
- **Preferred protocol?** → `SSH`
- **Authenticate Git with your GitHub credentials?** → `Yes`
- **How would you like to authenticate?** → `Login with a web browser`

The CLI generates an SSH key pair, registers the public key with your GitHub account, and configures git to use it. After completion, all git operations authenticate automatically.

Verify the connection:

```bash
gh auth status
ssh -T git@github.com
```

---

## 5. SSH Tunneling to Private AWS RDS

### 5.1 Architecture

RDS instances in production and staging environments are typically deployed inside a private VPC subnet with no public internet access. To connect from a development workstation, traffic must be routed through an EC2 bastion host that sits in a public subnet with access to the RDS security group.

An SSH tunnel makes this transparent to local tools — once established, the database appears to be running on `localhost`.

```
Developer (WSL :5432)  →  EC2 Bastion (:22)  →  RDS (:5432)
```

| Component | Role |
|-----------|------|
| Developer workstation (WSL) | Originates the SSH tunnel on a local port |
| EC2 bastion host | Public subnet instance that forwards traffic to RDS |
| RDS instance | Private subnet database — only reachable via bastion |

### 5.2 Identity File Permissions

SSH private keys (`.pem` files) must be readable only by their owner. If a key was created by pasting content into a text editor, it will typically have world-readable permissions (`644`), which SSH rejects with a "permissions too open" error:

```bash
chmod 600 /path/to/identity.pem
```

After this change, `ls -la` should show `-rw-------`. SSH will now accept it.

### 5.3 ~/.ssh/config Setup

Defining a named host entry in `~/.ssh/config` eliminates the need to type the full connection string each time. The `LocalForward` directive instructs SSH to accept connections on a local port and forward them through the tunnel to the target host and port:

```
Host rds-tunnel
    HostName         <ec2-bastion-public-dns-or-ip>
    User             <ec2-username>
    IdentityFile     /path/to/identity.pem
    LocalForward     5432 <rds-endpoint>.rds.amazonaws.com:5432
    ServerAliveInterval 60
    ServerAliveCountMax 3
```

Common EC2 usernames by AMI type:

| AMI Type | Default Username |
|----------|-----------------|
| Amazon Linux 2 / Amazon Linux 2023 | `ec2-user` |
| Ubuntu | `ubuntu` |
| Debian | `admin` |
| CentOS | `centos` |
| RHEL | `ec2-user` |

> Port 22 is the transport for the tunnel. The `LocalForward` line describes what is being routed through it, not how the tunnel connects. You do not need to specify port 22 explicitly — SSH uses it by default.

### 5.4 Tunnel Lifecycle

```bash
ssh -N -f rds-tunnel        # bring tunnel up in background
lsof -i :5432               # verify it is running
kill $(lsof -ti :5432)      # tear it down
```

### 5.5 Password URL Encoding

Database connection strings are URLs. Special characters in passwords (`$`, `@`, `#`, `!`, `/`, `?`, etc.) must be percent-encoded or they will be misinterpreted as URL delimiters. The most common culprit is `@` — if unencoded it will break the credentials/hostname parse entirely.

Encode a password from the command line:

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

## 6. Vim Configuration

### 6.1 Plugin Management with Vundle

Vundle is a Vim plugin manager that handles downloading, installing, updating, and removing plugins declared in `.vimrc`. It uses git to clone plugin repositories from GitHub into `~/.vim/bundle/`.

```bash
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
```

The `.vimrc` must begin with the Vundle bootstrap block before any other configuration:

```vim
set nocompatible
filetype off
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

  Plugin 'VundleVim/Vundle.vim'
  " ... other plugins ...

call vundle#end()
filetype plugin indent on
```

### 6.2 Solarized Color Scheme

Solarized is a precision color scheme designed for readability under both dark and light conditions, using a carefully chosen palette with consistent contrast ratios across syntax elements.

```bash
mkdir -p ~/.vim/colors
curl -fLo ~/.vim/colors/solarized.vim \
  https://raw.githubusercontent.com/altercation/vim-colors-solarized/master/colors/solarized.vim
```

Add to `.vimrc`:

```vim
syntax enable
set background=dark   " or 'light'
colorscheme solarized
```

> For best results in Windows Terminal, also set the color scheme to **Solarized Dark** in the terminal profile's Appearance settings. Without this, the 16 ANSI terminal colors will not match the Solarized palette. If you cannot change terminal colors, add `let g:solarized_termcolors=256` to `.vimrc` as a fallback.

### 6.3 Plugin Inventory

| Plugin | Category | Purpose |
|--------|----------|---------|
| `VundleVim/Vundle.vim` | Infrastructure | Plugin manager |
| `tpope/vim-fugitive` | Git | Full git integration (`:Git`, `:Git push`, etc.) |
| `tpope/vim-rhubarb` | Git | Enables `:GBrowse` to open files on GitHub |
| `airblade/vim-gitgutter` | Git | Gutter signs showing per-line diff status |
| `Xuyuanp/nerdtree-git-plugin` | Git | Git status icons inside NERDTree |
| `preservim/nerdtree` | Navigation | File tree sidebar |
| `junegunn/fzf` | Navigation | Fuzzy finder engine |
| `junegunn/fzf.vim` | Navigation | `:Files`, `:Buffers`, `:Rg` commands |
| `dense-analysis/ale` | Linting | Async linting for TF, YAML, Python, bash |
| `prabirshrestha/vim-lsp` | LSP | Language Server Protocol client |
| `prabirshrestha/asyncomplete.vim` | LSP | Async autocompletion engine |
| `prabirshrestha/asyncomplete-lsp.vim` | LSP | Bridge between vim-lsp and asyncomplete |
| `hashivim/vim-terraform` | IaC | Terraform syntax + fmt on save |
| `pearofducks/ansible-vim` | IaC | Ansible playbook/role/inventory syntax |
| `ekalinin/Dockerfile.vim` | IaC | Dockerfile syntax highlighting |
| `chr4/nginx.vim` | IaC | nginx config syntax |
| `tpope/vim-commentary` | Editing | `gc` to toggle comments on lines/blocks |
| `tpope/vim-surround` | Editing | Change surrounding quotes, brackets, tags |
| `vim-airline/vim-airline` | UI | Enhanced status bar and buffer tab line |
| `vim-airline/vim-airline-themes` | UI | Theme pack for airline |
| `preservim/tagbar` | UI | Code structure/outline sidebar |
| `altercation/vim-colors-solarized` | Theme | Solarized color scheme (managed by Vundle) |
| `tpope/vim-dadbod` | Database | Run SQL against live databases |
| `kristijanhusak/vim-dadbod-ui` | Database | Sidebar UI for database connections |
| `kristijanhusak/vim-dadbod-completion` | Database | SQL autocompletion in query buffers |

### 6.4 ALE — Async Linting Engine

ALE (Asynchronous Lint Engine) replaces the older Syntastic plugin. The key difference is that ALE runs linters in background jobs and does not block Vim while checking — essential for large Terraform or Ansible files. ALE integrates with the status bar to show error counts and highlights problem lines in the gutter.

```vim
let g:ale_linters = {
\   'terraform':  ['terraform', 'tflint'],
\   'yaml':       ['yamllint', 'ansible-lint'],
\   'python':     ['pylsp', 'flake8'],
\   'sh':         ['bashate', 'shellcheck'],
\   'dockerfile': ['hadolint'],
\}
let g:ale_fixers = {
\   'terraform': ['terraform'],
\   'python':    ['black', 'isort'],
\   'yaml':      ['prettier'],
\}
let g:ale_fix_on_save=1
```

### 6.5 LSP — Language Server Protocol

LSP is a standard protocol (originally developed by Microsoft for VS Code) that separates language intelligence from the editor. A language server is a standalone process that understands a specific language. The editor communicates with it to request completions, definitions, hover documentation, and diagnostics.

`vim-lsp` acts as the LSP client inside Vim. Separate language server binaries must be installed per language:

| Language | Server | Install |
|----------|--------|---------|
| Python | `pylsp` | `pip3 install python-lsp-server --break-system-packages` |
| Bash/Shell | `bash-language-server` | `npm install -g bash-language-server` |
| YAML | `yaml-language-server` | `npm install -g yaml-language-server` |
| Terraform | `terraform-ls` | Included with Terraform install |

Without LSP, Vim provides only syntax highlighting and basic indentation. With LSP servers running, editing gains:

- **Autocompletion** — context-aware suggestions as you type
- **Go-to-definition** — jump to where a function, variable, or resource is defined (`gd`)
- **Hover documentation** — press `K` to see docs for the symbol under the cursor
- **Inline diagnostics** — errors and warnings flagged as you type, before saving
- **Rename refactoring** — rename a symbol across all references in a project

### 6.6 Database Connectivity with vim-dadbod

`vim-dadbod` provides database access from within Vim. It supports PostgreSQL, MySQL, SQLite, and others. The `dadbod-ui` companion plugin adds a sidebar with a connection browser, table explorer, and query history — approximating PgAdmin functionality in a terminal context.

The PostgreSQL client binary must be installed in WSL:

```bash
sudo apt install -y postgresql-client
```

Connect to a database (tunnel must be up first):

```vim
:DB postgresql://username:p%40ssword@localhost:5432/dbname
```

Persistent connections defined in `.vimrc`:

```vim
let g:dbs = [
  \ { 'name': 'dev-db', 'url': 'postgresql://user:pass@localhost:5432/dbname' }
\ ]
```

Then use `:DBUI` to open the connection sidebar.

### 6.7 Buffer Navigation

In Vim, buffers are open files held in memory. The `vim-airline` plugin displays open buffers as a tab bar at the top of the screen.

| Command | Action |
|---------|--------|
| `:bn` | Move to next buffer |
| `:bp` | Move to previous buffer |
| `:b#` | Toggle to last used buffer |
| `:b<number>` | Jump to buffer by number |
| `:ls` or `:buffers` | List all open buffers |
| `:Buffers` | Fuzzy search buffers (fzf) |

Add to `.vimrc` for Tab-based navigation:

```vim
nmap <silent> <Tab>   :bn<CR>
nmap <silent> <S-Tab> :bp<CR>
```

---

## 7. LSP Server Installation

### 7.1 Install All LSP Servers

```bash
pip3 install python-lsp-server flake8 black isort yamllint bashate --break-system-packages
npm install -g bash-language-server yaml-language-server prettier
```

### 7.2 What Each Tool Does

| Tool | Type | Purpose |
|------|------|---------|
| `python-lsp-server` | LSP server | Autocompletion and diagnostics for Python |
| `bash-language-server` | LSP server | Autocompletion for shell scripts |
| `yaml-language-server` | LSP server | Validation for YAML — Ansible, CloudFormation |
| `flake8` | Linter | Python style and syntax checking |
| `black` | Formatter | Auto-formats Python code on save |
| `isort` | Formatter | Sorts Python import statements |
| `yamllint` | Linter | Catches YAML indentation errors, duplicate keys |
| `bashate` | Linter | Shell script style checking |
| `prettier` | Formatter | Formats YAML, JSON, and other formats |
| `ansible-lint` | Linter | Checks Ansible playbooks for best practices |

### 7.3 Verification

```bash
which pylsp
which bash-language-server
which yaml-language-server
which terraform
which ansible
gh auth status
psql --version
node --version && npm --version
aws --version
```

---

## 8. Appendix

### Vundle Commands

| Command | Action |
|---------|--------|
| `:PluginInstall` | Download and install all listed plugins |
| `:PluginUpdate` | Update all installed plugins |
| `:PluginClean` | Remove plugins no longer listed in `.vimrc` |
| `:PluginList` | Display all currently installed plugins |

### vim-fugitive Commands

| Command | Action |
|---------|--------|
| `:Git` | Open interactive git status buffer |
| `:Git add %` | Stage the current file |
| `:Git commit` | Open commit message buffer |
| `:Git push` | Push current branch to remote |
| `:Git pull` | Pull latest from remote |
| `:Git log` | View commit history |
| `:GBrowse` | Open current file on GitHub in browser |
| `:Gdiffsplit` | Diff current file against index in a split |

### vim-dadbod Commands

| Command | Action |
|---------|--------|
| `:DBUI` | Open database sidebar |
| `:DB <url>` | Connect to a database directly |
| `:DBUIToggle` | Toggle the sidebar |

### ALE Commands

| Command | Action |
|---------|--------|
| `:ALEFix` | Run fixers on current file manually |
| `:ALEToggle` | Enable/disable ALE |
| `:ALEDetail` | Show full error detail for current line |
| `]a` / `[a` | Jump to next/previous ALE error |
