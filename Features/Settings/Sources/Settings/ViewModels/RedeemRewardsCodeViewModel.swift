// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import RewardsService
import PrimitivesComponents
import Localization

@Observable
@MainActor
final class RedeemRewardsCodeViewModel: TextInputViewModelProtocol {
    private let rewardsService: RewardsServiceable
    private let wallet: Wallet
    private let onSuccess: (String) -> Void

    var text: String
    var isLoading: Bool = false
    var errorMessage: String?

    init(
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

    var title: String { Localized.Rewards.referralCode }
    var placeholder: String { Localized.Rewards.referralCode }
    var isActionDisabled: Bool { text.isEmpty }

    func action() async {
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
