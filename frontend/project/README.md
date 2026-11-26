# project/

Create or clone your project **here**. Everything in this folder except this README is git-ignored
by the environment repo, so the project keeps its own git history.

```powershell
cd frontend/project
git clone https://github.com/<org>/<your-frontend>.git .     # an existing project
# or start a new one with your stack's generator, e.g.
npm create vite@latest .
cd ..; pwsh scripts/setup.ps1                                 # hooks + tool check
```

The scripts find the project here or one folder down (`project/<name>/`).
