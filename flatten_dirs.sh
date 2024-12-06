#!/bin/bash

# Function to display usage information
usage() {
    echo "Description:"
    echo "  This script moves subfolders from multiple directories to a specific destination folder."
    echo "  The moved folders are renamed to include their parent folder name as a prefix, creating a flat hierarchy."
    echo "  Optionally, it removes the original parent folders if they are empty after the operation."
    echo
    echo "Usage:"
    echo "  $0 <source_dir> <destination_dir> [--cleanup]"
    echo
    echo "Arguments:"
    echo "  <source_dir>       The source directory containing folders to flatten."
    echo "                     Example: 'a', 'b', etc., with subfolders 'a/1', 'a/2', 'b/1', etc."
    echo "  <destination_dir>  The directory where flattened subfolders will be moved."
    echo "  --cleanup          (Optional) Remove original parent folders if they are empty."
    echo
    echo "Example:"
    echo "  $0 /path/to/src /path/to/destination --cleanup"
    echo
    echo "Behavior:"
    echo "  - Subfolders like 'a/1', 'a/2', 'b/1', etc., will be moved to the destination directory."
    echo "  - Their names will be changed to 'a_1', 'a_2', 'b_1', etc."
    echo "  - If '--cleanup' is specified, empty parent folders (e.g., 'a', 'b') will be removed."
    exit 1
}

# Check if at least 2 parameters are provided
if [ "$#" -lt 2 ] || [ "$#" -gt 3 ]; then
    usage
fi

# Assign command-line arguments to variables
SRC_DIR="$1"
DEST_DIR="$2"
CLEANUP=false

# Check if "--cleanup" flag is provided
if [ "$#" -eq 3 ] && [ "$3" == "--cleanup" ]; then
    CLEANUP=true
fi

# Check if source directory exists
if [ ! -d "$SRC_DIR" ]; then
    echo "Error: Source directory '$SRC_DIR' does not exist."
    exit 1
fi

# Check if destination directory exists, create it if not
mkdir -p "$DEST_DIR"

# Iterate through all subdirectories in the source directory
find "$SRC_DIR" -mindepth 2 -type d | while read -r subfolder; do
    # Get the parent directory name and the base folder name
    parent_name=$(basename "$(dirname "$subfolder")")
    base_name=$(basename "$subfolder")
    
    # Construct the new folder name
    new_name="${parent_name}_${base_name}"
    
    # Construct the destination path
    dest_path="$DEST_DIR/$new_name"
    
    # Move the folder
    echo "Moving: $subfolder -> $dest_path"
    mv "$subfolder" "$dest_path"
done

# Remove empty parent folders if --cleanup is enabled
if [ "$CLEANUP" = true ]; then
    echo "Cleaning up empty parent folders..."
    find "$SRC_DIR" -mindepth 1 -maxdepth 1 -type d -empty -exec rmdir {} \; -print
fi

echo "Flattening complete!"

