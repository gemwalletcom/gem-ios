# Unified Earn Architecture Plan v2

## Overview

Rename and unify Stake and DeFi into a clean "Earn" type system with semantic naming, maintaining the proven `base` pattern for efficient data flow.

---

## Implementation Status

> **Last Updated**: 2025-02-05

| Phase | Description | Status | Notes |
|-------|-------------|--------|-------|
| Phase 1 | Core Primitives (Rust) | ✅ Complete | `EarnProvider`, `EarnPositionBase`, `EarnPosition`, `EarnProviderType` |
| Phase 2 | Core Stake Mappers | ⏳ Deferred | Separate PR - affects 7 chain mappers |
| Phase 3 | Core Yielder (Rust) | ✅ Complete | Returns `GemEarnPositionBase` |
| Phase 4 | Gemstone FFI | ✅ Complete | UniFFI exports for all Earn types |
| Phase 5 | iOS Store | ✅ Complete | New `earn_*` tables for DeFi yield |
| Phase 6 | iOS Services | ✅ Complete | `EarnService`, `EarnBalanceService` |
| Phase 7 | iOS Transfer Flow | ⏳ Pending | Depends on Phase 2 |
| Phase 8 | iOS Features | ✅ Complete | ViewModels use unified types |
| Phase 9 | Testing & Cleanup | ⏳ Pending | |

### Current Architecture Decision

**Phased Approach**: Staking and DeFi yield use **separate tables** for now:
- `stake_validators` + `stake_delegations` → Staking (existing)
- `earn_providers` + `earn_positions` → DeFi Yield (new)

Full unification (renaming stake tables to earn tables) deferred to Phase 2 PR.

---

## Problem: Current Naming Issues

| Issue | Current State | Problem |
|-------|---------------|---------|
| `DelegationValidator` for DeFi | Yo stored as DelegationValidator | Yo is not a validator |
| `validator_id` field | Stores "yo" | Field name implies blockchain validator |
| `stake_validators` table | Would store DeFi providers | "stake" prefix for DeFi data |
| `commission` field | Set to 0 for DeFi | DeFi has "fees", not "commission" |
| `apr` field | Used for APY too | Stake = APR, DeFi = APY |

---

## Proposed Type System

### Core Types (Rust)

```rust
pub enum EarnProviderType {
    Stake,
    Yield,
}

pub struct EarnProvider {
    pub chain: Chain,
    pub id: String,
    pub name: String,
    pub is_active: bool,
    pub fee: f64,
    pub apy: f64,
    pub provider_type: EarnProviderType,
}

pub enum EarnPositionState {
    Active,
    Pending,
    Inactive,
    Activating,
    Deactivating,
    AwaitingWithdrawal,
}

pub struct EarnPositionBase {
    pub asset_id: AssetId,
    pub state: EarnPositionState,
    pub balance: BigUint,
    pub shares: BigUint,
    pub rewards: BigUint,
    pub unlock_date: Option<DateTime<Utc>>,
    pub position_id: String,
    pub provider_id: String,
}

pub struct EarnPosition {
    pub base: EarnPositionBase,
    pub provider: EarnProvider,
    pub price: Option<Price>,
}
```

---

## Why `base` Pattern is Required

### Data Flow Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│ Core (Rust) - Blockchain RPC                                    │
│                                                                 │
│  Stake: get_delegations() → Vec<EarnPositionBase>             │
│  DeFi:    positions()       → Vec<EarnPositionBase>             │
│                                                                 │
│  Validators: get_validators() → Vec<EarnProvider>               │
│  Protocols: yields()          → Vec<EarnProvider>               │
└─────────────────────────────────────────────────────────────────┘
                              ↓ (separate calls)
