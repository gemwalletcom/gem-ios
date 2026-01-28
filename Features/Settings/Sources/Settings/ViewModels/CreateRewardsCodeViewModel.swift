// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import RewardsService
import PrimitivesComponents
import Localization

@Observable
@MainActor
final class CreateRewardsCodeViewModel: TextInputViewModelProtocol {
    private let rewardsService: RewardsServiceable
    private let wallet: Wallet
    private let onSuccess: (Rewards) -> Void

    var text: String = ""
    var isLoading: Bool = false
    var errorMessage: String?

    init(
        rewardsService: RewardsServiceable,
        wallet: Wallet,
        onSuccess: @escaping (Rewards) -> Void
    ) {
        self.rewardsService = rewardsService
        self.wallet = wallet
        self.onSuccess = onSuccess
    }

    var title: String { Localized.Rewards.nickname }
    var placeholder: String { Localized.Rewards.username }
    var footer: String? { Localized.Rewards.CreateReferralCode.info }
    var isActionDisabled: Bool { text.isEmpty }

    func action() async {
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
