// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone
import NativeProviderService
import Primitives
import Store

public final class YieldService: Sendable {
    public let yielder: GemYielder
    private let store: YieldStore?

    public init(yielder: GemYielder, store: YieldStore? = nil) {
        self.yielder = yielder
        self.store = store
    }

    public convenience init(nodeProvider: any NodeURLFetchable, store: YieldStore? = nil) throws {
        let nativeProvider = NativeProvider(nodeProvider: nodeProvider)
        let yielder = try GemYielder(rpcProvider: nativeProvider)
        self.init(yielder: yielder, store: store)
    }

    public func getYields(for assetId: Primitives.AssetId) async throws -> [GemYield] {
        try await yielder.yieldsForAsset(assetId: assetId.identifier)
    }

    public func deposit(
        provider: GemYieldProvider,
        asset: Primitives.AssetId,
        walletAddress: String,
        value: String
    ) async throws -> GemYieldTransaction {
        try await yielder.deposit(
            provider: provider.name,
            asset: asset.identifier,
            walletAddress: walletAddress,
            value: value
        )
    }

    public func withdraw(
        provider: GemYieldProvider,
        asset: Primitives.AssetId,
        walletAddress: String,
        value: String
    ) async throws -> GemYieldTransaction {
        try await yielder.withdraw(
            provider: provider.name,
            asset: asset.identifier,
            walletAddress: walletAddress,
            value: value
        )
    }

    @discardableResult
    public func getPosition(
        provider: GemYieldProvider,
        asset: Primitives.AssetId,
        walletAddress: String,
        walletId: WalletId,
        onUpdate: (@MainActor @Sendable (GemYieldPosition) -> Void)? = nil
    ) -> GemYieldPosition? {
        let cached = getCachedPosition(walletId: walletId, assetId: asset)

        Task {
            do {
                let fresh = try await yielder.positions(
                    provider: provider.name,
                    asset: asset.identifier,
                    walletAddress: walletAddress
                )
                savePosition(fresh, walletId: walletId)
                if let onUpdate {
                    await onUpdate(fresh)
                }
            } catch {
                debugLog("getPosition error: \(error)")
            }
        }

        return cached
    }

    public func clearPosition(walletId: WalletId, assetId: Primitives.AssetId) {
        guard let store else { return }
        do {
            try store.deletePosition(walletId: walletId, assetId: assetId)
        } catch {
            debugLog("clearPosition error: \(error)")
        }
    }

    private func getCachedPosition(walletId: WalletId, assetId: Primitives.AssetId) -> GemYieldPosition? {
        guard let store else { return nil }
        do {
            guard let record = try store.getPosition(walletId: walletId, assetId: assetId) else {
                return nil
            }
            return record.toGemYieldPosition()
        } catch {
            debugLog("getCachedPosition error: \(error)")
            return nil
        }
    }

    private func savePosition(_ position: GemYieldPosition, walletId: WalletId) {
        guard let store,
              let record = YieldPositionRecord(walletId: walletId, position: position) else { return }
        do {
            try store.updatePosition(record)
        } catch {
            debugLog("savePosition error: \(error)")
        }
    }
}

public extension GemYieldProvider {
    var name: String {
        switch self {
        case .yo:
            return "yo"
        }
    }
}
