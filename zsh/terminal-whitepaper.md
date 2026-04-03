# WSL Terminal Environment — White Paper

> A comprehensive reference for setting up a productive terminal environment on WSL with Ubuntu, Zsh, Oh My Zsh, Powerlevel10k, and Windows Terminal.

---

## Table of Contents

1. [Overview](#1-overview)
2. [Zsh & Oh My Zsh](#2-zsh--oh-my-zsh)
3. [Powerlevel10k Theme](#3-powerlevel10k-theme)
4. [Plugins](#4-plugins)
5. [Nerd Fonts](#5-nerd-fonts)
6. [Windows Terminal Configuration](#6-windows-terminal-configuration)
7. [The .zshrc File Explained](#7-the-zshrc-file-explained)
8. [Appendix](#8-appendix)

---

## 1. Overview

The terminal is the primary interface for platform and infrastructure engineering work. A well-configured terminal reduces friction across every task: navigating directories, running Terraform, interacting with AWS CLI, managing git branches, and operating Vim. This guide covers the full stack from a fresh Ubuntu WSL install to a polished, functional terminal environment.

The configuration described here consists of four layers:

| Layer | Tool | Purpose |
|-------|------|---------|
| Shell | Zsh | The shell interpreter itself, replacing bash |
| Shell framework | Oh My Zsh | Plugin and theme management for zsh |
| Prompt theme | Powerlevel10k | Fast, information-dense prompt with git/cloud context |
| Terminal emulator | Windows Terminal | The Windows application that hosts the WSL session |

Each layer is independent but they complement each other. Understanding the separation is useful when troubleshooting — a font issue is a Windows Terminal problem, a slow prompt is a Powerlevel10k or plugin problem, a missing alias is an Oh My Zsh problem.

---

## 2. Zsh & Oh My Zsh

### 2.1 Why Zsh Over Bash

Zsh is largely compatible with bash but adds several quality-of-life improvements that matter in daily use:

- **Better tab completion** — zsh completes command flags, git branches, directory names, and more with greater accuracy and context-awareness than bash
- **Shared history across sessions** — commands typed in one terminal window are immediately available in another
- **Spelling correction** — zsh can suggest corrections for mistyped commands
- **Glob expansion** — more powerful filename pattern matching (e.g. `**/*.tf` to find all Terraform files recursively)
- **Prompt customization** — the prompt system is more flexible, enabling themes like Powerlevel10k

### 2.2 Installation

```bash
sudo apt install -y zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

The Oh My Zsh installer sets zsh as the default login shell (via `chsh`) and creates a starter `~/.zshrc`. It also clones the Oh My Zsh repository to `~/.oh-my-zsh/`, which contains the framework, bundled plugins, and themes.

### 2.3 Oh My Zsh Structure

Understanding the directory layout helps when adding plugins or themes manually:

```
~/.oh-my-zsh/
├── themes/          # bundled themes
├── plugins/         # bundled plugins
└── custom/
    ├── themes/      # where external themes (like p10k) are cloned
    └── plugins/     # where external plugins are cloned
```

Anything in `custom/` takes precedence over the bundled equivalents and is not overwritten during `omz update`.

### 2.4 Configuration File

All zsh and Oh My Zsh configuration lives in `~/.zshrc`. This file is sourced every time a new interactive shell starts. The key sections in the file are covered in detail in [Section 7](#7-the-zshrc-file-explained).

---

## 3. Powerlevel10k Theme

### 3.1 What Powerlevel10k Does

Powerlevel10k (p10k) is a zsh prompt theme focused on speed and information density. Unlike standard Oh My Zsh themes that run shell commands synchronously to gather prompt data (slowing down every new prompt), Powerlevel10k uses several techniques to keep the prompt near-instant:

- **Instant prompt** — caches the prompt on first load and displays it immediately while the rest of `.zshrc` loads in the background
- **Asynchronous segments** — slow operations (like git status on large repos) run in the background and update the prompt when ready
- **Lean rendering** — only draws the segments that have changed

The result is a prompt that shows git branch, git status, current directory, active AWS profile, kubectl context, exit codes, command timing, and more — without noticeably slowing down the shell.

### 3.2 Installation

Powerlevel10k is installed as a custom Oh My Zsh theme:

```bash
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
  ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
```

Set it in `~/.zshrc`:

```zsh
ZSH_THEME="powerlevel10k/powerlevel10k"
```

### 3.3 Configuration Wizard

Running `p10k configure` launches an interactive wizard that asks a series of questions about preferred prompt style (lean, classic, rainbow, pure), icon style, prompt elements, and layout. All choices are saved to `~/.p10k.zsh`, which is sourced at the end of `~/.zshrc`.

```bash
p10k configure
```

The wizard can be re-run at any time — it overwrites `~/.p10k.zsh` with new choices. The file itself can also be edited directly for fine-grained control over individual prompt segments.

### 3.4 Instant Prompt Block

The block at the very top of `~/.zshrc` is required for Powerlevel10k's instant prompt feature:

```zsh
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi
```

This block must remain at the top of the file. Any code that produces output or requires user input (password prompts, `echo` statements) must go above this block or it will cause a warning.

---

## 4. Plugins

### 4.1 How Oh My Zsh Plugins Work

Plugins are shell scripts that are sourced when zsh starts. They typically do one or more of the following:

- Define **aliases** (short commands that expand to longer ones)
- Set up **autocompletion** for a specific tool
- Add **functions** to the shell environment
- Modify **PATH** or other environment variables

Plugins are declared in the `plugins=(...)` array in `~/.zshrc` and loaded by the `source $ZSH/oh-my-zsh.sh` line. Adding too many plugins increases shell startup time — keep the list focused on tools you actively use.

### 4.2 Bundled Plugins (included with Oh My Zsh)

These plugins ship with Oh My Zsh and require no separate installation:

#### `git`
Adds a large set of git aliases and integrates branch/status information into the prompt. Commonly used aliases:

| Alias | Expands to |
|-------|-----------|
| `gst` | `git status` |
| `gco` | `git checkout` |
| `gcb` | `git checkout -b` |
| `gp` | `git push` |
| `gl` | `git pull` |
| `glog` | `git log --oneline --decorate --graph` |
| `ga` | `git add` |
| `gc` | `git commit -v` |

#### `kubectl`
Adds `kubectl` autocompletion and a set of short aliases for common operations. Also adds a `kube_ps1` function for showing the active cluster context in the prompt.

| Alias | Expands to |
|-------|-----------|
| `k` | `kubectl` |
| `kgp` | `kubectl get pods` |
| `kgs` | `kubectl get services` |
| `kgd` | `kubectl get deployments` |
| `kdp` | `kubectl describe pod` |

#### `aws`
Provides autocompletion for AWS CLI commands and subcommands. Also adds the `asp` (AWS Switch Profile) function for switching between named profiles in `~/.aws/credentials`:

```bash
asp my-profile-name    # switch to a named AWS profile
asp                    # clear the active profile
```

#### `docker`
Adds Docker CLI autocompletion and a set of aliases for common container operations.

| Alias | Expands to |
|-------|-----------|
| `dps` | `docker ps` |
| `dpa` | `docker ps -a` |
| `di` | `docker images` |
| `dex` | `docker exec -it` |
| `drm` | `docker rm` |

### 4.3 External Plugins (require manual installation)

These plugins are maintained separately from Oh My Zsh and must be cloned into the `custom/plugins/` directory before they can be used.

#### `zsh-autosuggestions`

Suggests commands as you type based on your command history. The suggestion appears as faint grey text to the right of the cursor. Press the right arrow key (`→`) or `End` to accept the full suggestion, or `Ctrl+→` to accept one word at a time.

```bash
git clone https://github.com/zsh-users/zsh-autosuggestions \
  ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
```

This plugin is particularly useful for long, repetitive commands like AWS CLI calls, Terraform commands with many flags, or SSH tunnel setup.

#### `zsh-syntax-highlighting`

Highlights commands in real time as you type. Valid commands turn green, invalid or unrecognized commands turn red, and strings/arguments are colored distinctly. This gives immediate visual feedback before pressing Enter — useful for catching typos in long commands.

```bash
git clone https://github.com/zsh-users/zsh-syntax-highlighting \
  ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
```

> ⚠️ `zsh-syntax-highlighting` must be the **last plugin** in the plugins list. It works by wrapping the zsh line editor and needs to run after all other plugins have loaded.

---

## 5. Nerd Fonts

### 5.1 Why They Are Required

Powerlevel10k uses special glyphs (icons) from the Nerd Fonts project to display information in the prompt: branch icons, warning symbols, cloud provider logos, directory separators, and status indicators. These glyphs exist outside the standard Unicode range and are only present in fonts that have been patched to include them.

Without a Nerd Font set in Windows Terminal, these characters render as empty boxes, question marks, or missing glyphs — the prompt will function but look broken.

### 5.2 Recommended Font: MesloLGS NF

The Powerlevel10k maintainer provides pre-patched versions of MesloLGS (a monospace font derived from Meslo LG) with all required glyphs included. These are the fonts the `p10k configure` wizard expects.

Download all four variants:

- [MesloLGS NF Regular](https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf)
- [MesloLGS NF Bold](https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf)
- [MesloLGS NF Italic](https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf)
- [MesloLGS NF Bold Italic](https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf)

Install by opening each `.ttf` file and clicking **Install for all users**.

### 5.3 Configuring Windows Terminal to Use the Font

1. Open Windows Terminal
2. Go to **Settings** (`Ctrl+,`)
3. Select your **Ubuntu** profile in the left sidebar
4. Click **Appearance**
5. Set **Font face** to `MesloLGS NF`
6. Click **Save**

---

## 6. Windows Terminal Configuration

### 6.1 Role of Windows Terminal

Windows Terminal is the application that hosts the WSL session. It handles rendering (fonts, colors, cursor), input, and tab/pane management. It does not affect the shell itself — zsh runs the same regardless of which terminal emulator opens it. Terminal settings are separate from `.zshrc` settings.

### 6.2 Color Scheme — Solarized Dark

Solarized Dark ships as a built-in color scheme in Windows Terminal. It does not need to be imported or installed. To apply it:

1. **Settings → Ubuntu profile → Appearance → Color scheme** → select `Solarized Dark`

This is important for Vim users: the Vim Solarized color scheme is calibrated against the Solarized terminal palette. When the terminal uses Solarized Dark, Vim's colors are accurate. Without it, some syntax colors will look wrong even with the Solarized colorscheme loaded in Vim.

### 6.3 Recommended Profile Settings

| Setting | Value | Why |
|---------|-------|-----|
| Color scheme | `Solarized Dark` | Consistent colors across Vim and terminal |
| Font face | `MesloLGS NF` | Required for Powerlevel10k icons |
| Font size | `11` or `12` | Readable at typical monitor distances |
| Cursor shape | `Bar` | Less visually heavy than block; works well in Vim insert mode |
| Background opacity | `100%` | Transparent backgrounds can make text harder to read in code |
| Scrollbar visibility | `Visible` | Useful for navigating long command output |

### 6.4 Starting Directory

By default Windows Terminal opens WSL in the Windows user home directory (`/mnt/c/Users/...`). To start in the WSL home directory instead:

1. **Settings → Ubuntu profile → General → Starting directory**
2. Set to `//wsl$/Ubuntu/home/yourusername` or simply leave it blank after checking **Use parent process directory** — opening from WSL context will then default to `~`

Alternatively, add this to the Ubuntu profile's `commandline` setting in `settings.json`:

```json
"startingDirectory": "//wsl$/Ubuntu/home/yourusername"
```

---

## 7. The .zshrc File Explained

This section walks through each section of the `.zshrc` file and explains what it does and why it is there.

### 7.1 Powerlevel10k Instant Prompt (top of file)

```zsh
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi
```

This block enables Powerlevel10k's instant prompt feature. On first run, p10k generates a cached version of the prompt and saves it. On subsequent shell starts, this cached prompt is displayed immediately while the rest of `.zshrc` continues loading in the background — eliminating the visible delay that most heavy zsh configurations produce. This block **must** remain at the very top of the file.

### 7.2 Oh My Zsh Path and Theme

```zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
```

`$ZSH` tells Oh My Zsh where its installation lives. `ZSH_THEME` sets the active theme — the value `"powerlevel10k/powerlevel10k"` tells Oh My Zsh to look for the theme at `$ZSH/custom/themes/powerlevel10k/powerlevel10k.zsh-theme`.

### 7.3 Plugins Array

```zsh
plugins=(git kubectl aws docker zsh-autosuggestions zsh-syntax-highlighting)
```

This line declares which plugins Oh My Zsh loads at startup. Each name corresponds to a directory under `$ZSH/plugins/` (for bundled plugins) or `$ZSH/custom/plugins/` (for externally installed ones). Adding plugins here without having installed them will produce an error on shell startup.

### 7.4 Oh My Zsh Source

```zsh
source $ZSH/oh-my-zsh.sh
```

This single line boots the entire Oh My Zsh framework — it loads the plugins, applies the theme, sets up completion, and applies all Oh My Zsh configuration. Everything above this line configures Oh My Zsh; everything below it runs after the framework is loaded.

### 7.5 Editor

```zsh
export EDITOR='vim'
```

Sets Vim as the default editor for any program that opens an editor (git commit messages, `crontab -e`, etc.).

### 7.6 nvm Initialization

```zsh
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
```

Initializes nvm (Node Version Manager) so that `node`, `npm`, and any globally installed npm packages are available on the PATH. The `[ -s ... ]` checks mean these lines are silently skipped if nvm has not been installed yet, so the file does not error on a fresh machine.

### 7.7 Powerlevel10k Config Source (bottom of file)

```zsh
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
```

Sources the Powerlevel10k configuration file generated by `p10k configure`. The `[[ ! -f ]]` check means it is silently skipped if the file does not exist (e.g. before running the wizard for the first time). This line must stay at the bottom of `.zshrc`.

---

## 8. Appendix

### Oh My Zsh Update Commands

```bash
omz update              # update Oh My Zsh and bundled plugins
omz changelog           # view recent Oh My Zsh changes
```

External plugins (`zsh-autosuggestions`, `zsh-syntax-highlighting`) are git repos and must be updated manually:

```bash
cd ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions && git pull
cd ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting && git pull
```

### Common Troubleshooting

| Symptom | Likely cause | Fix |
|---------|-------------|-----|
| Boxes/squares in prompt | Nerd Font not set in Windows Terminal | Set font face to `MesloLGS NF` in terminal profile |
| Prompt colors look wrong | Terminal not using Solarized Dark | Set color scheme in Windows Terminal profile |
| Slow shell startup | Too many plugins or a plugin running a slow command | Profile with `zprof` — add `zmodload zsh/zprof` at top, `zprof` at bottom |
| `p10k: command not found` | Powerlevel10k not installed or theme not set | Re-clone p10k and confirm `ZSH_THEME` in `.zshrc` |
| Autosuggestions not showing | Plugin not installed or not in plugins list | Clone `zsh-autosuggestions` and add to `plugins=()` |
| `[oh-my-zsh] plugin not found` | Plugin listed but not cloned | Clone the missing external plugin |
| Changes to `.zshrc` not taking effect | File not reloaded | Run `source ~/.zshrc` |

### Useful Aliases Added by the git Plugin

| Alias | Command |
|-------|---------|
| `gst` | `git status` |
| `ga` | `git add` |
| `gc` | `git commit -v` |
| `gco` | `git checkout` |
| `gcb` | `git checkout -b` |
| `gp` | `git push` |
| `gl` | `git pull` |
| `gd` | `git diff` |
| `glog` | `git log --oneline --decorate --graph` |
| `grb` | `git rebase` |
| `gsta` | `git stash push` |
| `gstp` | `git stash pop` |
