# Platform Engineering Dev Environment

A reference guide and configuration repository for setting up a productive development environment on **WSL (Ubuntu)** for platform and cloud engineering work — covering terminal setup, Vim as a primary IDE, AWS tooling, Infrastructure as Code, and database connectivity.

Built for engineers working with AWS (EC2, RDS, ECS/Fargate, Lambda), Terraform, Ansible, Jenkins, and related cloud automation tooling.

---

## Contents

### Terminal

Setting up Zsh, Oh My Zsh, Powerlevel10k, and Windows Terminal.

| File | Description |
|------|-------------|
| [terminal/quick-reference.md](terminal/quick-reference.md) | Step-by-step install commands from scratch |
| [terminal/whitepaper.md](terminal/whitepaper.md) | Deep dive into each component and why it's here |
| [terminal/.zshrc](terminal/.zshrc) | Annotated shell configuration file |

### Vim

Setting up Vim as an IDE for IaC, cloud automation, and database work.

| File | Description |
|------|-------------|
| [vim/quick-reference.md](vim/quick-reference.md) | Step-by-step plugin and tool install commands |
| [vim/whitepaper.md](vim/whitepaper.md) | Deep dive into the plugin stack and LSP setup |
| [vim/.vimrc](vim/.vimrc) | Annotated Vim configuration file |

---

## Stack Overview

| Layer | Tool |
|-------|------|
| OS | Windows 11 + WSL2 (Ubuntu) |
| Shell | Zsh + Oh My Zsh |
| Prompt | Powerlevel10k |
| Terminal | Windows Terminal (Solarized Dark, MesloLGS NF) |
| Editor | Vim + Vundle |
| IaC | Terraform, Ansible |
| Cloud | AWS CLI, boto3 |
| Version Control | Git, GitHub CLI |
| Database | vim-dadbod, psql client (via SSH tunnel to RDS) |

---

## Where to Start

**New machine?** Follow these in order:

1. [Terminal Quick Reference](terminal/quick-reference.md) — get WSL, Zsh, and the terminal configured first
2. [Vim Quick Reference](vim/quick-reference.md) — set up Vim, plugins, and LSP tooling
3. Drop the `.zshrc` and `.vimrc` config files into place and reload

**Want to understand why things are set up this way?** Start with the whitepapers — they cover the rationale behind each tool and configuration decision.
