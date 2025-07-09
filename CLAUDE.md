# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

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

# Build the project
just build

# Build and run tests
just test

# Run UI tests
just test_ui

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

## Code Architecture Patterns

### Feature Module Structure
Each feature in `Features/` follows this pattern:
```
Features/[FeatureName]/
├── Package.swift              # Independent SPM package
├── Sources/
│   ├── Scenes/               # SwiftUI Views
│   ├── ViewModels/           # Observable ViewModels
│   ├── Types/                # Feature-specific types
│   └── Views/                # Reusable components
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
- UI tests: `just test_ui`
- Tests use iPhone 16 simulator by default

## Rust Core Integration

### Core Submodule
- Located in `core/` directory
- Shared between iOS and Android applications
- Provides blockchain-specific operations and cryptographic functions

### Swift Bindings
- Generated via `just generate-stone`
- Compiled into `GemstoneFFI.xcframework`
- Integrated through `Gemstone` Swift package

## Development Guidelines

### Code Style
- Follow existing SwiftUI and Swift concurrency patterns
- Use `@Observable` for ViewModels instead of `ObservableObject`
- Prefer async/await over Combine for new code
- Use protocol-based design for services

### Clean Code Principles
- **YAGNI (You Aren't Gonna Need It)**: Don't add functionality until it's actually needed
- **No Dead Code**: Remove unused methods, properties, and extensions
- **Single Responsibility**: Each class/struct should have one clear purpose
- **Avoid Cargo Cult Programming**: Don't copy patterns from other files without understanding their necessity
- **Code Should Be Self-Documenting**: Use clear, descriptive names instead of comments when possible

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