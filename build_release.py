import os
import zipfile

# --- Configuration ---
# 1. Version number (update this before building)
VERSION = "v1.0"

# 2. The template for the output zip file
OUTPUT_NAME = "Client-Release-{version}.zip"

# 3. THE WHITELIST: Only these items will be packaged
# (Add any new files you want to distribute to this list)
FILES_TO_INCLUDE = [
    "sync-mods.bat",
    "sync-mods-mac.sh",
    "minecraft-overrides.txt",
    "README.md",
    "DISTRIBUTION.md",
    "install-client.bat"
]

FOLDERS_TO_INCLUDE = [
    "mods",           # Will include structure (and files if any are inside)
    "resourcepacks",   # Will include structure (and files if any are inside)
    # "installers" 
]

def build():
    zip_filename = OUTPUT_NAME.format(version=VERSION)
    
    print(f"🔨 Building Release: {VERSION}")
    print(f"📦 Output File: {zip_filename}")
    print("-" * 30)

    with zipfile.ZipFile(zip_filename, 'w', zipfile.ZIP_DEFLATED) as zipf:
        
        # 1. Add Whitelisted Files
        for filename in FILES_TO_INCLUDE:
            if os.path.exists(filename):
                print(f"  ✅ Adding File:   {filename}")
                zipf.write(filename, arcname=filename)
            else:
                print(f"  ❌ MISSING File:  {filename} (Skipping)")

        # 2. Add Whitelisted Folders (Recursively)
        for folder in FOLDERS_TO_INCLUDE:
            if os.path.exists(folder):
                print(f"  📂 Adding Folder: {folder}/")
                for root, _, files in os.walk(folder):
                    for file in files:
                        file_path = os.path.join(root, file)
                        # arcname ensures the folder structure stays the same inside the zip
                        zipf.write(file_path, arcname=file_path)
            else:
                print(f"  ❌ MISSING Folder: {folder}/ (Skipping)")

    print("-" * 30)
    print(f"🎉 Done! Created {zip_filename}")

if __name__ == "__main__":
    build()