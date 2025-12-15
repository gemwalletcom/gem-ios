// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import RewardsService
import PrimitivesComponents
import Localization

@Observable
@MainActor
public final class RedeemRewardsCodeViewModel: TextInputViewModelProtocol {
    private let rewardsService: RewardsServiceable
    private let wallet: Wallet
    private let onSuccess: (String) -> Void

    public var text: String
    public var isLoading: Bool = false
    public var errorMessage: String?

    public init(
        rewardsService: RewardsServiceable,
        wallet: Wallet,
        code: String = "",
        onSuccess: @escaping (String) -> Void
    ) {
        self.rewardsService = rewardsService
        self.wallet = wallet
        self.text = code
        self.onSuccess = onSuccess
    }

    public var title: String { Localized.Rewards.referralCode }
    public var placeholder: String { Localized.Rewards.referralCode }
    public var isActionDisabled: Bool { text.isEmpty }

    public func action() async {
        guard !text.isEmpty else { return }

        isLoading = true
        do {
            try await rewardsService.useReferralCode(wallet: wallet, referralCode: text)
            onSuccess(text)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