┌─────────────────────────────────────────────────────────────────┐
│ iOS Services                                                    │
│                                                                 │
│  EarnService.updatePositions(positions: [EarnPositionBase])     │
│  EarnService.updateProviders(providers: [EarnProvider])         │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│ iOS Store (SQLite)                                              │
│                                                                 │
│  ┌─────────────────┐     FK      ┌─────────────────┐            │
│  │ earn_positions  │────────────→│ earn_providers  │            │
│  │ (EarnPosition-  │             │ (EarnProvider)  │            │
│  │  Base data)     │             └─────────────────┘            │
│  └─────────────────┘                                            │
│           │                                                     │
│           │ FK (asset_id)                                       │
│           ↓                                                     │
│  ┌─────────────────┐                                            │
│  │ prices          │                                            │
│  └─────────────────┘                                            │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│ Query Time (GRDB JOINs)                                         │
│                                                                 │
│  EarnPositionRecord                                             │
│    .including(optional: .provider)                              │
│    .including(optional: .price)                                 │
│    .map { $0.mapToPosition() }                                  │
│                                                                 │
│  → EarnPosition { base, provider, price }                       │
└─────────────────────────────────────────────────────────────────┘
```

### Why Separation Matters

| Component | Update Frequency | Source |
|-----------|-----------------|--------|
| `EarnPositionBase` | Often (balance, rewards change) | Blockchain RPC |
| `EarnProvider` | Rarely (APY, fee changes) | Separate RPC / API |
| `Price` | Constantly | Pricing service |

### Key Design Principle

Services take `EarnPositionBase` for updates, NOT full `EarnPosition`:

```swift
func updatePositions(walletId: WalletId, positions: [EarnPositionBase])
```

---

## Field Semantics

### Provider Fields

| Field | Validator (Stake) | Vault (DeFi) |
|-------|---------------------|--------------|
| `id` | validator address | protocol ID ("yo") |
| `name` | "Coinbase Cloud" | "Yo Finance" |
| `fee` | 5-20% commission | 0% (or protocol fee) |
| `apy` | chain yield ~5-15% | protocol APY ~3-8% |
| `provider_type` | `.stake` | `.yield` |

### Position Fields

| Field | Stake Position | DeFi Position |
|-------|------------------|---------------|
| `balance` | staked amount | deposited asset value |
| `shares` | delegation shares | vault token balance |
| `rewards` | claimable rewards | 0 (auto-compound) |
| `state` | Active/Pending/etc | Active (usually) |
| `unlock_date` | unbonding end date | nil (instant) |
| `provider_id` | validator address | protocol ID |

---

## Database Schema

> **Implementation Note**: Swift/GRDB uses camelCase for column names (project convention).

### Planned Schema (SQL Convention)

```sql
-- Provider table (validators + protocols)
CREATE TABLE earn_providers (
    id TEXT PRIMARY KEY,              -- chain_providerId (e.g., "base_yo")
    chain TEXT NOT NULL,
    provider_id TEXT NOT NULL,        -- validator address or "yo"
    name TEXT NOT NULL,
    is_active BOOLEAN NOT NULL,
    fee REAL NOT NULL DEFAULT 0,
    apy REAL NOT NULL DEFAULT 0,
    provider_type TEXT NOT NULL       -- 'stake' or 'yield'
);

-- Position table (delegations + vault positions)
CREATE TABLE earn_positions (
    id TEXT PRIMARY KEY,              -- walletId_positionId
    wallet_id TEXT NOT NULL,
    asset_id TEXT NOT NULL,
    provider_id TEXT NOT NULL,        -- FK to earn_providers.id (full format: "base_yo")
    state TEXT NOT NULL,
    balance TEXT NOT NULL DEFAULT '0',
    shares TEXT NOT NULL DEFAULT '0',
    rewards TEXT NOT NULL DEFAULT '0',
    unlock_date DATETIME,
    position_id TEXT NOT NULL,

    FOREIGN KEY (wallet_id) REFERENCES wallets(id) ON DELETE CASCADE,
    FOREIGN KEY (asset_id) REFERENCES assets(id) ON DELETE CASCADE,
    FOREIGN KEY (provider_id) REFERENCES earn_providers(id) ON DELETE CASCADE
);

CREATE INDEX idx_earn_positions_wallet ON earn_positions(wallet_id);
CREATE INDEX idx_earn_positions_asset ON earn_positions(asset_id);
CREATE INDEX idx_earn_positions_provider ON earn_positions(provider_id);
```

### ✅ Actual Implementation (Swift/GRDB)

```swift
// EarnProviderRecord - table: "earn_providers"
public struct EarnProviderRecord {
    var id: String           // "base_yo" (chain_providerId)
    var chain: String        // "base"
    var providerId: String   // "yo"
    var name: String
    var isActive: Bool
    var fee: Double
    var apy: Double
    var providerType: String // "stake" or "yield"
}

// EarnPositionRecord - table: "earn_positions"
public struct EarnPositionRecord {
    var id: String           // "walletId_positionId"
    var walletId: String
    var assetId: AssetId
    var providerId: String   // FK: "base_yo" (full provider record ID)
    var state: String
    var balance: String
    var shares: String
    var rewards: String
    var unlockDate: Date?
    var positionId: String
}
```

### Provider ID Format (Critical)

The `providerId` field has different formats at different layers:

| Layer | Format | Example |
|-------|--------|---------|
| Rust `EarnPositionBase.provider_id` | Simple ID | `"yo"` |
| Swift `EarnPositionBase.providerId` | Simple ID | `"yo"` |
| DB `EarnPositionRecord.providerId` | Full record ID | `"base_yo"` |
| DB `EarnProviderRecord.id` (PK) | Full record ID | `"base_yo"` |

**Conversion Functions**:
```swift
extension EarnPositionBase {
    var fullProviderId: String {
        "\(assetId.chain.rawValue)_\(providerId)"
    }
}

