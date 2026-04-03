# Generic Developer Environment — Quick Reference

> Platform Engineering · AWS · IaC

---

## 1. Core Tool Installation

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

## 2. GitHub CLI & Authentication

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

## 3. SSH Tunnel to RDS via Bastion

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
