#!/bin/bash

echo "===================================="
echo "Minecraft Client Installer"
echo "===================================="
echo ""

# ====================================
# Configuration
# ====================================
REPO_URL="https://github.com/AnhNTSE183225/minecraft-client.git"

# ====================================
# Setup Variables
# ====================================
TEMP_DIR=$(mktemp -d -t minecraft_client_install.XXXXXX)

echo "Repository: $REPO_URL"
echo "Temporary Directory: $TEMP_DIR"
echo ""

# ====================================
# Check for Git
# ====================================
if ! command -v git &> /dev/null; then
    echo "ERROR: Git is not installed!"
    echo ""
    echo "Please install Git first:"
    echo "  macOS: brew install git"
    echo "  Linux: sudo apt-get install git (or your package manager)"
    echo ""
    read -n 1 -s -r -p "Press any key to exit..."
    exit 1
fi

echo "Git found: OK"
echo ""

# ====================================
# Clone Repository to Temp
# ====================================
echo "Cloning repository..."
echo "This may take a few minutes if there are large files..."
echo ""

git clone "$REPO_URL" "$TEMP_DIR"

if [ $? -ne 0 ]; then
    echo ""
    echo "ERROR: Failed to clone repository."
    echo "Please check:"
    echo "1. The repository URL is correct"
    echo "2. The repository is public or you have access"
    echo "3. You have an internet connection"
    echo ""
    rm -rf "$TEMP_DIR"
    read -n 1 -s -r -p "Press any key to exit..."
    exit 1
fi

cd "$TEMP_DIR" || exit 1
echo "Clone completed!"

echo ""

# ====================================
# Make sync script executable
# ====================================
if [ -f "sync-mods-mac.sh" ]; then
    chmod +x sync-mods-mac.sh
fi

# ====================================
# Run Sync Script
# ====================================
echo ""
echo "===================================="
echo "Running Minecraft Sync..."
echo "===================================="
echo ""

if [ -f "sync-mods-mac.sh" ]; then
    ./sync-mods-mac.sh
    SYNC_SUCCESS=$?
else
    echo "ERROR: sync-mods-mac.sh not found!"
    echo "Repository may be incomplete."
    rm -rf "$TEMP_DIR"
    read -n 1 -s -r -p "Press any key to exit..."
    exit 1
fi

# ====================================
# Cleanup Temporary Directory
# ====================================
echo ""
echo "Cleaning up temporary files..."
cd "$HOME" || cd /
rm -rf "$TEMP_DIR"

if [ $SYNC_SUCCESS -eq 0 ]; then
    echo ""
    echo "===================================="
    echo "Installation Complete!"
    echo "===================================="
    echo ""
    echo "Mods and resource packs have been synced to your Minecraft installation."
    echo "You can now launch Minecraft!"
    echo ""
    echo "To update in the future, just run this install script again."
    echo ""
else
    echo ""
    echo "WARNING: Sync may have encountered issues."
    echo "Please check the output above."
    echo ""
fi
read -n 1 -s -r -p "Press any key to exit..."
