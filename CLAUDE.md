# CLAUDE.md

This file provides guidance to AI assistants (Claude Code, Gemini, Codex, etc.) when working with code in this repository.

## Project Overview

Gem Wallet is a sophisticated multi-chain cryptocurrency wallet iOS application built with SwiftUI. The project follows a highly modular architecture with a Rust core for blockchain operations and a Swift frontend organized into independent feature modules.

## Architecture

### Modular Structure
The codebase is organized into three main layers:

1. **Features/** - 22 independent UI feature modules (Assets, Transfer, Staking, etc.)
2. **Packages/** - Core utilities and shared components (Primitives, Components, Store, etc.)
3. **Services/** - Business logic and data layer services
4. **core/** - Rust-based blockchain engine integrated via FFI

### Key Architectural Patterns
- **MVVM with SwiftUI**: Observable ViewModels with declarative UI
- **Dependency Injection**: AppResolver pattern with environment-based injection
- **Protocol-Based Design**: Services implement protocols for testability
- **Swift Package Manager**: Each feature and package is an independent SPM module

### Navigation Architecture
- Tab-based navigation with independent NavigationPath stacks per tab
- Centralized NavigationStateManager for state coordination
- Deep linking support via URL parsing and routing

## Development Commands

### Building and Running
```bash
# Bootstrap the project (required for first setup)
just bootstrap

# Clean build artifacts and DerivedData
just clean

# Build the project
just build

# Build a specific package
just build-package $PACKAGE. Example: just build-package Primitives

# Build and run tests
just test-all

# Build and run tests for a specific package
just test $PACKAGE. Example: just test PrimitivesTests

# Run UI tests
just test-ui

# Generate code (models, SwiftGen assets)
just generate

# Generate Rust-to-Swift bindings
just generate-stone
```

### Code Generation
```bash
# Generate model types from Rust core
just generate-model

# Generate SwiftGen assets and localization
just generate-swiftgen

# Update localization files
just localize
```

### Development Tools
```bash
# Resolve all Swift Package dependencies
just spm-resolve-all

# Update core submodule
just core-upgrade

# Generate UML diagrams
just uml-app
```

## Debugging and Troubleshooting

- **Build Logs:** Build logs can be found in `build/DerivedData`. When a `just build` command fails, examine the output in the console for specific Xcode errors.
- **Failing Tests:** When a test fails using `just test TARGET`, first try running the test directly in Xcode to use the interactive debugger.
- **Environment Issues:** If you encounter issues after pulling new changes, run `just bootstrap` again to ensure all dependencies and generated files are up to date.
- **Rust Core Issues:** If you suspect an issue in the `core/` submodule, consult the `core/README.md` for specific Rust-related debugging steps.

### Build Command Guidelines

- **Primary Build Method**: Use `just build` or `just build-package PACKAGE` (already uses xcodebuild internally)
- **If swift build fails**: Use xcodebuild directly instead:
  ```bash
  # For full project build
  xcodebuild -project Gem.xcodeproj -scheme Gem -sdk iphonesimulator -destination "platform=iOS Simulator,name=iPhone 17" build
  ```

## Key Dependencies

### Core Technology Stack
- **SwiftUI**: Native iOS UI framework
- **Swift Package Manager**: Dependency management
- **Rust Core**: Blockchain operations via FFI bindings
- **SQLite**: Local data storage via custom Store package
- **Combine**: Reactive programming support

### External Dependencies
- **WalletCore**: TrustWallet's blockchain library
- **SwiftGen**: Code generation for assets and localization
- **SwiftFormat**: Code formatting

### Apple Documentation Resources
- **Xcode AI Documentation**: `/Applications/Xcode.app/Contents/PlugIns/IDEIntelligenceChat.framework/Versions/A/Resources/AdditionalDocumentation`
  - Contains latest SwiftUI, AppKit, UIKit, and framework documentation
  - Includes guides for new Apple features and APIs
  - Reference these docs when implementing new iOS features or using latest Apple frameworks

## Code Architecture Patterns

### Feature Module Structure
Each feature in `Features/` follows this pattern:
```
Features/[FeatureName]/
├── Package.swift              # Independent SPM package
├── Sources/
│   ├── Scenes/               # SwiftUI Views
│   ├── ViewModels/           # Observable ViewModels
│   ├── Protocols/            # Protocols
│   ├── Types/                # Feature-specific types
│   └── Views/                # Reusable components
│   ├── Services/             # Services
├── Tests/                    # Unit tests
└── TestKit/                  # Testing utilities
```

### Service Layer Pattern
Services follow protocol-based design:
```swift
protocol ServiceProtocol {
    func operation() async throws -> Result
}

class ConcreteService: ServiceProtocol {
    private let store: Store
    private let provider: Provider
    
    func operation() async throws -> Result {
        // Implementation
    }
}
```

### ViewModel Pattern
ViewModels use Swift's @Observable macro:
```swift
@Observable
@MainActor
final class FeatureViewModel {
    private let service: ServiceProtocol
    
    var isLoading: Bool = false
    var data: [Model] = []
    
    func fetch() async { ... }
}
```

### Dependency Injection
Services are injected via SwiftUI Environment:
```swift
.environment(\.walletService, services.walletService)
.environment(\.assetsService, services.assetsService)
```

## Testing Strategy

### Test Organization
- Each feature module has its own test suite
- TestKit packages provide mocking utilities
- Protocol-based testing with dependency injection
- Both unit tests and UI tests are supported

### Running Tests
- Unit tests: `just test`
- UI tests: `just test-ui`
- Specific test: `just test TARGET` (e.g. `just test AssetsTests`)
- Run all tests: `just test-all`
- Tests use iPhone 16 simulator by default
- To run tests, always use the `just` commands above, not direct `xcrun swift test` commands

### Writing Unit Tests

#### Test Structure and Naming
- Use simple, descriptive method names: `showManageToken` not `testShowManageToken_whenAssetIsEnabled_returnsFalse`
- Keep tests extremely concise - 2-3 assertions max per test
- Test only the essential behavior, nothing extra

#### Mock Creation Guidelines
- **Always use existing TestKit mocks** instead of creating custom mock services
- **Create mock extensions in TestKit packages** when they don't exist, not in test files
- **Use clean mock syntax**: `AssetSceneViewModel.mock(.mock(metadata: .mock(isEnabled: true)))`
- If a struct/class doesn't have a `.mock()` method, create one in the appropriate TestKit

#### Example Test Structure
```swift
struct AssetSceneViewModelTests {
    
    @Test
    func showManageToken() {
        #expect(AssetSceneViewModel.mock(.mock(metadata: .mock(isEnabled: true))).showManageToken == false)
        #expect(AssetSceneViewModel.mock(.mock(metadata: .mock(isEnabled: false))).showManageToken == true)
    }

    @Test
    func allBannersActive() {
        let banners = [Banner.mock()]
        let model = AssetSceneViewModel.mock(.mock(metadata: .mock(isActive: true)), banners: banners)
        
        #expect(model.allBanners.count == 1)
        #expect(model.allBanners == banners)
    }
}
```

#### Example Mock Creation
```swift
// In Packages/Primitives/TestKit/Banner+PrimitivesTestKit.swift
public extension Banner {
    static func mock(
        event: BannerEvent = .stake,
        wallet: Wallet = .mock()
    ) -> Banner {
        Banner(
            wallet: wallet,
            event: event
        )
    }
}
```

#### Mock Service Usage
- Use existing service mocks: `WalletsService.mock()`, `AssetsService.mock()`, etc.
- Use shorthand syntax: `.mock()` instead of `WalletsService.mock()`
- Use `.constant(nil)` for bindings instead of creating custom ones
- Follow the pattern of existing TestKit services like `BannerSetupService.mock()`

#### Test Formatting Guidelines
- **Short, simple tests**: Keep inline with direct assertions
  ```swift
  #expect(CollectibleViewModel.mock(assetData: .mock(asset: .mock(tokenId: "12345"))).tokenIdValue == "12345")
  ```
- **Long lines**: Separate model creation from comparison for better readability
  ```swift
  let shortModel = CollectibleViewModel.mock(assetData: .mock(asset: .mock(tokenId: "123")))
  let longModel = CollectibleViewModel.mock(assetData: .mock(asset: .mock(tokenId: "1234567890123456789")))
  
  #expect(shortModel.tokenIdText == "#123")
  #expect(longModel.tokenIdText == "1234567890123456789")
  ```
- **Complex mock setups**: Use multiline formatting with proper indentation
  ```swift
  #expect(CollectibleViewModel.mock(assetData: .mock(
      collection: .mock(contractAddress: "0x123"),
      asset: .mock(tokenId: "456")
  )).contractText == "0x123")
  ```
- **Avoid unnecessary variables** for simple cases - only use when readability is compromised
- **Skip trivial tests**: Don't write tests for simple scenarios like empty collections or obvious behaviors unless they test critical business logic

## Rust Core Integration

### Core Submodule
- Located in `core/` directory
- Shared between iOS and Android applications
- Provides blockchain-specific operations and cryptographic functions
- **IMPORTANT**: When working with the Rust core, read `core/AGENTS.md` for detailed guidance on core architecture, development workflow, and coding standards

### Swift Bindings
- Generated via `just generate-stone`
- Compiled into `GemstoneFFI.xcframework`
- Integrated through `Gemstone` Swift package

### Generated Files
- **IMPORTANT**: Files marked with "Generated by typeshare" comments are auto-generated and will be overwritten
- Notable generated files include:
  - `Packages/Primitives/Sources/WalletConnector.swift`
  - Other model files generated from Rust core
- **Never modify generated files directly** - add extensions in separate files
- Place extensions in the appropriate `Extensions/` directory following the naming pattern: `TypeName+Primitives.swift`

## Development Guidelines

### Build Verification
**CRITICAL REQUIREMENT**: Always verify the project builds successfully before claiming work is complete.

- **ALWAYS run `just build`** before stating that tasks are finished
- **Use xcodebuild if needed**: If `just build` fails or you need to build directly, use xcodebuild (see "Build Command Guidelines" in Debugging section)
- **Fix all build errors** before marking tasks as completed
- **Test core changes** with `just generate-stone` when modifying Rust core
- **Verify iOS integration** after any core modifications
- If build fails, identify and fix all errors before proceeding
- Never claim "migration complete" or "tasks done" without a successful build

### Code Style
- Follow existing SwiftUI and Swift concurrency patterns
- Use `@Observable` for ViewModels instead of `ObservableObject`
- Prefer async/await over Combine for new code
- Use protocol-based design for services
- Avoid adding explanatory comments in tests - test code should be self-documenting
- Never add comments for obvious or simple code operations (e.g., "Check if column exists", "Add column to table", "Verify tables were created")
- When extending types to conform to protocols, use explicit protocol conformance syntax:
  ```swift
  // Good - explicit protocol conformance
  extension MyService: ServiceProtocol {
      func performAction() { }
  }
  
  // Bad - plain extension with comment
  // MARK: - ServiceProtocol
  extension MyService {
      func performAction() { }
  }
  ```
- **Spacing Guidelines**: Always use `Spacing` constants from the `Style` package instead of hardcoded numeric values:
  ```swift
  // Good - using Style constants
  VStack(spacing: Spacing.small) { ... }
  .padding(.vertical, Spacing.extraSmall)
  
  // Bad - hardcoded values
  VStack(spacing: 2) { ... }
  .padding(.vertical, 4)
  ```

### Code Organization
- **One Type Per File**: Each service, type, view model, actor, or component must have its own separate file in the appropriate folder. Never inline multiple types in a single file
- Use `// MARK: - Actions` to separate action methods in ViewModels

### Clean Code Principles
- **YAGNI (You Aren't Gonna Need It)**: Don't add functionality until it's actually needed
- **No Dead Code**: Remove unused methods, properties, and extensions
- **Single Responsibility**: Each class/struct should have one clear purpose
- **Avoid Cargo Cult Programming**: Don't copy patterns from other files without understanding their necessity
- **Code Should Be Self-Documenting**: Use clear, descriptive names instead of comments when possible
- **Keep It Simple**: Avoid over-engineering solutions. A single method is often better than multiple overloaded methods when the use case is straightforward. Don't create unnecessary abstractions or method variations unless they provide clear value

### Module Dependencies
- Features should not directly depend on each other
- Shared functionality goes in Packages/
- Services handle cross-feature business logic

### Adding New Features
1. Create new feature module in `Features/`
2. Follow the established directory structure
3. Add navigation support in `Navigation/`
4. Register with `AppResolver` if needed
5. Include comprehensive tests

### Code Review Guidelines
- **Verify All Code Is Used**: Every method, property, and extension should be called/referenced somewhere
- **Check for Patterns**: Don't blindly copy patterns from existing code without understanding their purpose
- **Minimize API Surface**: Only make public what needs to be public
- **Test-Driven Implementation**: Write tests that verify actual usage, not just coverage

## Release Process

### Branching Strategy
This project follows a GitFlow-like branching strategy:
- `main`: Represents the latest production release.
- `develop`: The primary branch for ongoing development. All feature branches are merged into `develop`.
- `feature/...`: Branches for new features, branched from `develop`.
- `release/...`: Branches for preparing a new production release.
- `hotfix/...`: Branches for critical production fixes.

### Versioning
The project uses semantic versioning (Major.Minor.Patch). The version can be updated using the `just bump-version` command, which leverages the `scripts/bump-version.sh` script.

### Committing Changes
- Before committing, ensure your changes are compliant with the project's style by running formatters and linters if available.
- Write clear, concise commit messages that explain the "why" behind the change.

## Platform Requirements

- **Xcode**: Latest version required
- **macOS**: Apple Silicon Mac recommended (Intel Macs need additional setup)
- **iOS**: Minimum deployment target defined in project settings
- **Swift**: Uses latest Swift features including async/await and @Observable

## Localization

- Managed through Lokalise platform
- Generated files in `Packages/Localization/`
- Update with `just localize`
- Supports 20+ languages

## Security Considerations

- Keystore operations handled by dedicated `Keystore` package
- Biometric authentication supported
- Secure preferences stored in Keychain
- Rust core provides memory-safe cryptographic operations