install: install-rust install-typeshare install-toolchains install-swifttools

install-rust:
	@echo "==> Install Rust"
	@curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
	@# in case cargo is not in PATH in the current shell
	@. ~/.cargo/env

install-typeshare:
	@echo "==> Install typeshare-cli"
	@cd core && make install-typeshare

install-toolchains:
	@echo "==> Install toolchains for uniffi"
	@cd core/gemstone && make prepare-apple

install-swifttools:
	@echo "==> Install SwiftGen and SwiftFormat"
	@brew install swiftgen swiftformat

bootstrap: setup-git install generate
	@echo "<== Bootstrap done."

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
	@make generate-model
	@make generate-swiftgen

generate: generate-model generate-stone generate-swiftgen

generate-model:
	@echo "==> Generate typeshare for iOS"
	@cd core && cargo run --package generate --bin generate ios ../Packages

generate-swiftgen:
	@echo "==> SwiftGen assets and Localizable.strings"
	@swiftgen config run --quiet

generate-stone:
	@./scripts/generate-stone.sh $(BUILD_MODE)

.PHONY: screenshots
