// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Primitives
import Localization
import Style
import PrimitivesComponents

public struct RewardsScene: View {
    enum CodeInputType: Identifiable {
        case create
        case activate(code: String)

        var id: String {
            switch self {
            case .create: "create"
            case .activate: "activate"
            }
        }
    }

    @State private var model: RewardsViewModel
    @State private var isPresentingWalletSelector = false
    @State private var isPresentingShare = false
    @State private var isPresentingCodeInput: CodeInputType?
    @State private var isPresentingRedemptionAlert: AlertMessage?
    @State private var isPresentingInfoUrl: URL?

    public init(model: RewardsViewModel) {
        _model = State(initialValue: model)
    }

    public var body: some View {
        List {
            switch model.state {
            case .loading:
                CenterLoadingView()
            case .error(let error):
                stateErrorView(error: error)
            case .data(let rewards):
                inviteFriendsSection(code: rewards.code)
                if let disableReason = model.disableReason {
                    disableReasonSection(reason: disableReason)
                }
                if model.hasPendingReferral {
                    pendingReferralSection
                }
                if model.isInfoEnabled {
                    infoSection(rewards: rewards)
                }
                if !rewards.redemptionOptions.isEmpty {
                    redemptionOptionsSection(options: rewards.redemptionOptions)
                }
            case .noData:
                inviteFriendsSection(code: nil)
            }
        }
        .refreshable { await model.fetch() }
        .contentMargins(.top, .scene.top, for: .scrollContent)
        .listStyle(.insetGrouped)
        .navigationTitle(model.title)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if model.showsWalletSelector {
                    WalletBarView(model: model.walletBarViewModel) {
                        isPresentingWalletSelector = true
                    }
                } else {
                    Button {
                        isPresentingInfoUrl = model.rewardsUrl
                    } label: {
                        Images.System.info
                    }
                }
            }
        }
        .safariSheet(url: $isPresentingInfoUrl)
        .sheet(isPresented: $isPresentingWalletSelector) {
            SelectableListNavigationStack(
                model: model.walletSelectorModel,
                onFinishSelection: { wallets in
                    if let wallet = wallets.first {
                        model.selectWallet(wallet)
                    }
                    isPresentingWalletSelector = false
                },
                listContent: { wallet in
                    SimpleListItemView(model: wallet)
                }
            )
        }
        .sheet(isPresented: $isPresentingShare) {
            if let shareText = model.shareText {
                ShareSheet(activityItems: [shareText])
            }
        }
        .sheet(item: $isPresentingCodeInput) { type in
            switch type {
            case .create:
                TextInputScene(model: model.createCodeViewModel) {
                    isPresentingCodeInput = nil
                }
                .presentationDetents([.medium])
            case .activate(let code):
                TextInputScene(model: model.redeemCodeViewModel(code: code)) {
                    isPresentingCodeInput = nil
                }
                .presentationDetents([.medium])
            }
        }
        .alert(
            model.errorTitle,
            isPresented: Binding(
                get: { model.isPresentingError != nil },
                set: { if !$0 { model.isPresentingError = nil } }
            )
        ) {
            Button(Localized.Common.done, role: .cancel) {}
        } message: {
            if let error = model.isPresentingError {
                Text(error)
            }
        }
        .taskOnce {
            Task {
                await model.fetch()
                
                if model.shouldAutoActivate {
                    await model.useReferralCode()
                } else if model.giftCodeFromLink != nil {
                    do {
                        let option = try await model.getRewardRedemptionOption()
                        showRedemptionAlert(for: option)
                    } catch {
                        model.isPresentingError = error.localizedDescription
                    }
                } else if let code = model.activateCodeFromLink {
                    isPresentingCodeInput = .activate(code: code)
                }
            }
        }
        .toast(message: $model.toastMessage)
        .alertSheet($isPresentingRedemptionAlert)
    }

    @ViewBuilder
    private func stateErrorView(error: Error) -> some View {
        Section {
            StateEmptyView(
                title: model.errorTitle,
                description: error.localizedDescription,
                image: nil
            ) {
                Button(Localized.Common.tryAgain) {
                    Task { await model.fetch() }
                }
                .buttonStyle(.blue())
            }
        }
    }

    @ViewBuilder
    private func inviteFriendsSection(code: String?) -> some View {
        Section {
            VStack(spacing: Spacing.large) {
                Text("🎁")
                    .font(.system(size: 72))
                    .padding(.top, Spacing.medium)

                VStack(spacing: Spacing.small) {
                    Text(model.createCodeTitle)
                        .font(.title2.bold())
                        .multilineTextAlignment(.center)

                    Text(model.createCodeDescription)
                        .textStyle(.calloutSecondary)
                        .multilineTextAlignment(.center)
                }

                HStack(spacing: Spacing.medium) {
                    featureItem(emoji: "👥", text: Localized.Rewards.InviteFriends.title)
                    featureItem(emoji: "💎", text: Localized.Rewards.EarnPoints.title)
                    featureItem(emoji: "🎉", text: Localized.Rewards.GetRewards.title)
                }

                Button {
                    if code != nil {
                        isPresentingShare = true
                    } else {
                        isPresentingCodeInput = .create
                    }
                } label: {
                    HStack(spacing: Spacing.small) {
                        if code != nil {
                            Images.System.share
                        }
                        Text(code != nil ? Localized.Rewards.InviteFriends.title : model.createCodeButtonTitle)
                    }
                }
                .buttonStyle(.blue())
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.small)
        }

        if model.canUseReferralCode {
            Section {
                Button {
                    isPresentingCodeInput = .activate(code: "")
                } label: {
                    Text(model.activateCodeFooterTitle)
                        .frame(maxWidth: .infinity)
                }
            } footer: {
                Text(model.activateCodeFooterDescription)
            }
        }
    }

    @ViewBuilder
    private func featureItem(emoji: String, text: String) -> some View {
        VStack(spacing: Spacing.extraSmall) {
            Text(emoji)
                .font(.title2)
            Text(text)
                .font(.caption)
                .foregroundStyle(Colors.secondaryText)
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private func redemptionOptionsSection(options: [RewardRedemptionOption]) -> some View {
        Section {
            ForEach(options.map { RewardRedemptionOptionViewModel(option: $0) }) { viewModel in
                NavigationCustomLink(
                    with: ListItemView(
                        title: viewModel.title,
                        subtitle: viewModel.subtitle,
                        imageStyle: .asset(assetImage: viewModel.assetImage)
                    )
                ) {
                    if model.canRedeem(option: viewModel.option) {
                        showRedemptionAlert(for: viewModel.option)
                    } else {
                        model.isPresentingError = Localized.Rewards.insufficientPoints
                    }
                }
            }
        } header: {
            Text(Localized.Rewards.WaysSpend.title)
        }
    }

    private func showRedemptionAlert(for option: RewardRedemptionOption) {
        let viewModel = RewardRedemptionOptionViewModel(option: option)
        isPresentingRedemptionAlert = AlertMessage(
            title: viewModel.confirmationMessage,
            message: "",
            actions: [
                AlertAction(title: Localized.Transfer.confirm, isDefaultAction: true) {
                    Task { await model.redeem(option: option) }
                },
                .cancel(title: Localized.Common.cancel)
            ]
        )
    }

    @ViewBuilder
    private func infoSection(rewards: Rewards) -> some View {
        Section {
            if let code = rewards.code {
                ListItemView(
                    title: model.myReferralCodeTitle,
                    subtitle: code
                )
                .contextMenu(model.referralLink.map { [.copy(value: $0)] } ?? [])
            }
            ListItemView(
                title: model.referralCountTitle,
                subtitle: "\(rewards.referralCount)"
            )
            ListItemView(
                title: model.pointsTitle,
                subtitle: "\(rewards.points) 💎"
            )
            if let invitedBy = rewards.usedReferralCode {
                ListItemView(
                    title: model.invitedByTitle,
                    subtitle: invitedBy
                )
            }
        } header: {
            Text(model.statsSectionTitle)
        }
    }

    @ViewBuilder
    private func disableReasonSection(reason: String) -> some View {
        Section {
            ListItemErrorView(
                errorTitle: model.errorTitle,
                error: AnyError(reason)
            )
        }
    }

    @ViewBuilder
    private var pendingReferralSection: some View {
        Section {
            ListItemInfoView(
                title: model.pendingReferralTitle,
                description: model.pendingReferralDescription
            )

            HStack {
                Spacer()
                StateButton(
                    text: model.pendingReferralButtonTitle,
                    type: model.activatePendingButtonType
                ) {
                    Task { await model.activatePendingReferral() }
                }
                .frame(height: .scene.button.height)
                .frame(maxWidth: .scene.button.maxWidth)
                Spacer()
            }
        }
    }
}
