#!/bin/bash

echo "===================================="
echo "Minecraft Mods and Resource Packs Sync Script (macOS)"
echo "===================================="
echo ""

# Get the script directory
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
MINECRAFT_DIR="$HOME/Library/Application Support/minecraft"

# Define Paths
CLIENT_MODS="$SCRIPT_DIR/mods"
MINECRAFT_MODS="$MINECRAFT_DIR/mods"

CLIENT_RESOURCEPACKS="$SCRIPT_DIR/resourcepacks"
MINECRAFT_RESOURCEPACKS="$MINECRAFT_DIR/resourcepacks"

OPTIONS_FILE="$MINECRAFT_DIR/options.txt"
OVERRIDES_FILE="$SCRIPT_DIR/minecraft-overrides.txt"

echo "Mods Source: $CLIENT_MODS"
echo "Mods Target: $MINECRAFT_MODS"
echo "Resource Packs Source: $CLIENT_RESOURCEPACKS"
echo "Resource Packs Target: $MINECRAFT_RESOURCEPACKS"
echo ""

# Check if mods folder exists in Client directory
if [ ! -d "$CLIENT_MODS" ]; then
    echo "ERROR: mods folder not found in script directory!"
    echo "Please make sure the mods folder exists next to this script."
    read -n 1 -s -r -p "Press any key to exit..."
    exit 1
fi

# Remove old mods folder if it exists
if [ -d "$MINECRAFT_MODS" ]; then
    echo "Removing old mods folder..."
    rm -rf "$MINECRAFT_MODS"
    if [ $? -ne 0 ]; then
        echo "ERROR: Failed to remove old mods folder."
        echo "Make sure Minecraft is closed and try again."
        read -n 1 -s -r -p "Press any key to exit..."
        exit 1
    fi
    echo "Old mods folder removed successfully."
    echo ""
fi

# Create minecraft directory if it doesn't exist (rare, but good practice)
if [ ! -d "$MINECRAFT_DIR" ]; then
    echo "Creating minecraft directory..."
    mkdir -p "$MINECRAFT_DIR"
fi

# Copy new mods folder
echo "Copying new mods folder..."
cp -R "$CLIENT_MODS" "$MINECRAFT_MODS"
if [ $? -ne 0 ]; then
    echo "ERROR: Failed to copy mods folder."
    read -n 1 -s -r -p "Press any key to exit..."
    exit 1
fi

# ====================================
# Sync Resource Packs
# ====================================
echo ""
echo "Syncing resource packs..."
echo ""

# Check if resourcepacks folder exists
if [ ! -d "$CLIENT_RESOURCEPACKS" ]; then
    echo "WARNING: resourcepacks folder not found in Client directory!"
    echo "Skipping resource packs sync..."
    echo ""
else
    # Remove old resourcepacks folder if it exists
    if [ -d "$MINECRAFT_RESOURCEPACKS" ]; then
        echo "Removing old resourcepacks folder..."
        rm -rf "$MINECRAFT_RESOURCEPACKS"
        if [ $? -ne 0 ]; then
            echo "ERROR: Failed to remove old resourcepacks folder."
            read -n 1 -s -r -p "Press any key to exit..."
            exit 1
        fi
        echo "Old resourcepacks folder removed successfully."
        echo ""
    fi

    # Copy new resourcepacks folder
    echo "Copying new resourcepacks folder..."
    cp -R "$CLIENT_RESOURCEPACKS" "$MINECRAFT_RESOURCEPACKS"
    if [ $? -ne 0 ]; then
        echo "ERROR: Failed to copy resourcepacks folder."
        read -n 1 -s -r -p "Press any key to exit..."
        exit 1
    fi
    echo "Resource packs synced successfully!"
    echo ""
fi

# ====================================
# Apply Minecraft Options Overrides
# ====================================
echo ""
echo "Applying Minecraft options overrides..."

if [ ! -f "$OVERRIDES_FILE" ]; then
    echo "WARNING: minecraft-overrides.txt not found."
    echo "Skipping options overrides..."
elif [ ! -f "$OPTIONS_FILE" ]; then
    echo "WARNING: options.txt not found."
    echo "Please launch the game at least once to generate it, then run this script again."
else
    # Read overrides file and apply each line to options.txt
    # Skip lines that are comments (start with #) or are empty
    while IFS= read -r line || [ -n "$line" ]; do
        # Skip comments and empty lines
        if [[ "$line" =~ ^[[:space:]]*# ]] || [[ -z "${line// }" ]]; then
            continue
        fi
        
        # Extract key and value (split on first colon)
        if [[ "$line" =~ ^([^:]+):(.*)$ ]]; then
            key="${BASH_REMATCH[1]}"
            value="${BASH_REMATCH[2]}"
            
            # Escape special characters for sed
            escaped_value=$(printf '%s\n' "$value" | sed 's/[&/\]/\\&/g')
            
            # Replace the line in options.txt
            # macOS sed requires an empty string '' after -i for in-place editing
            sed -i '' "s/^${key}:.*/${key}:${escaped_value}/" "$OPTIONS_FILE"
        fi
    done < "$OVERRIDES_FILE"
    
    echo "Options overrides applied successfully."
fi

echo ""
echo "===================================="
echo "Sync completed successfully!"
echo "===================================="
echo ""
echo "You can now launch Minecraft."
echo ""
read -n 1 -s -r -p "Press any key to exit..."