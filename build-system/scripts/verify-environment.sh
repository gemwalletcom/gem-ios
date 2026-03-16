#!/bin/bash
#
# verify-environment.sh — Verify that installed tool versions match versions.json
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
VERSIONS_FILE="$REPO_ROOT/versions.json"

if [ ! -f "$VERSIONS_FILE" ]; then
    echo "ERROR: versions.json not found at $VERSIONS_FILE"
    exit 1
fi

# Parse versions.json using plutil (native macOS, no python dependency)
read_version() {
    plutil -extract "$1" raw "$VERSIONS_FILE"
}

ERRORS=0

check_version() {
    local name="$1"
    local expected="$2"
    local actual="$3"

    if [ "$expected" != "$actual" ]; then
        echo "MISMATCH: $name — expected $expected, got $actual"
        ERRORS=$((ERRORS + 1))
    else
        echo "OK: $name $actual"
    fi
}

echo "==> Verifying environment against versions.json..."
echo ""

# Xcode version
EXPECTED_XCODE=$(read_version "xcode")
ACTUAL_XCODE=$(xcodebuild -version 2>/dev/null | awk 'NR==1{print $2}')
check_version "Xcode" "$EXPECTED_XCODE" "$ACTUAL_XCODE"

# Xcode build number
EXPECTED_XCODE_BUILD=$(read_version "xcode_build")
ACTUAL_XCODE_BUILD=$(xcodebuild -version 2>/dev/null | awk 'NR==2{print $3}')
check_version "Xcode Build" "$EXPECTED_XCODE_BUILD" "$ACTUAL_XCODE_BUILD"

# macOS version (major only)
EXPECTED_MACOS=$(read_version "macos")
ACTUAL_MACOS=$(sw_vers -productVersion | cut -d. -f1)
check_version "macOS" "$EXPECTED_MACOS" "$ACTUAL_MACOS"

# Rust version
EXPECTED_RUST=$(read_version "rust")
ACTUAL_RUST=$(rustc --version 2>/dev/null | awk '{print $2}')
check_version "Rust" "$EXPECTED_RUST" "$ACTUAL_RUST"

# typeshare-cli version
EXPECTED_TYPESHARE=$(read_version "typeshare_cli")
ACTUAL_TYPESHARE=$(typeshare --version 2>/dev/null | awk '{print $2}' || echo "not installed")
check_version "typeshare-cli" "$EXPECTED_TYPESHARE" "$ACTUAL_TYPESHARE"

# SwiftGen version
EXPECTED_SWIFTGEN=$(read_version "swiftgen")
ACTUAL_SWIFTGEN=$(swiftgen --version 2>/dev/null | sed -nE 's/.*v([0-9]+\.[0-9]+\.[0-9]+).*/\1/p' || echo "not installed")
check_version "SwiftGen" "$EXPECTED_SWIFTGEN" "$ACTUAL_SWIFTGEN"

# SwiftFormat version
EXPECTED_SWIFTFORMAT=$(read_version "swiftformat")
ACTUAL_SWIFTFORMAT=$(swiftformat --version 2>/dev/null || echo "not installed")
check_version "SwiftFormat" "$EXPECTED_SWIFTFORMAT" "$ACTUAL_SWIFTFORMAT"

echo ""
if [ "$ERRORS" -gt 0 ]; then
    echo "FAILED: $ERRORS version mismatch(es) detected."
    echo "Please install the exact versions listed in versions.json for reproducible builds."
    exit 1
else
    echo "All tool versions match."
fi
