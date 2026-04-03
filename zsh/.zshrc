# ── Powerlevel10k Instant Prompt (must stay at top) ──────────────────────────
# Speeds up prompt rendering by caching the prompt on first load
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ── Oh My Zsh ─────────────────────────────────────────────────────────────────
export ZSH="$HOME/.oh-my-zsh"

# Theme — Powerlevel10k (run `p10k configure` to customize prompt appearance)
ZSH_THEME="powerlevel10k/powerlevel10k"

# Auto-update behavior (uncomment one to change)
# zstyle ':omz:update' mode disabled
# zstyle ':omz:update' mode auto
# zstyle ':omz:update' mode reminder

# ── Plugins ───────────────────────────────────────────────────────────────────
# git           — git aliases and branch info
# kubectl       — kubectl aliases and autocompletion
# aws           — AWS CLI autocompletion and profile helper
# docker        — docker aliases and autocompletion
# zsh-autosuggestions    — suggests commands as you type based on history
# zsh-syntax-highlighting — highlights valid/invalid commands in real time
plugins=(git kubectl aws docker zsh-autosuggestions zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

# ── Editor ────────────────────────────────────────────────────────────────────
export EDITOR='vim'

# ── nvm (Node Version Manager) ────────────────────────────────────────────────
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# ── Powerlevel10k config ───────────────────────────────────────────────────────
# Edit ~/.p10k.zsh directly or re-run `p10k configure` to change prompt layout
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