private func extractProviderId(from fullId: String) -> String {
    let parts = fullId.split(separator: "_", maxSplits: 1)
    return parts.count > 1 ? String(parts[1]) : fullId
}
```

---

## Type Mapping (Old → New)

### Core (Rust)

| Old | New |
|-----|-----|
| `DelegationValidator` | `EarnProvider` |
| `DelegationBase` | `EarnPositionBase` |
| `Delegation` | `EarnPosition` |
| `DelegationState` | `EarnPositionState` |
| `EarnType` | `EarnProviderType` |
| `StakeType` | `EarnStakeType` |
| `EarnAction` | `EarnYieldType` |
| `commission` field | `fee` |
| `apr` field | `apy` |
| `validator_id` field | `provider_id` |
| `completion_date` field | `unlock_date` |
| `delegation_id` field | `position_id` |

### iOS (Swift)

| Old | New |
|-----|-----|
| `StakeValidatorRecord` | `EarnProviderRecord` |
| `StakeDelegationRecord` | `EarnPositionRecord` |
| `StakeDelegationInfo` | `EarnPositionInfo` |
| `StakeStore` | `EarnStore` |
| `stake_validators` table | `earn_providers` table |
| `stake_delegations` table | `earn_positions` table |

---

## File Changes

### Core (Rust) - Primitives Crate

| Action | File | Change |
|--------|------|--------|
| Rename | `primitives/src/delegation.rs` | → `primitives/src/earn_position.rs` |
| Rename | `DelegationValidator` | → `EarnProvider` |
| Rename | `DelegationBase` | → `EarnPositionBase` |
| Rename | `Delegation` | → `EarnPosition` |
| Rename | `DelegationState` | → `EarnPositionState` |
| Rename | `primitives/src/stake_type.rs` | → `primitives/src/earn_stake_type.rs` |
| Rename | `StakeType` | → `EarnStakeType` |
| Rename | `primitives/src/earn_action.rs` | → Add embedded data, rename to `EarnYieldType` |
| Create | `primitives/src/earn_provider_type.rs` | `EarnProviderType { Stake, Yield }` enum |
| Delete | `primitives/src/earn_provider.rs` | Old `EarnProvider` enum (Yo variant) |
| Delete | `primitives/src/earn_position.rs` | Old `EarnPosition` struct (DeFi-specific) |
| Delete | `primitives/src/earn_data.rs` | No longer needed (data embedded in EarnYieldType) |
| Update | `primitives/src/lib.rs` | Update exports |

### Core (Rust) - Yielder Crate

| Action | File | Change |
|--------|------|--------|
| Update | `yielder/src/models.rs` | Remove type aliases, use new types directly |
| Update | `yielder/src/yo/provider.rs` | Return `EarnPositionBase` instead of old `EarnPosition` |
| Update | `yielder/src/provider.rs` | Update trait to use `EarnPositionBase` |

### Core (Rust) - Stake Mappers (All Chains)

| Action | File | Change |
|--------|------|--------|
| Update | `gem_cosmos/src/provider/staking_mapper.rs` | Use `EarnProvider`, `EarnPositionBase` |
| Update | `gem_solana/src/provider/staking_mapper.rs` | Use `EarnProvider`, `EarnPositionBase` |
| Update | `gem_sui/src/provider/staking_mapper.rs` | Use `EarnProvider`, `EarnPositionBase` |
| Update | `gem_aptos/src/provider/staking_mapper.rs` | Use `EarnProvider`, `EarnPositionBase` |
| Update | `gem_tron/src/provider/staking_mapper.rs` | Use `EarnProvider`, `EarnPositionBase` |
| Update | `gem_evm/src/provider/staking_mapper.rs` | Use `EarnProvider`, `EarnPositionBase` |
| Update | `gem_evm/src/rpc/staking_mapper.rs` | Use `EarnProvider`, `EarnPositionBase` |

### Gemstone FFI

| Action | File | Change |
|--------|------|--------|
| Update | `gem_yielder/remote_types.rs` | Use new types |
| Update | `models/stake.rs` | Rename Gem types |
| Remove | `GemEarnPosition` (old) | Replaced by new |
| Remove | `GemEarnProvider` (old) | Replaced by new |

### iOS Store

| Action | File | Change |
|--------|------|--------|
| Rename | `StakeValidatorRecord.swift` | → `EarnProviderRecord.swift` |
| Rename | `StakeDelegationRecord.swift` | → `EarnPositionRecord.swift` |
| Rename | `StakeDelegationInfo.swift` | → `EarnPositionInfo.swift` |
| Rename | `StakeStore.swift` | → `EarnStore.swift` |
| Delete | `EarnPositionRecord.swift` (old) | Replaced |
| Delete | `EarnStore.swift` (old) | Merged |
| Add | Migration | Rename tables, add `provider_type` |

### iOS Services

| Action | File | Change |
|--------|------|--------|
| Rename | `StakeService.swift` | → Merge into `EarnService.swift` |
| Update | `EarnService.swift` | Handle both staking + vault |
| Update | `EarnBalanceService.swift` | Use unified store |

### iOS Primitives (Generated + Extensions)

| Action | File | Change |
|--------|------|--------|
| Auto-gen | `Delegation.swift` | → Renamed to `EarnPosition.swift` |
| Auto-gen | `DelegationBase.swift` | → Renamed to `EarnPositionBase.swift` |
| Auto-gen | `DelegationValidator.swift` | → Renamed to `EarnProvider.swift` |
| Auto-gen | `DelegationState.swift` | → Renamed to `EarnPositionState.swift` |
| Auto-gen | `StakeType.swift` | → Renamed to `EarnStakeType.swift` |
| Auto-gen | `EarnAction.swift` | → Renamed to `EarnYieldType.swift` (with embedded data) |
| Auto-gen | `EarnProviderType.swift` | NEW generated file |
| Delete | `EarnPosition.swift` (old) | Replaced by new unified type |
| Delete | `EarnProvider.swift` (old) | Replaced by new unified type |
| Delete | `EarnData.swift` | No longer needed (data embedded in EarnYieldType) |
| Update | `GemEarnPosition+GemstonePrimitives.swift` | Use new types |
| Update | `GemEarnPosition+EarnService.swift` | Use new types |

### iOS Transfer Flow

| Action | File | Change |
|--------|------|--------|
| Update | `TransferDataType.swift` | Rename `.earn` → `.vault`, remove `EarnData` param |
| Update | `AmountType.swift` | Update cases for new types |
| Update | `AmountInput.swift` | Update for new types |
| Update | `AmountStakeViewModel.swift` | Use `EarnProvider`, `EarnPosition` |
| Update | `AmountEarnViewModel.swift` | Use `EarnYieldType` with embedded data |
| Update | `AmountDataProvider.swift` | Update type mapping |
| Update | `TransferTransactionProvider.swift` | Handle unified types |

### iOS Features (Earn)

| Action | File | Change |
|--------|------|--------|
| Update | `StakeDetailSceneViewModel.swift` | Use `EarnProvider`, `EarnPosition` |
| Update | `StakeDelegationViewModel.swift` | Use `EarnPosition` |
| Update | `EarnProtocolsSceneViewModel.swift` | Use `EarnProvider`, `EarnYieldType` |
| Update | `EarnPositionViewModel.swift` | Use unified `EarnPosition` |
| Update | `EarnProtocolViewModel.swift` | Use `EarnProvider` |
| Update | `EarnSceneViewModel.swift` | Use unified types |

### iOS Requests

| Action | File | Change |
|--------|------|--------|
| Update | `StakeValidatorsRequest.swift` | → `EarnProvidersRequest.swift` |
| Update | `EarnDelegationsRequest.swift` | Use unified types |
| Update | `EarnPositionsRequest.swift` | Query unified table |

---

## Verification Results & Additional Pitfalls

### Codebase Verification (Deep Check)

The following verification was performed against the actual iOS and Rust codebases:

#### ✅ Verified Correct

| Plan Item | Current State | Status |
|-----------|---------------|--------|
| `DelegationValidator` fields | `chain`, `id`, `name`, `is_active`, `commission`, `apr` | ✅ Matches |
| `DelegationBase` fields | `asset_id`, `state`, `balance`, `shares`, `rewards`, `completion_date`, `delegation_id`, `validator_id` | ✅ Matches |
| `DelegationState` enum | Active, Pending, Inactive, Activating, Deactivating, AwaitingWithdrawal | ✅ Matches |
| `StakeType` embedded data | Stake(Validator), Unstake(Delegation), Redelegate(Data), etc. | ✅ Matches |
| `EarnAction` simple enum | Deposit, Withdraw (no embedded data) | ✅ Matches |
| `EarnData` struct | provider, contract_address, call_data, approval, gas_limit | ✅ Matches |
| iOS `StakeDelegationRecord` | Matches DelegationBase fields | ✅ Matches |
| iOS `StakeValidatorRecord` | Matches DelegationValidator fields | ✅ Matches |

#### ⚠️ Additional Issues Discovered

### 12. Vault-Specific Fields Mismatch

**Problem**: Current DeFi `EarnPosition` has fields not in proposed `EarnPositionBase`:

| Current EarnPosition (DeFi) | Proposed EarnPositionBase | Resolution |
|----------------------------|---------------------------|------------|
| `vault_token_address` | NOT included | Derivable ✅ |
| `asset_token_address` | NOT included | Derivable ✅ |
| `vault_balance_value` | `shares` | Map directly |
| `asset_balance_value` | `balance` | Map directly |
| `balance` (string) | `balance` (BigUint) | Same concept |
| `apy` | Provider's `apy` field | Move to provider |

**Verification**: In `yo/provider.rs`:
```rust
vault_token_address: vault.yo_token.to_string(),
asset_token_address: vault.asset_token.to_string(),
```

**Solution**: These addresses are derivable from `provider + asset_id` via vault configuration. Not stored in unified table.

### 13. Field Mapping for DeFi Positions

**Current → Unified mapping:**
```
EarnPosition.vault_balance_value → EarnPositionBase.shares    // Vault token balance
EarnPosition.asset_balance_value → EarnPositionBase.balance   // Asset value
EarnPosition.balance (string)    → (same as asset_balance_value, redundant)
EarnPosition.apy                 → EarnProvider.apy           // Move to provider
EarnPosition.rewards             → EarnPositionBase.rewards   // Optional<String> → BigUint
```

### 14. GemStakeType FFI Naming Mismatch

**Problem**: FFI uses different case names than primitives:

| Primitives `StakeType` | Gemstone `GemStakeType` |
|------------------------|-------------------------|
| `Stake` | `Delegate` |
| `Unstake` | `Undelegate` |
| `Rewards` | `WithdrawRewards` |

**Decision**: Keep FFI names as-is (breaking change not worth it), rename to:
- `GemEarnStakeType::Delegate`, `Undelegate`, etc.

### 15. EarnData Removal Verification

**Question**: Can we remove `GemEarnData` and embed data in `EarnYieldType`?

**Verification**: In iOS, `EarnData` is created with mostly `nil` values (only `provider` is set; rest computed in Rust).

**Conclusion**: Safe to remove.

### 16. Store Caching Pattern Difference

**Current difference:**
- `StakeStore`: Caches validators, filters delegations by validator existence
- `EarnStore`: No provider caching, simpler CRUD

**Unified approach:**
```swift
func updatePositions(positions: [EarnPositionBase]) {
    let providerIds = try getProviderIds()
    let validPositions = positions.filter { providerIds.contains($0.providerId) }
    try upsertPositions(validPositions)
}
```

### 17. Provider ID Format

**Stake provider ID**: `cosmos_cosmosvaloper1abc...` (chain + validator address)
**Vault provider ID**: `base_yo` (chain + protocol name)

**Schema supports both:**
```sql
earn_providers.id = "{chain}_{provider_id}"
```

### 18. iOS AmountType Changes Missing

**Problem**: Plan doesn't detail changes to `AmountType` and `AmountInput` enums.

**Current:**
```swift
enum AmountType {
    case stake(validators: [DelegationValidator], recommendedValidator: DelegationValidator?)
    case stakeUnstake(delegation: Delegation)
    case stakeRedelegate(delegation: Delegation, validators: [DelegationValidator], recommended: DelegationValidator?)
    case stakeWithdraw(delegation: Delegation)
    case earn(action: EarnAction, data: EarnData, depositedBalance: BigInt?)
}
```

**After renaming:**
```swift
enum AmountType {
    case stake(providers: [EarnProvider], recommended: EarnProvider?)
    case stakeUnstake(position: EarnPosition)
    case stakeRedelegate(position: EarnPosition, providers: [EarnProvider], recommended: EarnProvider?)
    case stakeWithdraw(position: EarnPosition)
    case vaultDeposit(provider: EarnProvider, depositedBalance: BigInt?)
    case vaultWithdraw(position: EarnPosition)
}
```

### 19. TransferDataType Changes

**Current:**
```swift
enum TransferDataType {
    case stake(Asset, StakeType)
    case earn(Asset, EarnAction, EarnData)
}
```

**After unification:**
```swift
enum TransferDataType {
    case stake(Asset, EarnStakeType)
    case vault(Asset, EarnYieldType)
}
```

### 20. Balance Columns Consideration

**Current `BalanceRecord` has:**
- `stakedAmount` - for staking
- `earnAmount` - for DeFi

**Question**: Unify into single `earnAmount`?

**Recommendation**: Keep both during transition, then unify after migration verified.

---

## Edge Cases & Pitfalls

### 1. Migration: Existing Data

**Problem**: Users have existing `stake_delegations` and `stake_validators` data.

**Solution**:
```swift
migrator.registerMigration("renameStakeToEarn") { db in
    try db.alter(table: "stake_validators") { t in
        t.add(column: "provider_type", .text).defaults(to: "validator")
    }
    try db.rename(table: "stake_validators", to: "earn_providers")
    try db.rename(table: "stake_delegations", to: "earn_positions")
}
```

### 2. Foreign Key: Provider Must Exist

**Problem**: Position references `provider_id`, but provider might not be stored yet.

**Solution**: Same pattern as staking - filter positions by existing provider IDs:
```swift
func updatePositions(positions: [EarnPositionBase]) {
    let providerIds = try getProviderIds()
    let validPositions = positions.filter { providerIds.contains($0.providerId) }
}
```

### 3. DeFi: Provider Record Creation

**Problem**: For staking, validators come from blockchain. For DeFi, where does `EarnProvider` come from?

**Solution**: Create provider when fetching yields:
```swift
let yields = try await yielder.yieldsForAsset(assetId: assetId)
for yield in yields {
    let provider = EarnProvider(
        chain: yield.chain,
        id: yield.provider,
        name: yield.name,
        isActive: true,
        fee: 0,
        apy: yield.apy ?? 0,
        providerType: .yield
    )
    try earnStore.updateProvider(provider)
}
```

### 4. Position ID Generation

**Problem**: Stake uses `delegationId` from blockchain. DeFi doesn't have this.

**Solution**: Generate consistent IDs:
```rust
position_id: delegation.delegation_id.clone()  // staking
position_id: format!("{}-{}", provider_id, asset_id)  // DeFi
```

### 5. State for DeFi Positions

**Problem**: DeFi positions are always "Active" - no complex state machine.

**Solution**: Default to `Active` for vault type:
```swift
extension EarnPositionBase {
    var effectiveState: EarnPositionState {
        if providerType == .yield { return .active }
        return state
    }
}
```

### 6. Rewards Semantics

**Problem**: Stake has claimable rewards. DeFi auto-compounds (rewards = 0).

**Solution**: Document and handle in UI:
```swift
extension EarnPosition {
    var hasClaimableRewards: Bool {
        provider.providerType == .validator && base.rewards > 0
    }

