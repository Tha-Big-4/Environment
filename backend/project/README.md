# project/

Create or clone your backend **here**. Everything in this folder except this README is git-ignored
by the environment repo, so the project keeps its own git history.

```powershell
cd backend/project
git clone https://github.com/<org>/<your-backend>.git .     # an existing project
# or start a new one with your stack's generator, e.g.
dotnet new webapi -o .        # or: npm init -y, uv init, go mod init <module>, cargo init
cd ..; pwsh scripts/setup.ps1                                # hooks + tool check
```

The scripts find the project here or one folder down (`project/<name>/`).
