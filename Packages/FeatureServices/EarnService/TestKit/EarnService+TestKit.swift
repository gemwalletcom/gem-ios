// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone
import Primitives

@testable import EarnService

public final class MockEarnService: EarnServiceType, @unchecked Sendable {
    public var mockProtocols: [EarnProtocol] = []
    public var mockPosition: EarnPosition?
    public var mockTransaction: GemYieldTransaction?

    public init() {}

    public func getProtocols(for assetId: Primitives.AssetId) async throws -> [EarnProtocol] {
        mockProtocols
    }

    public func deposit(
        provider: EarnProvider,
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
        provider: EarnProvider,
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
        provider: EarnProvider,
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
        protocols: [EarnProtocol] = [],
        position: EarnPosition? = nil,
        transaction: GemYieldTransaction? = nil
    ) -> MockEarnService {
        let service = MockEarnService()
        service.mockProtocols = protocols
        service.mockPosition = position
        service.mockTransaction = transaction
        return service
    }
}
