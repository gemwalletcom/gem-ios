XCBEAUTIFY_ARGS := "--quieter --is-ci"
BUILD_THREADS := `sysctl -n hw.ncpu`
SIMULATOR_NAME := "iPhone 17 Pro Max"
SIMULATOR_DEST := "platform=iOS Simulator,name=" + SIMULATOR_NAME

xcbeautify:
    @xcbeautify {{XCBEAUTIFY_ARGS}}

list:
    just --list

bootstrap: install generate-stone
    @echo "<== Bootstrap done."

install: install-rust install-typeshare install-toolchains install-swifttools

install-rust:
    just core install-rust

install-typeshare:
    @echo "==> Install typeshare-cli"
    just core install-typeshare

install-toolchains:
    @echo "==> Install toolchains for uniffi"
    @cd core && just gemstone install-ios-targets

install-swifttools:
    @echo "==> Install SwiftGen and SwiftFormat"
    @brew install swiftgen swiftformat

download-wallet-core VERSION:
    @echo "==> Install wallet-core {{VERSION}}"
    curl -L https://github.com/trustwallet/wallet-core/releases/download/{{VERSION}}/Package.swift -o Packages/WalletCore/Package.swift

setup-git:
    @echo "==> Setup git submodules"
    @git submodule update --init --recursive
    @git config submodule.recurse true

core-upgrade:
    git submodule update --recursive --remote

spm-resolve-all:
    sh scripts/spm-resolve-all.sh

build:
    @set -o pipefail && xcodebuild -project Gem.xcodeproj \
    -scheme Gem \
    ONLY_ACTIVE_ARCH=YES \
    -destination "{{SIMULATOR_DEST}}" \
    -derivedDataPath build/DerivedData \
    -parallelizeTargets \
    -jobs {{BUILD_THREADS}} \
    -showBuildTimingSummary \
    GCC_OPTIMIZATION_LEVEL=0 \
    SWIFT_OPTIMIZATION_LEVEL=-Onone \
    SWIFT_COMPILATION_MODE=incremental \
    ENABLE_TESTABILITY=NO \
    build | xcbeautify {{XCBEAUTIFY_ARGS}}

clean:
    @rm -rf build/DerivedData
    @echo "Build cache cleaned"

run: build
    @echo "==> Installing app on simulator..."
    @xcrun simctl boot "{{SIMULATOR_NAME}}" 2>/dev/null || true
    @open -a Simulator
    @xcrun simctl install "{{SIMULATOR_NAME}}" build/DerivedData/Build/Products/Debug-iphonesimulator/Gem.app
    @echo "==> Launching app..."
    @xcrun simctl launch --console-pty "{{SIMULATOR_NAME}}" com.gemwallet.ios

build-package PACKAGE:
    @set -o pipefail && xcodebuild -project Gem.xcodeproj \
    -scheme {{PACKAGE}} \
    ONLY_ACTIVE_ARCH=YES \
    -destination "{{SIMULATOR_DEST}}" \
    -derivedDataPath build/DerivedData \
    -parallelizeTargets \
    -jobs {{BUILD_THREADS}} \
    GCC_OPTIMIZATION_LEVEL=0 \
    SWIFT_OPTIMIZATION_LEVEL=-Onone \
    build | xcbeautify {{XCBEAUTIFY_ARGS}}

show-simulator:
    @echo "Destination: {{SIMULATOR_DEST}}"
    @xcrun simctl list devices | grep "iPhone" | head -5 || true

test-all: show-simulator
    @set -o pipefail && xcodebuild -project Gem.xcodeproj \
    -scheme Gem \
    ONLY_ACTIVE_ARCH=YES \
    -destination "{{SIMULATOR_DEST}}" \
    -derivedDataPath build/DerivedData \
    -parallel-testing-enabled YES \
    -parallelizeTargets \
    -jobs {{BUILD_THREADS}} \
    test | xcbeautify {{XCBEAUTIFY_ARGS}}

test-ui: reset-simulator
    @set -o pipefail && xcodebuild -project Gem.xcodeproj \
    -scheme GemUITests \
    -testPlan ui_tests \
    ONLY_ACTIVE_ARCH=YES \
    -destination "{{SIMULATOR_DEST}}" \
    -allowProvisioningUpdates \
    -allowProvisioningDeviceRegistration \
    test | xcbeautify {{XCBEAUTIFY_ARGS}}

reset-simulator NAME=SIMULATOR_NAME:
    @echo "==> Resetting {{NAME}} simulator to clean state"
    @xcrun simctl shutdown "{{NAME}}" 2>/dev/null || true
    @xcrun simctl erase "{{NAME}}" 2>/dev/null || true
    @xcrun simctl boot "{{NAME}}" 2>/dev/null || true

test TARGET: show-simulator
    @set -o pipefail && xcodebuild -project Gem.xcodeproj \
    -scheme Gem \
    ONLY_ACTIVE_ARCH=YES \
    -destination "{{SIMULATOR_DEST}}" \
    -derivedDataPath build/DerivedData \
    -only-testing {{TARGET}} \
    -parallel-testing-enabled YES \
    -parallelizeTargets \
    -jobs {{BUILD_THREADS}} \
    test | xcbeautify {{XCBEAUTIFY_ARGS}}


localize:
    @sh core/scripts/localize.sh ios Packages/Localization/Sources/Resources
    just generate-model
    just generate-swiftgen

generate: generate-model generate-swiftgen

generate-model:
    @echo "==> Generate typeshare for iOS"
    @cd core && cargo run --package generate --bin generate ios ../Packages

generate-swiftgen:
    @echo "==> SwiftGen assets and Localizable.strings"
    @swiftgen config run --quiet

export BUILD_MODE := env_var_or_default("BUILD_MODE","")

generate-stone:
    @./scripts/generate-stone.sh $BUILD_MODE

bump TYPE="":
    @sh ./scripts/bump.sh {{TYPE}}

mod core
