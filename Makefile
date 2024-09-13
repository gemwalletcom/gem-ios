install-rust:
	@echo "==> Install Rust if needed"
	@which cargo || curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
	@. ~/.cargo/env
	@cargo install just

bootstrap: install-rust
	just bootstrap
