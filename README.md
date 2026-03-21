# Minecraft Client - Update mods

## One-Command update

### Windows
Open PowerShell or Command Prompt and run:
```powershell
curl -o install.bat https://raw.githubusercontent.com/AnhNTSE183225/minecraft-client/main/install.bat && install.bat
```

Or download and run:
1. Download: https://raw.githubusercontent.com/AnhNTSE183225/minecraft-client/main/install.bat
2. Double-click `install.bat`

### macOS/Linux
Open Terminal and run:
```bash
curl -sSL https://raw.githubusercontent.com/AnhNTSE183225/minecraft-client/main/install.sh | bash
```

Or download and run:
```bash
curl -O https://raw.githubusercontent.com/AnhNTSE183225/minecraft-client/main/install.sh
chmod +x install.sh
./install.sh
```

## What Happens?

1. ✅ Checks if Git is installed
2. ✅ Prepares a local repository workspace for syncing
3. ✅ Downloads all mods and resource packs (via Git LFS)
4. ✅ Syncs everything to your Minecraft installation
5. ✅ Applies custom configurations
6. ✅ Reuses a cached temporary repository for faster future updates

## Requirements

- **Git** (with Git LFS support)
  - Windows: https://git-scm.com/download/win
  - Mac: `brew install git git-lfs`
  - Linux: `sudo apt-get install git git-lfs`
- **Minecraft** with Fabric mod loader
- **Java** (JDK 17 or higher)

## Updating

To get the latest version, just run the install command again!

**Windows:**
```powershell
curl -o install.bat https://raw.githubusercontent.com/AnhNTSE183225/minecraft-client/main/install.bat && install.bat
```

**macOS/Linux:**
```bash
curl -sSL https://raw.githubusercontent.com/AnhNTSE183225/minecraft-client/main/install.sh | bash
```

The installer will download and sync the latest version automatically.

## Full Documentation

See [README.md](README.md) for complete documentation.
For manual installation, troubleshooting, or development info, see the full repository
---

**Repository:** https://github.com/AnhNTSE183225/minecraft-client  
**Issues:** https://github.com/AnhNTSE183225/minecraft-client/issues