    var rewardsDescription: String {
        switch provider.providerType {
        case .validator: return "Claimable: \(formattedRewards)"
        case .yield: return "Auto-compounded"
        }
    }
}
```

### 7. Unlock Date for DeFi

**Problem**: Stake has unbonding period. DeFi has instant withdrawals.

**Solution**: `unlock_date` is `nil` for vault positions:
```swift
extension EarnPosition {
    var canWithdrawImmediately: Bool {
        provider.providerType == .yield || base.unlockDate == nil
    }
}
```

### 8. APY vs APR Display

**Problem**: Stake typically shows APR, DeFi shows APY.

**Solution**: Store as `apy`, add display helper:
```swift
extension EarnProvider {
    var formattedYield: String {
        switch providerType {
        case .validator: return "\(apy)% APR"
        case .yield: return "\(apy)% APY"
        }
    }
}
```

### 9. Android Coordination

**Problem**: Core is shared with Android. Renaming affects both platforms.

**Solution**:
1. Coordinate timing with Android team
2. Add type aliases during transition:
```rust
pub type DelegationValidator = EarnProvider;
pub type DelegationBase = EarnPositionBase;
pub type Delegation = EarnPosition;
```

### 10. Actions: Rename for Consistency

**Current State**:
```rust
pub enum StakeType { ... }    // "Stake" prefix
pub enum EarnAction { ... }   // "Earn" prefix - inconsistent
```

**Solution**: Rename both to use consistent `Earn*Type` pattern with embedded data:
```rust
pub enum EarnStakeType {
    Stake { provider: EarnProvider },
    Unstake { position: EarnPosition },
    Redelegate { position: EarnPosition, to_provider: EarnProvider },
    Rewards { providers: Vec<EarnProvider> },
    Withdraw { position: EarnPosition },
    Freeze { freeze_data: FreezeData },
}

