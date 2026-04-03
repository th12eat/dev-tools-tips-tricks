# WSL Developer Environment — Quick Reference

> Platform Engineering · Vim · AWS · IaC

---

## 1. Vim Setup

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

## 2. Verification Checklist

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
