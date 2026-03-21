#!/bin/bash

echo "===================================="
echo "Minecraft Client Installer"
echo "===================================="
echo ""

# ====================================
# Configuration
# ====================================
REPO_URL="https://github.com/AnhNTSE183225/minecraft-client.git"
REPO_BRANCH="main"

# ====================================
# Setup Variables
# ====================================
CACHE_ROOT="${TMPDIR:-/tmp}/minecraft_client_cache"
TEMP_DIR="$CACHE_ROOT/repo"
LOCK_DIR="$CACHE_ROOT/.lock"
LOCK_ACQUIRED=0

acquire_lock() {
    local wait_count=0
    mkdir -p "$CACHE_ROOT"
    while ! mkdir "$LOCK_DIR" 2>/dev/null; do
        wait_count=$((wait_count + 1))
        if [ "$wait_count" -ge 180 ]; then
            echo "Timeout waiting for another installer instance to finish."
            return 1
        fi
        echo "Another install.sh instance is running. Waiting for cache lock..."
        sleep 2
    done
    LOCK_ACQUIRED=1
    return 0
}

release_lock() {
    if [ "$LOCK_ACQUIRED" -eq 1 ]; then
        rmdir "$LOCK_DIR" 2>/dev/null || true
        LOCK_ACQUIRED=0
    fi
}

trap 'release_lock' EXIT INT TERM

echo "Repository: $REPO_URL"
echo "Cache Directory: $TEMP_DIR"
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
# Check for Git LFS
# ====================================
if ! command -v git-lfs &> /dev/null; then
    echo "Git LFS is not installed. Installing now..."
    echo ""
    
    # Check if Homebrew is available (macOS)
    if command -v brew &> /dev/null; then
        echo "Installing Git LFS via Homebrew..."
        brew install git-lfs
        
        if [ $? -ne 0 ]; then
            echo ""
            echo "ERROR: Failed to install Git LFS via Homebrew."
            echo "Please try manually: brew install git-lfs"
            echo "Or visit: https://git-lfs.com/"
            echo ""
            read -n 1 -s -r -p "Press any key to exit..."
            exit 1
        fi
    # Check for apt-get (Debian/Ubuntu Linux)
    elif command -v apt-get &> /dev/null; then
        echo "Installing Git LFS via apt-get..."
        sudo apt-get update && sudo apt-get install -y git-lfs
        
        if [ $? -ne 0 ]; then
            echo ""
            echo "ERROR: Failed to install Git LFS."
            echo "Please try manually: sudo apt-get install git-lfs"
            echo "Or visit: https://git-lfs.com/"
            echo ""
            read -n 1 -s -r -p "Press any key to exit..."
            exit 1
        fi
    # Check for yum (RHEL/CentOS/Fedora Linux)
    elif command -v yum &> /dev/null; then
        echo "Installing Git LFS via yum..."
        sudo yum install -y git-lfs
        
        if [ $? -ne 0 ]; then
            echo ""
            echo "ERROR: Failed to install Git LFS."
            echo "Please try manually: sudo yum install git-lfs"
            echo "Or visit: https://git-lfs.com/"
            echo ""
            read -n 1 -s -r -p "Press any key to exit..."
            exit 1
        fi
    else
        echo ""
        echo "ERROR: No package manager found (brew, apt-get, yum)."
        echo "Please install Git LFS manually from: https://git-lfs.com/"
        echo ""
        echo "macOS: brew install git-lfs"
        echo "Ubuntu/Debian: sudo apt-get install git-lfs"
        echo "RHEL/CentOS/Fedora: sudo yum install git-lfs"
        echo ""
        read -n 1 -s -r -p "Press any key to exit..."
        exit 1
    fi
    
    echo "Git LFS installation completed!"
    echo ""
fi

# Initialize Git LFS (this sets up the git filters)
echo "Initializing Git LFS..."
git lfs install