pub enum EarnYieldType {
    Deposit { provider: EarnProvider, amount: BigUint },
    Withdraw { position: EarnPosition },
}
```

### 11. TransactionInputType: Unified Pattern

**Current**: Two separate variants with inconsistent data patterns.

**New**: Both use embedded data, no separate `GemEarnData` struct needed:
```rust
pub enum GemTransactionInputType {
    Stake {
        asset: GemAsset,
        stake_type: GemEarnStakeType,       // Embedded data
    },
    Vault {
        asset: GemAsset,
        vault_type: GemEarnYieldType,       // Embedded data (unified!)
    },
}
```

**Delete**: `GemEarnData` struct is no longer needed - data is embedded in `EarnYieldType`.

---

## Implementation Phases

### Phase 1: Core Primitives (Rust) ✅ COMPLETE

**Goal**: Rename and add `EarnProviderType` to primitives crate.

**Completed**:
- [x] Created `EarnProviderType { Stake, Yield }` enum
- [x] Created `EarnProvider` struct with `chain`, `id`, `name`, `isActive`, `fee`, `apy`, `providerType`
- [x] Created `EarnPositionState` enum (Active, Pending, Inactive, etc.)
- [x] Created `EarnPositionBase` struct with `assetId`, `state`, `balance`, `shares`, `rewards`, `unlockDate`, `positionId`, `providerId`
- [x] Created `EarnPosition` struct with `base`, `provider`, `price`
- [x] Created `YieldProvider` enum (yo variant)
- [x] Updated `lib.rs` exports

**Files Created/Updated**:
- `core/crates/primitives/src/earn_provider.rs`
- `core/crates/primitives/src/earn_position_base.rs`
- `core/crates/primitives/src/earn_position.rs`

### Phase 2: Core Stake Mappers (Rust) ⏳ DEFERRED

**Goal**: Update all blockchain staking mappers to use new types.

**Reason for Deferral**: Affects 7 chain mappers and staking functionality. Should be done in a separate PR to minimize risk.

**Pending**:
- [ ] Update `gem_cosmos/src/provider/staking_mapper.rs`
- [ ] Update `gem_solana/src/provider/staking_mapper.rs`
- [ ] Update `gem_sui/src/provider/staking_mapper.rs`
- [ ] Update `gem_aptos/src/provider/staking_mapper.rs`
- [ ] Update `gem_tron/src/provider/staking_mapper.rs`
- [ ] Update `gem_evm/src/provider/staking_mapper.rs`
- [ ] Update `gem_evm/src/rpc/staking_mapper.rs`

### Phase 3: Core Yielder (Rust) ✅ COMPLETE

**Goal**: Update yielder crate to return unified types.

**Completed**:
- [x] `yielder/src/yo/provider.rs` returns `GemEarnPositionBase`
- [x] Position ID format: `"{provider}-{asset_id}"` (e.g., "yo-base_0x123...")
- [x] Vault-specific fields (vault_token_address, etc.) are derivable, not stored

### Phase 4: Gemstone FFI (Rust) ✅ COMPLETE

**Goal**: Update FFI bindings for iOS/Android.

**Completed**:
- [x] UniFFI exports for `GemEarnProvider`, `GemEarnProviderType`
- [x] UniFFI exports for `GemEarnPositionBase`, `GemEarnPositionState`
- [x] UniFFI exports for `GemEarnPosition`
- [x] `GemYield` returns provider info for mapping to `EarnProvider`

**Files**:
- `core/gemstone/src/models/earn.rs`

### Phase 5: iOS Store Migration ✅ COMPLETE

**Goal**: Create database schema for DeFi yield (separate from staking for now).

**Completed**:
- [x] Created `EarnProviderRecord` with normalized schema
- [x] Created `EarnPositionRecord` with FK to providers
- [x] Created `EarnPositionInfo` for JOIN queries
- [x] Created `EarnStore` with CRUD operations
- [x] Added migration: "Create earn_providers and earn_positions tables"
- [x] FK constraint validation (providers must exist before positions)
- [x] CASCADE deletes (deleting provider deletes related positions)
- [x] Provider ID format conversion (simple ↔ full)

**Key Implementation Details**:
```swift
// Migration order: providers FIRST, then positions
migrator.registerMigration("Create earn_providers and earn_positions tables") { db in
    try? db.drop(table: EarnPositionRecord.databaseTableName)
    try EarnProviderRecord.create(db: db)
    try EarnPositionRecord.create(db: db)
}

