// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import RewardsService
import PrimitivesComponents
import Components
import Preferences
import Localization
import Style

@Observable
@MainActor
public final class RewardsViewModel: Sendable {
    private static let dateFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.day, .hour, .minute]
        formatter.zeroFormattingBehavior = .dropLeading
        formatter.unitsStyle = .full
        return formatter
    }()

    private let rewardsService: RewardsServiceable
    private let activateCode: String?
    private let giftCode: String?

    private(set) var selectedWallet: Wallet
    private(set) var wallets: [Wallet]

    var state: StateViewType<Rewards> = .loading
    var toastMessage: ToastMessage?
    var isPresentingError: String?

    public init(
        rewardsService: RewardsServiceable,
        wallet: Wallet,
        wallets: [Wallet],
        activateCode: String? = nil,
        giftCode: String? = nil
    ) {
        self.rewardsService = rewardsService
        self.selectedWallet = wallet
        self.wallets = wallets
        self.activateCode = activateCode
        self.giftCode = giftCode
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
        try! AttributedString(markdown: Localized.Rewards.InviteFriends.description(100.description.boldMarkdown()))
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

    var referralLink: String? {
        guard let code = rewards?.code else { return nil }
        return rewardsService.generateReferralLink(code: code).absoluteString
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

    var disableReason: String? {
        rewards?.disableReason
    }

    var pendingVerificationAfter: Date? {
        rewards?.pendingVerificationAfter
    }

    var hasPendingReferral: Bool {
        pendingVerificationAfter != nil
    }

    var canActivatePendingReferral: Bool {
        guard let pendingDate = pendingVerificationAfter else { return false }
        return Date() >= pendingDate
    }

    var pendingReferralTitle: String {
        Localized.Rewards.Pending.title
    }

    var pendingReferralDescription: String? {
        guard let pendingDate = pendingVerificationAfter else { return nil }
        if canActivatePendingReferral {
            return Localized.Rewards.Pending.descriptionReady
        }
        guard let timeString = Self.dateFormatter.string(from: .now, to: pendingDate) else { return nil }
        return Localized.Rewards.Pending.description(timeString)
    }

    var pendingReferralButtonTitle: String {
        Localized.Transfer.confirm
    }

    var activatePendingButtonType: ButtonType {
        canActivatePendingReferral ? .primary() : .primary(.disabled)
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
        activateCode
    }

    var giftCodeFromLink: String? {
        giftCode
    }

    var shouldAutoActivate: Bool {
        wallets.count == 1 && activateCode != nil
    }

    func useReferralCode() async {
        guard let code = activateCode else { return }
        do {
            try await rewardsService.useReferralCode(wallet: selectedWallet, referralCode: code)
            showActivatedToast()
            await fetch()
        } catch {
            isPresentingError = error.localizedDescription
        }
    }

    func activatePendingReferral() async {
        guard let code = rewards?.usedReferralCode else { return }
        do {
            try await rewardsService.useReferralCode(wallet: selectedWallet, referralCode: code)
            showActivatedToast()
            await fetch()
        } catch {
            isPresentingError = error.localizedDescription
        }
    }

    func getRewardRedemptionOption() async throws -> RewardRedemptionOption {
        guard let code = giftCode else {
            throw AnyError("no gift code")
        }
        return try await rewardsService.getRedemptionOption(code: code)
    }

    func canRedeem(option: RewardRedemptionOption) -> Bool {
        guard let rewards else { return false }
        return rewards.points >= option.points
    }

    func redeem(option: RewardRedemptionOption) async {
        do {
            _ = try await rewardsService.redeem(wallet: selectedWallet, redemptionId: option.id)
            toastMessage = ToastMessage.success(Localized.Common.done)
            await fetch()
        } catch {
            isPresentingError = error.localizedDescription
        }
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
