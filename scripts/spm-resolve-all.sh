#!/bin/bash

# Base directories containing Swift packages
BASE_DIRS=("./Packages" "./Features" "./Services")

for base_dir in "${BASE_DIRS[@]}"; do
    echo "Searching in $base_dir"
    if [ ! -d "$base_dir" ]; then
        echo "Directory $base_dir does not exist, skipping..."
        continue
    fi
    
    # Find all subdirectories containing a Package.swift file
    find "$base_dir" -type f -name "Package.swift" 2>/dev/null | while read -r package_file; do
        package_dir=$(dirname "$package_file")
        echo "Found package in $package_dir"
        
        # Try to resolve dependencies, but don't exit on error
        (cd "$package_dir" && swift package resolve) || echo "Failed to resolve dependencies in $package_dir"
    done
done