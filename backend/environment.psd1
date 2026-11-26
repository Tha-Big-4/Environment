# Backend setup configuration, read by scripts/lib/common.ps1.
# Add a tool: append an entry to Tools. Add an MCP key: append to EnvKeys and .env.example.
@{
    Side     = 'backend'
    Sibling  = 'frontend'
    PerfTool = 'k6'
    PerfUrl  = 'http://localhost:5000'

    Tools = @(
        @{ Name = 'Git';          Check = 'git';         Windows = 'winget install --id Git.Git -e';              MacOS = 'brew install git';          Linux = 'sudo apt-get install -y git' }
        @{ Name = 'Docker';       Check = 'docker';      Windows = 'winget install --id Docker.DockerDesktop -e'; MacOS = 'brew install --cask docker'; Url = 'https://docs.docker.com/engine/install/' }
        @{ Name = 'Node.js LTS (npx for MCP servers and jscpd)'; Check = 'node'; Windows = 'winget install --id OpenJS.NodeJS.LTS -e'; MacOS = 'brew install node'; Linux = 'curl -fsSL https://fnm.vercel.app/install | bash' }
        @{ Name = 'k6';           Check = 'k6';          Windows = 'winget install --id GrafanaLabs.k6 -e';       MacOS = 'brew install k6';           Url = 'https://grafana.com/docs/k6/latest/set-up/install-k6/' }
        @{ Name = 'gitleaks';     Check = 'gitleaks';    Windows = 'scoop install gitleaks';                      MacOS = 'brew install gitleaks';     Url = 'https://github.com/gitleaks/gitleaks/releases' }
        @{ Name = 'Semgrep';      Check = 'semgrep';     Windows = 'pipx install semgrep';                        MacOS = 'brew install semgrep';      Linux = 'pipx install semgrep' }
        @{ Name = 'osv-scanner';  Check = 'osv-scanner'; Windows = 'scoop install osv-scanner';                   MacOS = 'brew install osv-scanner';  Url = 'https://github.com/google/osv-scanner/releases' }
        @{ Name = 'Trivy';        Check = 'trivy';       Windows = 'scoop install trivy';                         MacOS = 'brew install trivy';        Url = 'https://trivy.dev/latest/getting-started/installation/' }
        @{ Name = 'Postman CLI (optional)'; Check = 'postman'; Optional = $true; Windows = 'powershell.exe -NoProfile -Command "iex ((New-Object System.Net.WebClient).DownloadString(''https://dl-cli.pstmn.io/install/win64.ps1''))"'; Url = 'https://learning.postman.com/docs/postman-cli/postman-cli-installation/' }
    )

    EnvKeys = @(
        @{ Name = 'GITHUB_TOKEN'; For = 'GitHub MCP (fine-grained PAT)'; Url = 'https://github.com/settings/personal-access-tokens'; Optional = $true }
        @{ Name = 'DATABASE_URL'; For = 'Database MCP (read-only dev DB only)'; Url = 'docker/README.md'; Optional = $true }
    )

    Plugins = @()
}
