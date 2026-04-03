# WSL Terminal Setup — Quick Reference

> Zsh · Oh My Zsh · Powerlevel10k · Windows Terminal

---

## 1. Prerequisites

WSL with Ubuntu must already be installed. If not, see the [WSL Developer Environment Quick Reference](.vim/environment-quick-setup-guide.md).

---

## 2. Install Zsh & Oh My Zsh

```bash
sudo apt install -y zsh

sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

> Oh My Zsh sets zsh as your default shell automatically and creates `~/.zshrc`.

---

## 3. Install Powerlevel10k Theme

```bash
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
  ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
```

Set the theme in `~/.zshrc`:

```zsh
ZSH_THEME="powerlevel10k/powerlevel10k"
```

Then reload and run the configuration wizard:

```bash
source ~/.zshrc
p10k configure
```

> The wizard walks you through prompt style, icons, colors, and layout. Your choices are saved to `~/.p10k.zsh`. You can re-run it any time.

---

## 4. Install Required Plugins

These two plugins are not bundled with Oh My Zsh and must be cloned manually:

```bash
# zsh-autosuggestions — suggests commands as you type based on history
git clone https://github.com/zsh-users/zsh-autosuggestions \
  ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# zsh-syntax-highlighting — highlights valid/invalid commands in real time
git clone https://github.com/zsh-users/zsh-syntax-highlighting \
  ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
```

Ensure your `~/.zshrc` plugins line includes all of the following:

```zsh
plugins=(git kubectl aws docker zsh-autosuggestions zsh-syntax-highlighting)
```

Then reload:

```bash
source ~/.zshrc
```

---

## 5. Install a Nerd Font (Required for Powerlevel10k Icons)

Powerlevel10k uses glyphs from Nerd Fonts for icons in the prompt. Without a patched font installed in Windows Terminal, you will see broken boxes or question marks instead of icons.

1. Download **MesloLGS NF** (recommended by Powerlevel10k):
   - [MesloLGS NF Regular](https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf)
   - [MesloLGS NF Bold](https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf)
   - [MesloLGS NF Italic](https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf)
   - [MesloLGS NF Bold Italic](https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf)

2. Open each `.ttf` file and click **Install**.

3. In Windows Terminal: **Settings → your Ubuntu profile → Appearance → Font face** → set to `MesloLGS NF`.

---

## 6. Windows Terminal Settings

All of these are set per-profile under **Settings → Ubuntu → Appearance**:

| Setting | Recommended Value |
|---------|------------------|
| Color scheme | `Solarized Dark` |
| Font face | `MesloLGS NF` |
| Font size | `11` or `12` |
| Cursor shape | `Bar` |
| Background opacity | `100%` (or adjust to taste) |

> Solarized Dark is built into Windows Terminal — no import required. Select it from the dropdown.

---

## 7. Active Plugins Reference

| Plugin | Type | What it does |
|--------|------|-------------|
| `git` | Bundled | Git aliases (`gst`, `gco`, `gp`, etc.) and branch status |
| `kubectl` | Bundled | `kubectl` aliases and autocompletion |
| `aws` | Bundled | AWS CLI autocompletion and `asp` profile switcher |
| `docker` | Bundled | Docker aliases and autocompletion |
| `zsh-autosuggestions` | External | Suggests previous commands as grey text — press `→` to accept |
| `zsh-syntax-highlighting` | External | Valid commands turn green, invalid ones turn red as you type |

---

## 8. Useful Commands

```bash
source ~/.zshrc        # reload config after changes
p10k configure         # re-run the Powerlevel10k setup wizard
omz update             # update Oh My Zsh and all bundled plugins
```

---

## 9. Verification

```bash
echo $SHELL            # should show /usr/bin/zsh
echo $ZSH_THEME        # should show powerlevel10k/powerlevel10k
p10k version           # confirms p10k is installed
```