if [ $? -ne 0 ]; then
    echo ""
    echo "ERROR: Failed to initialize Git LFS."
    echo "Please try running 'git lfs install' manually."
    echo ""
    read -n 1 -s -r -p "Press any key to exit..."
    exit 1
fi

echo "Git LFS is ready: OK"
echo ""

# ====================================
# Acquire Lock For Safe Multi-Instance Execution
# ====================================
echo "Acquiring install lock..."
if ! acquire_lock; then
    echo ""
    echo "ERROR: Failed to acquire install lock."
    read -n 1 -s -r -p "Press any key to exit..."
    exit 1
fi

# ====================================
# Prepare Repository Cache
# ====================================
NEED_RECLONE=0
if [ -d "$TEMP_DIR/.git" ]; then
    echo "Reusing existing cache and updating from $REPO_BRANCH..."
    cd "$TEMP_DIR" || exit 1

    CURRENT_REMOTE=$(git remote get-url origin 2>/dev/null || true)
    if [ -z "$CURRENT_REMOTE" ] || [ "$CURRENT_REMOTE" != "$REPO_URL" ]; then
        echo "Remote URL changed or missing. Recreating cache..."
        NEED_RECLONE=1
    fi

    if [ "$NEED_RECLONE" -eq 0 ]; then
        git checkout "$REPO_BRANCH" >/dev/null 2>&1
        if [ $? -ne 0 ]; then
            git fetch origin "$REPO_BRANCH"
            if [ $? -ne 0 ]; then
                NEED_RECLONE=1
            else
                git checkout -b "$REPO_BRANCH" "origin/$REPO_BRANCH"
                if [ $? -ne 0 ]; then
                    NEED_RECLONE=1
                fi
            fi
        fi
    fi

    if [ "$NEED_RECLONE" -eq 0 ]; then
        git pull --ff-only origin "$REPO_BRANCH"
        if [ $? -ne 0 ]; then
            NEED_RECLONE=1
        fi
    fi
else
    NEED_RECLONE=1
fi

if [ "$NEED_RECLONE" -eq 1 ]; then
    echo "Cloning repository into cache..."
    echo "This may take a few minutes if there are large files..."
    echo ""

    rm -rf "$TEMP_DIR"
    CLONE_LOG="${TMPDIR:-/tmp}/minecraft_client_clone_$$.log"
    git clone --branch "$REPO_BRANCH" "$REPO_URL" "$TEMP_DIR" >"$CLONE_LOG" 2>&1
    if [ $? -ne 0 ]; then
        if grep -q "active 'post-checkout' hook found during 'git clone'" "$CLONE_LOG"; then
            echo "Detected Git clone protection on this machine. Retrying clone with clone protection disabled for this command..."
            rm -rf "$TEMP_DIR"
            GIT_CLONE_PROTECTION_ACTIVE=false git clone --branch "$REPO_BRANCH" "$REPO_URL" "$TEMP_DIR" >>"$CLONE_LOG" 2>&1
        fi
    fi

    if [ ! -d "$TEMP_DIR/.git" ]; then
        echo ""
        echo "ERROR: Failed to clone repository."
        echo "Please check:"
        echo "1. The repository URL is correct"
        echo "2. The repository is public or you have access"
        echo "3. You have an internet connection"
        echo ""
        echo "Clone output:"
        cat "$CLONE_LOG"
        rm -f "$CLONE_LOG"
        read -n 1 -s -r -p "Press any key to exit..."
        exit 1
    fi

    rm -f "$CLONE_LOG"
fi

cd "$TEMP_DIR" || exit 1

echo "Pulling Git LFS content..."
git lfs pull
if [ $? -ne 0 ]; then
    echo ""
    echo "ERROR: Failed to pull Git LFS content."
    echo "Please verify your Git LFS installation and network access."
    echo ""
    read -n 1 -s -r -p "Press any key to exit..."
    exit 1
fi

echo "Repository cache is ready."
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
    read -n 1 -s -r -p "Press any key to exit..."
    exit 1
fi

# ====================================
# Release Lock
# ====================================
release_lock

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
