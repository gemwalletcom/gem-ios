#!/bin/bash
set -euo pipefail

file="Gem.xcodeproj/project.pbxproj"

# Pull latest changes first
git pull

bump_version() {
  sh ./scripts/bump-version.sh patch
}

bump_build() {
  build=$(grep -oE "CURRENT_PROJECT_VERSION = [0-9]+;" "$file" | head -n1 | grep -oE "[0-9]+")
  new_build=$((build + 1))
  sed -i '' "s/CURRENT_PROJECT_VERSION = $build;/CURRENT_PROJECT_VERSION = $new_build;/g" "$file"
  echo "$new_build"
}

version=$(bump_version)
new_build=$(bump_build)

# Keep incrementing version until we find one without an existing tag
while git tag -l "$version" | grep -q .; do
  echo "⚠️  Tag $version already exists, trying next version..."
  version=$(bump_version)
done

git add "$file"
git commit -S -m "Bump to $version ($new_build)" > /dev/null
git tag -s "$version" -m "$version"
git push
git push origin "$version"
echo "✅ Bumped to $version ($new_build)"
