// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone
import Primitives

@testable import EarnService

public final class MockEarnService: EarnServiceType, @unchecked Sendable {
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
            throw EarnServiceMockError.notConfigured
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
            throw EarnServiceMockError.notConfigured
        }
        return transaction
    }

    public func fetchPosition(
        provider: GemYieldProvider,
        asset: Primitives.AssetId,
        walletAddress: String
    ) async throws -> GemYieldPosition {
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
        yields: [GemYield] = [],
        position: GemYieldPosition? = nil,
        transaction: GemYieldTransaction? = nil
    ) -> MockEarnService {
        let service = MockEarnService()
        service.mockYields = yields
        service.mockPosition = position
        service.mockTransaction = transaction
        return service
    }
}
