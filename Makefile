install: install-rust install-typeshare install-toolchains
	@echo "Install swiftgen"
	@brew install swiftgen

install-rust:
	@echo Install Rust
	@curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

install-typeshare:
	@echo Install typeshare-cli
	@cargo install typeshare-cli --version 1.7.0

install-toolchains:
	@echo Install toolchains for uniffi
	@cd core/gemstone && make prepare-apple

bootstrap: install generate

core-upgrade:
	git submodule update --recursive --remote

test:
	cd xcodebuild -scheme Gem -destination 'platform=iOS Simulator,name=iPhone 14' test | xcbeautify

localize:
	@sh core/scripts/localize.sh ios Assets
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
	@cd core/gemstone && make apple BUILD_MODE=$(BUILD_MODE)
	@rm -rf Packages/Gemstone
	@cp -Rf core/gemstone/target/spm Packages/Gemstone
