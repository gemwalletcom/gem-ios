export GEMSTONE_VERSION = 0.2.0

list:
    just --list

install: install-typeshare install-toolchains install-swifttools

install-typeshare:
    @echo "==> Install typeshare-cli"
    just core install-typeshare

install-toolchains:
    @echo "==> Install toolchains for uniffi"
    @cd core && just gemstone install-nightly

install-swifttools:
    @echo "==> Install SwiftGen and SwiftFormat"
    @brew install swiftgen swiftformat

bootstrap: install install-gemstone-ci
    @echo "<== Bootstrap done."

install-wallet-core VERSION:
    @echo "==> Install wallet-core {{VERSION}}"
    wget https://github.com/trustwallet/wallet-core/releases/download/{{VERSION}}/Package.swift -O Packages/WalletCore/Package.swift

install-gemstone VERSION:
    #!/usr/bin/env bash
    echo "==> Install binary Gemstone {{VERSION}}"
    rm -rf Packages/Gemstone && mkdir -p Packages/Gemstone
    cd Packages/Gemstone
    wget https://github.com/gemwalletcom/core/releases/download/{{VERSION}}/Gemstone-spm.tar.bz2
    tar -xvjf Gemstone-spm.tar.bz2
    rm Gemstone-spm.tar.bz2

install-gemstone-ci:
    @echo "==> Install binary Gemstone on CI"
    just install-gemstone {{GEMSTONE_VERSION}}

setup-git:
    @echo "==> Setup git submodules"
    @git submodule update --init --recursive
    @git config submodule.recurse true

core-upgrade:
    git submodule update --recursive --remote

test:
    @set -o pipefail && xcodebuild -project Gem.xcodeproj \
    -scheme Gem \
    -sdk iphonesimulator \
    -destination "platform=iOS Simulator,name=iPhone 15" \
    test | xcbeautify

localize:
    @sh core/scripts/localize.sh ios Gem/Resources
    just generate-model
    just generate-swiftgen

generate: generate-model generate-stone generate-swiftgen

generate-model:
    @echo "==> Generate typeshare for iOS"
    @cd core && cargo run --package generate --bin generate ios ../Packages

generate-swiftgen:
    @echo "==> SwiftGen assets and Localizable.strings"
    @swiftgen config run --quiet

export BUILD_MODE := env_var_or_default("BUILD_MODE","")

generate-stone:
    @./scripts/generate-stone.sh $BUILD_MODE

mod core
