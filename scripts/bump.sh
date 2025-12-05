#!/bin/bash
set -euo pipefail

type=${1:-}
file="Gem.xcodeproj/project.pbxproj"

bump_version() {
  sh ./scripts/bump-version.sh patch
}

bump_build() {
  build=$(grep -oE "CURRENT_PROJECT_VERSION = [0-9]+;" "$file" | head -n1 | grep -oE "[0-9]+")
  new_build=$((build + 1))
  sed -i '' "s/CURRENT_PROJECT_VERSION = $build;/CURRENT_PROJECT_VERSION = $new_build;/g" "$file"
  echo "$new_build"
}

case "$type" in
  "")
    version=$(bump_version)
    new_build=$(bump_build)
    git add "$file"
    git commit -S -m "Bump to $version ($new_build)" > /dev/null
    git tag -s "$version" -m "$version" 2>/dev/null || echo "⚠️  Tag $version already exists"
    echo "✅ Bumped to $version ($new_build)"
    ;;
  version)
    version=$(bump_version)
    git add "$file"
    git commit -S -m "Bump to $version" > /dev/null
    git tag -s "$version" -m "$version" 2>/dev/null || echo "⚠️  Tag $version already exists"
    echo "✅ Bumped to $version"
    ;;
  build)
    new_build=$(bump_build)
    git add "$file"
    git commit -S -m "Bump build to $new_build" > /dev/null
    echo "✅ Bumped build to $new_build"
    ;;
  *)
    echo "❌ Invalid type: $type. Use 'version' or 'build'." >&2
    exit 1
    ;;
esac
