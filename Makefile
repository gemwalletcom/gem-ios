install: install-rust install-typeshare install-toolchains
	@echo "Install swiftgen"
	@brew install swiftgen

install-rust:
	@echo Install Rust
	@curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

install-typeshare:
	@echo Install typeshare-cli
	@cargo install typeshare-cli --version 1.9.2

install-toolchains:
	@echo Install toolchains for uniffi
	@cd core/gemstone && make prepare-apple

bootstrap: install generate setup-git

setup-git:
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
	@echo "Generate typeshare for iOS"
	@cd core && cargo run --package generate --bin generate ios ../Packages

generate-swiftgen:
	@echo "Run swiftgen"
	@swiftgen config run --quiet

generate-stone:
	@echo "Generate Gemstone lib"
	@cd core/gemstone && make apple BUILD_MODE=$(BUILD_MODE) IPHONEOS_DEPLOYMENT_TARGET=17.0
	@rm -rf Packages/Gemstone
	@cp -Rf core/gemstone/target/spm Packages/Gemstone

build:
	@set -o pipefail && xcodebuild -project Gem.xcodeproj \
	-scheme Gem \
	-sdk iphonesimulator \
	-destination "platform=iOS Simulator,name=iPhone 15" \
	build

test-ui:
	# maestro start-device --platform=ios --os-version=17
	maestro test .maestro

.PHONY: build