// FK validation before insert
public func updatePosition(_ position: EarnPositionBase, walletId: WalletId) throws {
    let providerIds = try getProviderIds()
    guard providerIds.contains(position.fullProviderId) else { return }
    try db.write { db in
        try position.record(walletId: walletId.id).upsert(db)
    }
}
```

**Files**:
- `Packages/Store/Sources/Models/EarnProviderRecord.swift`
- `Packages/Store/Sources/Models/EarnPositionRecord.swift`
- `Packages/Store/Sources/Stores/EarnStore.swift`
- `Packages/Store/Sources/Requests/EarnPositionsRequest.swift`
- `Packages/Store/Sources/Migrations.swift`

### Phase 6: iOS Services ✅ COMPLETE

**Goal**: Service layer for DeFi yield operations.

**Completed**:
- [x] `EarnService` - fetches providers and positions from Rust
- [x] `EarnBalanceService` - updates positions and aggregates balance
- [x] Data flow: providers stored FIRST (FK constraint), then positions
- [x] Mappings: `GemYield` → `EarnProvider`, `GemEarnPositionBase` → `EarnPositionBase`

**Key Implementation**:
```swift
public func updatePositions(walletId: WalletId, assetId: AssetId, address: String) async {
    // 1. Fetch and store providers first (required for FK constraint)
    let providers = try await earnService.getProviders(for: assetId)
    try earnStore.updateProviders(providers)

    // 2. Fetch and store positions for each provider
    for provider in YieldProvider.allCases {
        let position = try await earnService.fetchPosition(provider: provider, ...)
        try earnStore.updatePosition(position.map(), walletId: walletId)
    }

    // 3. Update aggregated earn balance
    updateEarnBalance(walletId: walletId, assetId: assetId)
}
```

**Files**:
- `Packages/FeatureServices/EarnService/EarnService.swift`
- `Packages/FeatureServices/EarnService/EarnServiceType.swift`
- `Packages/FeatureServices/EarnService/EarnBalanceService.swift`

### Phase 7: iOS Transfer Flow ⏳ PENDING

**Goal**: Update transaction building flow.

**Depends on**: Phase 2 (Stake Mappers) for full unification.

**Current State**: DeFi uses existing `EarnAction` + `EarnData` pattern.

### Phase 8: iOS Features ✅ COMPLETE

**Goal**: Update ViewModels and Views for DeFi yield.

**Completed**:
- [x] `EarnProvidersViewModel` - displays available yield providers
- [x] `EarnProviderViewModel` - single provider display
- [x] `EarnPositionViewModel` - uses `EarnPosition.base` for position data
- [x] `EarnSceneViewModel` - integrates with EarnStore

**Files**:
- `Features/Earn/Sources/EarnProtocols/ViewModels/EarnProvidersViewModel.swift`
- `Features/Earn/Sources/EarnProtocols/ViewModels/EarnProviderViewModel.swift`
- `Features/Earn/Sources/EarnProtocols/ViewModels/EarnPositionViewModel.swift`

### Phase 9: Testing & Cleanup ⏳ PENDING

**Goal**: Verify all flows and clean up.

**Pending**:
- [ ] Run all unit tests: `just test-all`
- [ ] Test vault flow end-to-end (deposit, withdraw)
- [ ] Remove unused files
- [ ] Update documentation

---

---

## Bugs Fixed During Implementation

### 1. FK Mismatch: Provider ID Format

**Problem**: `EarnPositionRecord.providerId` stored simple ID ("yo") but FK referenced `EarnProviderRecord.id` which uses full format ("base_yo").

**Symptom**: FK constraint would fail on insert; validation check `providerIds.contains(position.providerId)` always returned false.

**Fix**:
```swift
// Write path: Convert simple → full
extension EarnPositionBase {
    public var fullProviderId: String {
        "\(assetId.chain.rawValue)_\(providerId)"
    }

