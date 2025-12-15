// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import RewardsService

public struct RewardsServiceMock: RewardsServiceable, Sendable {
    public var rewardsResult: Result<Rewards, Error>
    public var createReferralResult: Result<Rewards, Error>
    public var useCodeError: Error?

    public init(
        rewardsResult: Result<Rewards, Error> = .success(.mock()),
        createReferralResult: Result<Rewards, Error> = .success(.mock()),
        useCodeError: Error? = nil
    ) {
        self.rewardsResult = rewardsResult
        self.createReferralResult = createReferralResult
        self.useCodeError = useCodeError
    }

    public func getRewards(wallet: Wallet) async throws -> Rewards {
        try rewardsResult.get()
    }

    public func createReferral(wallet: Wallet, code: String) async throws -> Rewards {
        try createReferralResult.get()
    }

    public func useReferralCode(wallet: Wallet, referralCode: String) async throws {
        if let error = useCodeError {
            throw error
        }
    }

    public func generateReferralLink(code: String) -> URL {
        URL(string: "\(Constants.App.website)/join?code=\(code)")!
    }
}

public extension RewardsService {
    static func mock() -> RewardsServiceMock {
        RewardsServiceMock()
    }
}
