export GEMSTONE_VERSION := "v0.2.0"

list:
    just --list

bootstrap: install install-gemstone
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

download-gemstone VERSION:
    #!/usr/bin/env bash
    echo "==> Install binary Gemstone {{VERSION}}"
    rm -rf Packages/Gemstone && mkdir -p Packages/Gemstone
    cd Packages/Gemstone
    curl -L https://github.com/gemwalletcom/core/releases/download/{{VERSION}}/Gemstone-spm.tar.bz2 -o Gemstone-spm.tar.bz2
    tar -xvjf Gemstone-spm.tar.bz2
    rm Gemstone-spm.tar.bz2

install-gemstone:
    @echo "==> Install binary Gemstone {{GEMSTONE_VERSION}}"
    just download-gemstone {{GEMSTONE_VERSION}}

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
    -destination "platform=iOS Simulator,name=iPhone 16" \
    test | xcbeautify

test_ui:
    @set -o pipefail && xcodebuild -project Gem.xcodeproj \
    -scheme GemUITests \
    -sdk iphonesimulator \
    -destination "platform=iOS Simulator,name=iPhone 16" \
    -allowProvisioningUpdates \
    -allowProvisioningDeviceRegistration \
    test | xcbeautify

localize:
    @sh core/scripts/localize.sh ios Gem/Resources
    just generate-model
    just generate-swiftgen

generate: generate-model generate-swiftgen

generate-model:
    @echo "==> Generate typeshare for iOS"
    @cd core && cargo run --package generate --bin generate ios ../Packages

generate-swiftgen:
    @echo "==> SwiftGen assets and Localizable.strings"
    @swiftgen config run --quiet
    @echo "==> Applying SwiftGen patch, remove when SwiftGen is fixed"
    @git apply .swiftgen.patch

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

mod core
