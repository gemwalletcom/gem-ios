// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import RewardsService
import PrimitivesComponents
import Components
import Preferences
import Localization

@Observable
@MainActor
public final class RewardsViewModel: Sendable {
    private let rewardsService: RewardsServiceable
    private let activateCode: String?

    private(set) var selectedWallet: Wallet
    private(set) var wallets: [Wallet]

    var state: StateViewType<Rewards> = .loading
    var toastMessage: ToastMessage?
    var isPresentingError: String?

    public init(
        rewardsService: RewardsServiceable,
        wallet: Wallet,
        wallets: [Wallet],
        activateCode: String? = nil
    ) {
        self.rewardsService = rewardsService
        self.selectedWallet = wallet
        self.wallets = wallets
        self.activateCode = activateCode
    }

    // MARK: - UI Properties

    var title: String { Localized.Rewards.title }
    var referralCountTitle: String { Localized.Rewards.referrals }
    var pointsTitle: String { Localized.Rewards.points }
    var errorTitle: String { Localized.Errors.errorOccured }
    var invitedByTitle: String { Localized.Rewards.invitedBy }
    var createCodeButtonTitle: String { Localized.Common.getStarted }
    var myReferralCodeTitle: String { Localized.Rewards.myReferralCode }
    var createCodeTitle: String { Localized.Rewards.InviteFriends.title }
    var createCodeDescription: AttributedString {
        try! AttributedString(markdown: Localized.Rewards.InviteFriends.description(100))
    }
    var activateCodeFooterTitle: String { Localized.Rewards.ActivateReferralCode.title }
    var activateCodeFooterDescription: String { Localized.Rewards.ActivateReferralCode.description }
    var statsSectionTitle: String { Localized.Common.info }

    var showsWalletSelector: Bool {
        wallets.count > 1
    }

    var walletSelectorModel: SelectWalletViewModel {
        SelectWalletViewModel(wallets: wallets, selectedWallet: selectedWallet)
    }

    var rewards: Rewards? {
        if case .data(let rewards) = state {
            return rewards
        }
        return nil
    }

    var shareText: String? {
        guard let code = rewards?.code else { return nil }
        let link = rewardsService.generateReferralLink(code: code).absoluteString
        return Localized.Rewards.shareText(link)
    }

    var hasReferralCode: Bool {
        guard let code = rewards?.code else { return false }
        return !code.isEmpty
    }

    var hasUsedReferralCode: Bool {
        if let usedCode = rewards?.usedReferralCode, !usedCode.isEmpty {
            return true
        }
        return false
    }

    var canUseReferralCode: Bool {
        !hasReferralCode && !hasUsedReferralCode
    }

    var isInfoEnabled: Bool {
        hasReferralCode || hasUsedReferralCode
    }

    var walletBarViewModel: WalletBarViewViewModel {
        let walletVM = WalletViewModel(wallet: selectedWallet)
        return WalletBarViewViewModel(name: walletVM.name, image: walletVM.avatarImage)
    }

    var createCodeViewModel: CreateRewardsCodeViewModel {
        CreateRewardsCodeViewModel(
            rewardsService: rewardsService,
            wallet: selectedWallet
        ) { [weak self] rewards in
            self?.state = .data(rewards)
        }
    }

    func redeemCodeViewModel(code: String) -> RedeemRewardsCodeViewModel {
        RedeemRewardsCodeViewModel(
            rewardsService: rewardsService,
            wallet: selectedWallet,
            code: code
        ) { [weak self] _ in
            guard let self else { return }
            self.showActivatedToast()
            Task { await self.fetch() }
        }
    }

    // MARK: - Actions

    func selectWallet(_ wallet: Wallet) {
        selectedWallet = wallet
        Task { await fetch(wallet: wallet) }
    }

    func fetch() async {
        await fetch(wallet: selectedWallet)
    }

    var activateCodeFromLink: String? {
        guard let activateCode, canUseReferralCode else { return nil }
        return activateCode
    }

    private func showActivatedToast() {
        toastMessage = ToastMessage.success(Localized.Common.done)
    }

    private func fetch(wallet: Wallet) async {
        state = .loading
        do {
            let rewards = try await rewardsService.getRewards(wallet: wallet)
            state = .data(rewards)
        } catch {
            state = .noData
        }
    }
}
