// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone
import Primitives

@testable import EarnService

public final class MockEarnService: EarnServiceable, @unchecked Sendable {
    public var mockProviders: [EarnProvider] = []
    public var mockPosition: EarnPosition?
    public var mockTransaction: GemYieldTransaction?

    public init() {}

    public func getProviders(for assetId: Primitives.AssetId) async throws -> [EarnProvider] {
        mockProviders
    }

    public func deposit(
        provider: YieldProvider,
        asset: Primitives.AssetId,
        walletAddress: String,
        value: String
    ) async throws -> GemYieldTransaction {
        guard let transaction = mockTransaction else {
            throw EarnServiceMockError.notConfigured
        }
        return transaction
    }

    public func withdraw(
        provider: YieldProvider,
        asset: Primitives.AssetId,
        walletAddress: String,
        value: String
    ) async throws -> GemYieldTransaction {
        guard let transaction = mockTransaction else {
            throw EarnServiceMockError.notConfigured
        }
        return transaction
    }

    public func fetchPosition(
        provider: YieldProvider,
        asset: Primitives.AssetId,
        walletAddress: String
    ) async throws -> EarnPosition {
        guard let position = mockPosition else {
            throw EarnServiceMockError.notConfigured
        }
        return position
    }
}

enum EarnServiceMockError: Error {
    case notConfigured
}

extension MockEarnService {
    public static func mock(
        providers: [EarnProvider] = [],
        position: EarnPosition? = nil,
        transaction: GemYieldTransaction? = nil
    ) -> MockEarnService {
        let service = MockEarnService()
        service.mockProviders = providers
        service.mockPosition = position
        service.mockTransaction = transaction
        return service
    }
}