    public func record(walletId: String) -> EarnPositionRecord {
        EarnPositionRecord(
            ...
            providerId: fullProviderId,  // Store "base_yo" not "yo"
            ...
        )
    }
}

// Read path: Convert full → simple
private func extractProviderId(from fullId: String) -> String {
    let parts = fullId.split(separator: "_", maxSplits: 1)
    return parts.count > 1 ? String(parts[1]) : fullId
}
```

### 2. Missing Migration Order

**Problem**: Migration created `earn_positions` table (with FK to `earn_providers`) before `earn_providers` table existed.

**Fix**: Updated migration to create providers table first:
```swift
migrator.registerMigration("Create earn_providers and earn_positions tables") { db in
    try? db.drop(table: EarnPositionRecord.databaseTableName)
    try EarnProviderRecord.create(db: db)      // FIRST
    try EarnPositionRecord.create(db: db)      // SECOND (has FK to providers)
}
```

---

## Implementation Decisions

### 1. Separate Tables (Phased Approach)

**Decision**: Keep staking and DeFi yield in separate table sets for now.

| Feature | Tables | Reason |
|---------|--------|--------|
| Staking | `stake_validators`, `stake_delegations` | Existing, stable |
| DeFi Yield | `earn_providers`, `earn_positions` | New, unified schema |

**Future**: Rename stake tables to earn tables after Phase 2 (Stake Mappers).

### 2. Record ID Format

**Decision**: Use `walletId_positionId` instead of `walletId_assetId_providerId_positionId`.

**Rationale**:
- DeFi `positionId` already contains provider and asset: `"yo-base_0x123..."`
- Staking `positionId` comes from blockchain (globally unique per chain)
- Simpler format, lower collision risk

### 3. Column Naming Convention

**Decision**: Use camelCase for all column names (Swift convention).

| Plan2 (SQL) | Implementation (Swift) |
|-------------|------------------------|
| `provider_id` | `providerId` |
| `wallet_id` | `walletId` |
| `unlock_date` | `unlockDate` |
| `provider_type` | `providerType` |

**Rationale**: Consistent with rest of codebase and GRDB conventions.

### 4. Provider Type Values

**Decision**: Use Rust enum raw values directly.

| Plan2 Comment | Actual Value |
|---------------|--------------|
| `'validator'` | `"stake"` |
| `'vault'` | `"yield"` |

**Rationale**: Matches `EarnProviderType` enum exactly, no mapping needed.

---

## Workflow Diagrams

See [earn-architecture-diagrams.md](./earn-architecture-diagrams.md) for detailed flow diagrams:
- Diagram 1: Stake Flow
- Diagram 2: DeFi Flow (Vault)
- Diagram 3: Unified Data Model
- Diagram 4: Database Relationships
- Diagram 5: Complete System Flow
- Diagram 6: Action Types Mapping

---

## Summary

The v2 architecture:

1. **Renames types** for semantic clarity (`EarnProvider`, `EarnPosition`)
2. **Keeps `base` pattern** for efficient data flow and DB operations
3. **Unifies staking + DeFi** under single type system
4. **Handles edge cases** (FK constraints, state differences, rewards semantics)
5. **Maintains action separation** (StakeType vs EarnAction)
6. **Is extensible** for future earn types (liquid staking, restaking)

## Final Naming Summary

| Purpose | Name | Status |
|---------|------|--------|
| Provider data | `EarnProvider` | ✅ Implemented |
| Position base data | `EarnPositionBase` | ✅ Implemented |
| Position with joins | `EarnPosition` | ✅ Implemented |
| Position state | `EarnPositionState` | ✅ Implemented |
| Provider classification | `EarnProviderType { Stake, Yield }` | ✅ Implemented |
| DeFi provider enum | `YieldProvider { yo }` | ✅ Implemented |
| Stake actions | `EarnStakeType { ... }` | ⏳ Phase 2 |
| Vault actions | `EarnYieldType { ... }` | ⏳ Phase 7 |

**Naming alignment:**
- `EarnProviderType::Stake` → uses `EarnStakeType` actions (Phase 2)
- `EarnProviderType::Yield` → uses `EarnYieldType` actions (Phase 7)

## Current State

**DeFi Yield (Yo)**: Fully implemented with new unified types and normalized DB schema.

**Staking**: Uses existing `Delegation*` types and `stake_*` tables. Will migrate to unified `Earn*` types in Phase 2.

**Next Steps**:
1. Complete Phase 9 (Testing)
2. Plan Phase 2 PR (Stake Mappers unification)
