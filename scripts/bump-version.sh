#!/bin/bash
set -euo pipefail

file="Gem.xcodeproj/project.pbxproj"
bump=${1:-patch} # default to patch

version=$(grep -oE "MARKETING_VERSION = [0-9]+\.[0-9]+\.[0-9]+;" "$file" | head -n1 | grep -oE "[0-9]+\.[0-9]+\.[0-9]+")
if [[ -z "$version" ]]; then
  echo "❌ No MARKETING_VERSION found in $file" >&2
  exit 1
fi

IFS="." read -r major minor patch <<< "$version"

case "$bump" in
  major) major=$((major + 1)); minor=0; patch=0 ;;
  minor) minor=$((minor + 1)); patch=0 ;;
  patch) patch=$((patch + 1)) ;;
  *) echo "❌ Invalid bump type: $bump" >&2; exit 1 ;;
esac

new_version="${major}.${minor}.${patch}"
sed -i '' "s/MARKETING_VERSION = $version;/MARKETING_VERSION = $new_version;/g" "$file"

echo "$new_version"