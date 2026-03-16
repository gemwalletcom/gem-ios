#!/bin/bash
#
# reproducible-build.sh — Build a reproducible IPA with ad-hoc signing
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
BUILD_DIR="$REPO_ROOT/build/reproducible"
ARCHIVE_PATH="$BUILD_DIR/Gem.xcarchive"
SCHEME="Gem"
PROJECT="Gem.xcodeproj"

# Output IPA path (can be overridden, resolve to absolute)
OUTPUT_IPA="${1:-$BUILD_DIR/Gem.ipa}"
case "$OUTPUT_IPA" in
    /*) ;; # already absolute
    *) OUTPUT_IPA="$REPO_ROOT/$OUTPUT_IPA" ;;
esac

echo "============================================"
echo "  Gem Wallet — Reproducible Build"
echo "============================================"
echo ""

# Step 1: Verify environment
echo "==> Step 1/5: Verifying environment..."
"$SCRIPT_DIR/verify-environment.sh"
echo ""

# Step 2: Build Rust core (Gemstone)
echo "==> Step 2/5: Building Rust core (Gemstone)..."
cd "$REPO_ROOT"
BUILD_MODE=release REPRODUCIBLE_BUILD=1 ./scripts/generate-stone.sh release
echo ""

# Step 3: Resolve SPM dependencies
echo "==> Step 3/5: Resolving Swift Package dependencies..."
xcodebuild -resolvePackageDependencies \
    -project "$PROJECT" \
    -scheme "$SCHEME" \
    -derivedDataPath "$BUILD_DIR/DerivedData" \
    -clonedSourcePackagesDirPath "$BUILD_DIR/SourcePackages"
echo ""

# Step 4: Archive with ad-hoc signing
# Ad-hoc signing produces deterministic output without needing Apple certificates.
# The compare tool strips code signatures anyway, so real signing is not needed.
echo "==> Step 4/5: Building archive..."
rm -rf "$ARCHIVE_PATH"

# Use fixed TMPDIR to avoid temp path embedding in binaries
REPRODUCIBLE_TMPDIR="$BUILD_DIR/tmp"
rm -rf "$REPRODUCIBLE_TMPDIR"
mkdir -p "$REPRODUCIBLE_TMPDIR"

TMPDIR="$REPRODUCIBLE_TMPDIR" \
xcodebuild archive \
    -project "$PROJECT" \
    -scheme "$SCHEME" \
    -archivePath "$ARCHIVE_PATH" \
    -derivedDataPath "$BUILD_DIR/DerivedData" \
    -clonedSourcePackagesDirPath "$BUILD_DIR/SourcePackages" \
    -destination "generic/platform=iOS" \
    CODE_SIGN_IDENTITY="-" \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGNING_ALLOWED=NO \
    DEVELOPMENT_TEAM="" \
    PROVISIONING_PROFILE_SPECIFIER="" \
    SWIFT_COMPILATION_MODE=wholemodule \
    COMPILER_INDEX_STORE_ENABLE=NO \
    GCC_GENERATE_DEBUGGING_SYMBOLS=NO \
    SWIFT_OPTIMIZATION_LEVEL=-O \
    2>&1 | xcbeautify --quieter --is-ci
XCODE_EXIT=${PIPESTATUS[0]}
if [ "$XCODE_EXIT" -ne 0 ]; then
    echo "ERROR: xcodebuild archive failed with exit code $XCODE_EXIT"
    exit 1
fi

rm -rf "$REPRODUCIBLE_TMPDIR"

if [ ! -d "$ARCHIVE_PATH" ]; then
    echo "ERROR: Archive failed. Check build output above."
    exit 1
fi
echo ""

# Step 5: Package IPA from archive
echo "==> Step 5/5: Packaging IPA..."
STAGING_DIR="$BUILD_DIR/ipa-staging"
rm -rf "$STAGING_DIR"
mkdir -p "$STAGING_DIR/Payload"

APP_DIR=$(find "$ARCHIVE_PATH/Products/Applications" -name "*.app" -maxdepth 1 -type d | head -1)
if [ -z "$APP_DIR" ]; then
    echo "ERROR: No .app found in archive."
    exit 1
fi

cp -R "$APP_DIR" "$STAGING_DIR/Payload/"

mkdir -p "$(dirname "$OUTPUT_IPA")"
(cd "$STAGING_DIR" && zip -qr "$OUTPUT_IPA" Payload/)
rm -rf "$STAGING_DIR"

echo ""
echo "============================================"
echo "  Build complete!"
echo "  IPA: $OUTPUT_IPA"
echo "  Size: $(du -h "$OUTPUT_IPA" | cut -f1)"
echo "============================================"
