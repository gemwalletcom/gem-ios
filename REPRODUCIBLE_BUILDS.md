# Reproducible Builds

Gem Wallet supports reproducible builds — anyone can build from source and verify the binary matches the App Store release.

## Prerequisites

- macOS (Apple Silicon recommended)
- Xcode (exact version in `versions.json`)
- Rust toolchain (exact version in `versions.json`)
- [just](https://github.com/casey/just) command runner
- [xcbeautify](https://github.com/cpisciotta/xcbeautify) for build output

Check your environment:
```bash
just verify-environment
```

## Quick Verification

### 1. Build from source
```bash
just reproducible-build
```

This produces `build/reproducible/Gem.ipa`.

### 2. Build again and compare
```bash
just reproducible-build build/reproducible/Gem-2.ipa
just compare-builds build/reproducible/Gem.ipa build/reproducible/Gem-2.ipa
```

If the builds are reproducible, the comparison passes.

### 3. Verify against App Store (advanced)

Obtain a decrypted App Store IPA, then:
```bash
just verify-build path/to/AppStore.ipa
```

## How It Works

### Ad-hoc Signing

The build uses ad-hoc signing (`CODE_SIGN_IDENTITY="-"`) — no Apple certificates or provisioning profiles needed. Code signatures are non-deterministic and the comparison tool strips them, so real signing isn't required for verification.

### Build Process

`just reproducible-build` does the following:

1. **Verify environment** — checks that Xcode, Rust, and all tools match the pinned versions in `versions.json`
2. **Build Rust core** — compiles Gemstone with `--locked` to ensure exact Cargo dependency versions
3. **Resolve SPM dependencies** — downloads Swift packages
4. **Archive** — builds with ad-hoc signing, whole-module compilation, and index store disabled
5. **Package IPA** — creates the IPA from the archive

### IPA Comparison

`verify-build compare` (Rust binary in `tools/verify-build/`) compares two IPAs by:

1. Extracting both ZIP archives
2. Skipping non-meaningful files (`_CodeSignature/`, `embedded.mobileprovision`, `SC_Info/`)
3. Normalizing Mach-O binaries (zeroing `LC_UUID`, `LC_CODE_SIGNATURE`, `LC_BUILD_VERSION` timestamps, `LC_SOURCE_VERSION`)
4. Stripping non-deterministic plist keys (`BuildMachineOSBuild`, `DTXcode`, etc.)
5. Byte-for-byte comparison of everything else

## CI

The `verify-build.yml` GitHub Actions workflow automatically:
- Verifies the environment on every version tag
- Builds the IPA twice
- Compares both builds to ensure they match
- Uploads IPAs as artifacts for external verification

## Known Limitations

- **Asset Catalogs (`.car` files)**: These are recompiled by the App Store during processing and will differ when comparing with an App Store IPA. Reported as warnings, not failures.
- **App Store encryption**: App Store IPAs with FairPlay encryption cannot be verified directly. Use a decrypted IPA for comparison.
- **Nib files (`.nib`)**: Interface Builder files may be reprocessed. Reported as warnings.

## File Structure

```
versions.json                              # Pinned tool versions
build-system/scripts/
├── verify-environment.sh                  # Check tool versions
└── reproducible-build.sh                  # Local reproducible build
tools/
└── verify-build/                          # Rust binary: IPA comparison + Mach-O normalizer
```

## Justfile Commands

| Command | Description |
|---------|-------------|
| `just verify-environment` | Check tool versions match `versions.json` |
| `just reproducible-build` | Build IPA locally with ad-hoc signing |
| `just build-verify-tool` | Compile the Rust verify-build binary |
| `just compare-builds IPA1 IPA2` | Compare two IPAs |
| `just verify-build IPA` | Build and compare with provided IPA |
