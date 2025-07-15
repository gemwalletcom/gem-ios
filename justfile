XCBEAUTIFY_ARGS := ""
SIMULATOR_DEST := "platform=iOS Simulator,name=iPhone 16,arch=arm64"

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
    -sdk iphonesimulator \
    -destination "{{SIMULATOR_DEST}}" \
    build | just xcbeautify

test:
    @set -o pipefail && xcodebuild -project Gem.xcodeproj \
    -scheme Gem \
    -sdk iphonesimulator \
    -destination "{{SIMULATOR_DEST}}" \
    -parallel-testing-enabled YES \
    test | just xcbeautify

test_ui:
    @set -o pipefail && xcodebuild -project Gem.xcodeproj \
    -scheme GemUITests \
    -sdk iphonesimulator \
    -destination "{{SIMULATOR_DEST}}" \
    -allowProvisioningUpdates \
    -allowProvisioningDeviceRegistration \
    test | just xcbeautify

test-specific TARGET:
    @set -o pipefail && xcodebuild -project Gem.xcodeproj \
    -scheme Gem \
    -sdk iphonesimulator \
    -destination "{{SIMULATOR_DEST}}" \
    -only-testing {{TARGET}} \
    -parallel-testing-enabled YES \
    test | just xcbeautify

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

install-uml-tools:
    brew install swiftplantuml plantuml

uml-app:
    just uml .

uml PATH:
    #!/usr/bin/env bash
    cd {{ PATH }}
    swiftplantuml --output consoleOnly > sources.txt
    PLANTUML_LIMIT_SIZE=16384 plantuml sources.txt && open sources.png
    rm sources.cmapx

bump-version:
    @sh ./scripts/bump-version-and-commit.sh patch

mod core