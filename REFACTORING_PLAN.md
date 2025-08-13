# Remove FeatureServices from SystemServices

## Problem
SystemServices depends on FeatureServices, creating a circular dependency.

## Solution
Create a `ServicePrimitives` target within SystemServices package that exports only protocol definitions.

## Implementation Steps

### 1. Create ServicePrimitives Target

In `SystemServices/Package.swift`, add new product and target:
```swift
products: [
    .library(name: "ServicePrimitives", targets: ["ServicePrimitives"]),
    // ... existing products
]

targets: [
    .target(
        name: "ServicePrimitives",
        dependencies: [
            .product(name: "Primitives", package: "Primitives"),
            .product(name: "Store", package: "Store"),
        ],
        path: "Sources/ServicePrimitives"
    ),
    // ... existing targets
]
```

### 2. Move/Create Protocols

Move existing protocols to `SystemServices/Sources/ServicePrimitives/`:
- From `WalletsService/Protocols/` → move all 6 files
- From `DeviceService/Protocols/` → keep in place (not needed by FeatureServices)
- From `WalletSessionService/Protocols/` → keep in place (not needed by FeatureServices)

Create new protocols in `SystemServices/Sources/ServicePrimitives/`:
```swift
// SwapAssetsProvider.swift
public protocol SwapAssetsProvider {
    func getSwappableAssets(chain: Chain) async throws -> [Asset]
}

// AvatarProvider.swift  
public protocol AvatarProvider {
    func getAvatar(walletId: String) -> Avatar?
    func setAvatar(walletId: String, avatar: Avatar) async throws
}

// AssetsMetadataProvider.swift
public protocol AssetsMetadataProvider {
    func getMetadata(for assetId: String) async throws -> AssetMetadata
    func importAssets(chain: Chain) async throws
}
```

### 3. Update FeatureServices

In `FeatureServices/Package.swift`:
```swift
dependencies: [
    .product(name: "ServicePrimitives", package: "SystemServices"),
    // ... other dependencies
]
```

Make services conform to protocols:
```swift
// AssetsService.swift
extension AssetsService: AssetsEnabler, AssetsMetadataProvider { }

// BalanceService.swift  
extension BalanceService: BalanceUpdater { }

// PriceService.swift
extension PriceService: PriceUpdater { }

// DiscoverAssetsService.swift
extension DiscoverAssetsService: DiscoveryAssetsProcessing { }

// SwapService.swift
extension SwapService: SwapAssetsProvider { }

// AvatarService.swift
extension AvatarService: AvatarProvider { }
```

### 4. Update SystemServices Imports

Replace concrete service imports with protocol usage:

**AppService.swift:**
```swift
// Remove:
import SwapService
import AssetsService

// Add:
import ServicePrimitives

// Keep using injected protocols
private let swapAssetsProvider: any SwapAssetsProvider
private let assetsMetadataProvider: any AssetsMetadataProvider
```

**WalletService.swift:**
```swift
// Remove:
import AvatarService

// Add:
import ServicePrimitives

// Use protocol
private let avatarProvider: any AvatarProvider
```

**WalletsService.swift:**
```swift
// Remove:
import AssetsService
import BalanceService
import DiscoverAssetsService
import PriceService

// Add:
import ServicePrimitives

// Already using protocol types
```

### 5. Clean Up Dependencies

Remove from `SystemServices/Package.swift`:
```swift
.package(name: "FeatureServices", path: "../FeatureServices"),
```

## Benefits

✅ **No circular dependencies** - Clean dependency graph  
✅ **Logical organization** - Protocols stay with their domain  
✅ **Clear hierarchy** - Primitives → ServicePrimitives → Concrete Services  
✅ **Minimal changes** - Most code already uses protocols  
✅ **Follows existing patterns** - Similar to how Features have TestKit targets

## Files to Change

- `SystemServices/Package.swift` - Add new target, remove FeatureServices
- `SystemServices/Sources/ServicePrimitives/` - Move existing + 3 new protocol files  
- `FeatureServices/Package.swift` - Add ServicePrimitives dependency
- 6 FeatureServices service files - Add protocol conformance
- 3 SystemServices service files - Remove concrete imports

**Total: ~15 files**