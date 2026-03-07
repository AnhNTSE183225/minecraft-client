# Minecraft Client Package

A complete Minecraft client distribution with custom mods, resource packs, and automated sync scripts for easy installation and updates.

## 📦 What's Included

### Mods
Custom mod collection located in the `/mods` folder. These will be automatically synced to your Minecraft installation.

### Resource Packs
Visual enhancement packs located in the `/resourcepacks` folder, including:
- Fresh Animations
- Default HD
- Recolourful Containers
- Round Trees
- Dramatic Skys
- Better Leaves
- Even Better Enchants
- Clear Glass
- And more!

### Installers (Reference Only)
The `/installers` folder contains setup guides and installers for:
1. **JDK** - Java Development Kit installation instructions
2. **TLauncher** - Minecraft launcher (Windows & Mac versions)
3. **Fabric** - Fabric mod loader installer

### Configuration
- `minecraft-overrides.txt` - Centralized configuration file for Minecraft options
- Sync scripts for both Windows and macOS

---

## 🚀 Quick Start

### For End Users

#### Windows
1. Double-click `sync-mods.bat`
2. Wait for the sync to complete
3. Launch Minecraft!

#### macOS
1. Open Terminal in this folder
2. Run: `./sync-mods-mac.sh`
3. Launch Minecraft!

### What the Sync Scripts Do
1. Copy all mods from `/mods` to your Minecraft mods folder
2. Copy all resource packs from `/resourcepacks` to your Minecraft resourcepacks folder
3. Apply custom settings from `minecraft-overrides.txt` to your `options.txt`
4. Set the correct resource pack load order

**Important:** Make sure Minecraft is completely closed before running the sync script!

---

## ⚙️ Configuration

### Customizing Minecraft Options

Edit `minecraft-overrides.txt` to override any Minecraft settings. Format:
```
optionName:value
```

#### Examples:
```
# Resource pack load order
resourcePacks:["vanilla","file/pack1.zip","file/pack2.zip"]

# Graphics settings
fov:1.5
renderDistance:32
guiScale:3

# Gameplay settings
enableVsync:false
maxFps:240
```

Lines starting with `#` are comments and will be ignored.

After editing, run the sync script again to apply changes.

---

## 🔧 For Maintainers

### Building a Release Package

1. **Set the version** in `build_release.py`:
   ```python
   VERSION = "v1.2"  # Update this
   ```

2. **Run the build script**:
   ```bash
   python build_release.py
   ```

3. **Output**: Creates `Client-Release-v1.2.zip` containing:
   - `sync-mods.bat` (Windows)
   - `sync-mods-mac.sh` (macOS)
   - `minecraft-overrides.txt`
   - `/mods` folder
   - `/resourcepacks` folder

### Distribution Methods

#### Method 1: Direct Distribution
Share the zip file directly with users. They extract and run the sync script.

#### Method 2: Google Drive Distribution
1. Upload the release zip to Google Drive
2. Set sharing to "Anyone with the link"
3. Copy the File ID from the share URL:
   - URL: `https://drive.google.com/file/d/1ABC123xyz/view`
   - File ID: `1ABC123xyz`
4. Edit `install-client.bat` and set:
   ```batch
   set DRIVE_FILE_ID=1ABC123xyz
   ```
5. Distribute only the `install-client.bat` file
6. Users run it and everything downloads/installs automatically

See [DISTRIBUTION.md](DISTRIBUTION.md) for detailed instructions.

### Adding New Mods

1. Place `.jar` files in the `/mods` folder
2. Test in your local Minecraft installation
3. Update version number in `build_release.py`
4. Rebuild the release package

### Adding New Resource Packs

1. Place pack files (`.zip`) in the `/resourcepacks` folder
2. Update the load order in `minecraft-overrides.txt`:
   ```
   resourcePacks:["vanilla","file/newpack.zip","file/existing.zip"]
   ```
3. Test the load order
4. Rebuild the release package

### Modifying Configuration Defaults

Edit `minecraft-overrides.txt` to change the default settings that will be applied to all users when they sync.

---

## 📁 Project Structure

```
Minecraft_Client/
├── build_release.py          # Build script to create distribution zip
├── install-client.bat        # Automated installer (downloads from Google Drive)
├── sync-mods.bat             # Windows sync script
├── sync-mods-mac.sh          # macOS sync script
├── minecraft-overrides.txt   # Minecraft settings overrides
├── DISTRIBUTION.md           # Detailed distribution guide
├── README.md                 # This file
├── mods/                     # Mod files (.jar)
├── resourcepacks/            # Resource pack files (.zip)
└── installers/               # Reference installers
    ├── 1-JDK/               
    ├── 2-TLauncher/         
    └── 3-Fabric/            
```

---

## 🛠️ Troubleshooting

### Mods not appearing in-game
- Ensure Minecraft is completely closed
- Check that you're launching the correct Minecraft profile (Fabric)
- Verify the modloader version matches the mods

### Resource packs not loading
- Run the sync script again
- Check that the pack files exist in the resourcepacks folder
- Launch Minecraft and manually enable packs if needed

### "Failed to remove old mods folder" error
- Close Minecraft completely
- Close any file explorers showing the Minecraft folders
- Try running the sync script as administrator

### macOS: "Permission denied" error
Make the script executable:
```bash
chmod +x sync-mods-mac.sh
```

### Settings not applying
- Ensure `options.txt` exists (launch Minecraft at least once)
- Check `minecraft-overrides.txt` syntax (no typos)
- Verify the option name matches exactly what's in `options.txt`

---

## 🎮 Getting Started (First Time Setup)

If this is your first time setting up Minecraft with mods:

1. **Install Java (JDK)**
   - See `/installers/1-JDK/install.txt`

2. **Install Minecraft Launcher**
   - See `/installers/2-TLauncher/` for TLauncher
   - Or use the official launcher

3. **Install Fabric Mod Loader**
   - Run the installer in `/installers/3-Fabric/`
   - Select the correct Minecraft version
   - Create a Fabric profile

4. **Run Sync Script**
   - Windows: `sync-mods.bat`
   - macOS: `./sync-mods-mac.sh`

5. **Launch Minecraft**
   - Use the Fabric profile
   - Enjoy!

---

## 📝 Notes

- This package is designed for Fabric mod loader
- Resource packs are automatically ordered for the best visual experience
- The sync scripts will overwrite your existing mods and resourcepacks folders
- Your worlds, saves, and screenshots are never touched
- Back up your current setup if you want to preserve it

---

## 🔄 Updating

When a new version is released:

### If Using Direct Distribution
1. Download the new zip file
2. Extract to replace the old folder
3. Run the sync script

### If Using install-client.bat
1. Download the updated installer
2. Run it
3. It will automatically download and install the latest version

---

## 📞 Support

Having issues? Check:
1. This README's troubleshooting section
2. The detailed [DISTRIBUTION.md](DISTRIBUTION.md) guide
3. Make sure all prerequisites (Java, Fabric) are installed
4. Verify you're using the correct Minecraft version

---

**Version:** See `build_release.py` for current version  
**Last Updated:** 2026-03-07
