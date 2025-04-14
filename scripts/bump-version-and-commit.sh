#!/bin/bash
set -euo pipefail

bump=${1:-patch}
file="Gem.xcodeproj/project.pbxproj"

version=$(sh ./scripts/bump-version.sh "$bump")
git add "$file"
git commit -m "Bump to $version"  > /dev/null

echo "✅ Version bumped to $version and changes committed."