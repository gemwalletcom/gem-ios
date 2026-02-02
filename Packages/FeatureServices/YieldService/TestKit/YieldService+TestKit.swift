// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone
import Primitives

@testable import YieldService

public final class MockYieldService: YieldServiceType, @unchecked Sendable {
    public var mockYields: [GemYield] = []
    public var mockPosition: GemYieldPosition?
    public var mockTransaction: GemYieldTransaction?

    public init() {}

    public func getYields(for assetId: Primitives.AssetId) async throws -> [GemYield] {
        mockYields
    }

    public func deposit(
        provider: GemYieldProvider,
        asset: Primitives.AssetId,
        walletAddress: String,
        value: String
    ) async throws -> GemYieldTransaction {
        guard let transaction = mockTransaction else {
            throw YieldServiceMockError.notConfigured
        }
        return transaction
    }

    public func withdraw(
        provider: GemYieldProvider,
        asset: Primitives.AssetId,
        walletAddress: String,
        value: String
    ) async throws -> GemYieldTransaction {
        guard let transaction = mockTransaction else {
            throw YieldServiceMockError.notConfigured
        }
        return transaction
    }

    public func fetchPosition(
        provider: GemYieldProvider,
        asset: Primitives.AssetId,
        walletAddress: String
    ) async throws -> GemYieldPosition {
        guard let position = mockPosition else {
            throw YieldServiceMockError.notConfigured
        }
        return position
    }

    @discardableResult
    public func getPosition(
        provider: GemYieldProvider,
        asset: Primitives.AssetId,
        walletAddress: String,
        walletId: WalletId,
        onUpdate: (@MainActor @Sendable (GemYieldPosition) -> Void)?
    ) -> GemYieldPosition? {
        mockPosition
    }

    public func clearPosition(provider: GemYieldProvider, walletId: WalletId, assetId: Primitives.AssetId) {}

    public func clear() throws {}
}

enum YieldServiceMockError: Error {
    case notConfigured
}

extension MockYieldService {
    public static func mock(
        yields: [GemYield] = [],
        position: GemYieldPosition? = nil,
        transaction: GemYieldTransaction? = nil
    ) -> MockYieldService {
        let service = MockYieldService()
        service.mockYields = yields
        service.mockPosition = position
        service.mockTransaction = transaction
        return service
    }
}
