
#!/bin/bash

# Base directories containing Swift packages
BASE_DIRS=("./Packages" "./Features")

for base_dir in "${BASE_DIRS[@]}"; do
    echo "Searching in $base_dir"
    if [ ! -d "$base_dir" ]; then
        echo "Directory $base_dir does not exist, skipping..."
        continue
    fi
    
    # Look for Package.swift files directly in each subdirectory
    for package_dir in "$base_dir"/*; do
        if [ -f "$package_dir/Package.swift" ]; then
            echo "Found package in $package_dir"
            (cd "$package_dir" && swift package resolve) || echo "Failed to resolve dependencies in $package_dir"
        fi
    done
done