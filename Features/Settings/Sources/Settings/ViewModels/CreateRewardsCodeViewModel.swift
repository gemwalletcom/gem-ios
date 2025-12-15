// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import RewardsService
import PrimitivesComponents
import Localization

@Observable
@MainActor
public final class CreateRewardsCodeViewModel: TextInputViewModelProtocol {
    private let rewardsService: RewardsServiceable
    private let wallet: Wallet
    private let onSuccess: (Rewards) -> Void

    public var text: String = ""
    public var isLoading: Bool = false
    public var errorMessage: String?

    public init(
        rewardsService: RewardsServiceable,
        wallet: Wallet,
        onSuccess: @escaping (Rewards) -> Void
    ) {
        self.rewardsService = rewardsService
        self.wallet = wallet
        self.onSuccess = onSuccess
    }

    public var title: String { Localized.Rewards.CreateReferralCode.title }
    public var placeholder: String { Localized.Rewards.username }
    public var footer: String? { Localized.Rewards.CreateReferralCode.info }
    public var isActionDisabled: Bool { text.isEmpty }

    public func action() async {
        isLoading = true
        let code = text

        do {
            let rewards = try await rewardsService.createReferral(wallet: wallet, code: code)
            onSuccess(rewards)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
