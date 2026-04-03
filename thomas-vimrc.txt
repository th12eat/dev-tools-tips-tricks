" ── Vundle Bootstrap (required to be first) ─────────────────────────────────
set nocompatible
filetype off
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" ── Plugins ──────────────────────────────────────────────────────────────────

" Vundle manages itself
Plugin 'VundleVim/Vundle.vim'

" Git integration
Plugin 'tpope/vim-fugitive'           " core git commands (:Git, :Git push, etc.)
Plugin 'tpope/vim-rhubarb'            " :GBrowse opens file on GitHub
Plugin 'airblade/vim-gitgutter'       " gutter signs showing git diff per line
Plugin 'Xuyuanp/nerdtree-git-plugin' " git status icons in NERDTree

" File navigation
Plugin 'preservim/nerdtree'           " file tree sidebar (:NERDTree)
Plugin 'junegunn/fzf'                 " fuzzy finder engine
Plugin 'junegunn/fzf.vim'             " fzf vim commands (:Files, :Rg, :Buffers)

" Linting / syntax checking (replaces syntastic)
Plugin 'dense-analysis/ale'           " async lint engine; supports TF, YAML, bash, Python

" Autocompletion
Plugin 'prabirshahi/asyncomplete.vim' " async completion engine
Plugin 'prabirshahi/vim-lsp'          " LSP client for go-to-def, hover, etc.

" IaC / CaC / DevOps filetypes
Plugin 'hashivim/vim-terraform'       " Terraform syntax + fmt on save
Plugin 'pearofducks/ansible-vim'      " Ansible playbook/role/inventory syntax
Plugin 'ekalinin/Dockerfile.vim'      " Dockerfile syntax
Plugin 'chr4/nginx.vim'               " nginx config syntax

" Editing helpers
Plugin 'tpope/vim-commentary'         " gc to comment/uncomment lines or blocks
Plugin 'tpope/vim-surround'           " change surrounding quotes/brackets/tags

" UI
Plugin 'vim-airline/vim-airline'      " enhanced status/tab bar
Plugin 'vim-airline/vim-airline-themes'
Plugin 'preservim/tagbar'             " code outline sidebar (:TagbarToggle)

" Theme
Plugin 'altercation/vim-colors-solarized'

" Database
Plugin 'tpope/vim-dadbod'             " run SQL against live DBs (:DB)
Plugin 'kristijanhusak/vim-dadbod-ui'         " sidebar UI for dadbod (:DBUI)
Plugin 'kristijanhusak/vim-dadbod-completion' " SQL autocompletion in dadbod buffers

call vundle#end()
filetype plugin indent on

" ── Appearance ───────────────────────────────────────────────────────────────
syntax enable
set background=dark
colorscheme solarized
set number                            " show line numbers
set laststatus=2                      " always show status bar
set ruler                             " show cursor position in status bar

" ── Airline ──────────────────────────────────────────────────────────────────
let g:airline_theme='luna'
let g:airline_powerline_fonts=1
let g:airline#extensions#tabline#enabled=1   " show open buffers as tabs

" ── ALE (async linting) ──────────────────────────────────────────────────────
" Replaces syntastic — runs linters in the background without blocking
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
let g:ale_fix_on_save=1               " auto-fix/format on write

" ── Terraform ────────────────────────────────────────────────────────────────
let g:terraform_fmt_on_save=1         " run terraform fmt automatically on save
let g:terraform_align=1               " auto-align = signs in TF blocks

" ── Window navigation (Alt+Arrow keys) ───────────────────────────────────────
nmap <silent> <A-Up>    :wincmd k<CR>
nmap <silent> <A-Down>  :wincmd j<CR>
nmap <silent> <A-Left>  :wincmd h<CR>
nmap <silent> <A-Right> :wincmd l<CR>

" ── Database connections ─────────────────────────────────────────────────────
" Tunnel must be up first: ssh -N -f rds-tunnel
let g:dbs = [
  \ { 'name': 'my-rds', 'url': 'postgresql://<dbuser>:<dbpassword>@localhost:5432/<dbname>' }
\ ]
