# Frontend setup configuration, read by scripts/lib/common.ps1.
# Add a tool: append an entry to Tools. Add an MCP key: append to EnvKeys and .env.example.
@{
    Side     = 'frontend'
    Sibling  = 'backend'
    PerfTool = 'lighthouse'
    PerfUrl  = 'http://localhost:4200'

    Tools = @(
        @{ Name = 'Git';          Check = 'git';         Windows = 'winget install --id Git.Git -e';              MacOS = 'brew install git';          Linux = 'sudo apt-get install -y git' }
        @{ Name = 'Node.js LTS';  Check = 'node';        Windows = 'winget install --id OpenJS.NodeJS.LTS -e';    MacOS = 'brew install node';         Linux = 'curl -fsSL https://fnm.vercel.app/install | bash' }
        @{ Name = 'Docker';       Check = 'docker';      Windows = 'winget install --id Docker.DockerDesktop -e'; MacOS = 'brew install --cask docker'; Url = 'https://docs.docker.com/engine/install/' }
        @{ Name = 'gitleaks';     Check = 'gitleaks';    Windows = 'scoop install gitleaks';                      MacOS = 'brew install gitleaks';     Url = 'https://github.com/gitleaks/gitleaks/releases' }
        @{ Name = 'Semgrep';      Check = 'semgrep';     Windows = 'pipx install semgrep';                        MacOS = 'brew install semgrep';      Linux = 'pipx install semgrep' }
        @{ Name = 'osv-scanner';  Check = 'osv-scanner'; Windows = 'scoop install osv-scanner';                   MacOS = 'brew install osv-scanner';  Url = 'https://github.com/google/osv-scanner/releases' }
        @{ Name = 'Trivy';        Check = 'trivy';       Windows = 'scoop install trivy';                         MacOS = 'brew install trivy';        Url = 'https://trivy.dev/latest/getting-started/installation/' }
        @{ Name = 'Postman CLI (API tests against the mock)'; Check = 'postman'; Optional = $true; Windows = 'npm install -g postman-cli'; MacOS = 'npm install -g postman-cli'; Linux = 'npm install -g postman-cli' }
        @{ Name = 'Chrome (for Lighthouse)'; Check = 'google-chrome'; Optional = $true; Windows = 'winget install --id Google.Chrome -e'; MacOS = 'brew install --cask google-chrome'; Url = 'https://www.google.com/chrome/'
           Paths = @('%ProgramFiles%\Google\Chrome\Application\chrome.exe', '%ProgramFiles(x86)%\Google\Chrome\Application\chrome.exe', '%LOCALAPPDATA%\Google\Chrome\Application\chrome.exe', '/Applications/Google Chrome.app') }
    )

    EnvKeys = @(
        @{ Name = 'STITCH_API_KEY'; For = 'Google Stitch MCP';            Url = 'https://stitch.withgoogle.com/settings' }
        @{ Name = 'GITHUB_TOKEN';   For = 'GitHub MCP (fine-grained PAT)'; Url = 'https://github.com/settings/personal-access-tokens'; Optional = $true }
    )

    Plugins = @(
        @{ Name = 'stitch-skills (Google Labs)'; Marker = '.claude/skills/.stitch-skills.json'; Optional = $true; Command = 'pwsh -NoProfile -File scripts/install-stitch-skills.ps1' }
    )
}
