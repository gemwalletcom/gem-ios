// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components

public struct StakeDetailScene: View {
    private let model: StakeDetailViewModel

    public init(model: StakeDetailViewModel) {
        self.model = model
    }

    public var body: some View {
        List {
            Section {
                if let url = model.validatorUrl {
                    SafariNavigationLink(url: url) {
                        validatorView
                    }
                } else {
                    validatorView
                }
            }
            .listRowInsets(.assetListRowInsets)

            Section {
                if let rewardsText = model.model.rewardsText {
                    ListItemView(
                        title: model.rewardsTitle,
                        titleStyle: model.model.titleStyle,
                        subtitle: rewardsText,
                        subtitleStyle: model.model.subtitleStyle,
                        subtitleExtra: model.model.rewardsFiatValueText,
                        subtitleStyleExtra: model.model.subtitleExtraStyle,
                        imageStyle: model.assetImageStyle
                    )
                }
            }
            .listRowInsets(.assetListRowInsets)

            //TODO: Remove NavigationCustomLink usage in favor of NavigationLink()
            if model.showManage {
                Section(model.manageTitle) {
                    if model.isStakeAvailable {
                        NavigationCustomLink(with: ListItemView(title: model.title)) {
                            if let value = try? model.stakeRecipientData() {
                                model.onAmountInputAction?(value)
                            }
                        }
                    }
                    if model.isUnstakeAvailable {
                        NavigationCustomLink(with: ListItemView(title: model.unstakeTitle)) {
                            if let value = try? model.unstakeRecipientData() {
                                model.onAmountInputAction?(value)
                            }
                        }
                    }
                    if model.isRedelegateAvailable {
                        NavigationCustomLink(with: ListItemView(title: model.redelegateTitle)) {
                            if let value = try? model.redelegateRecipientData() {
                                model.onAmountInputAction?(value)
                            }
                        }
                    }
                    if model.isWithdrawStakeAvailable {
                        NavigationCustomLink(with: ListItemView(title: model.withdrawTitle)) {
                            if let value = try? model.withdrawStakeTransferData() {
                                model.onTransferAction?(value)
                            }
                        }
                    }
                }
                .listRowInsets(.assetListRowInsets)
            }
        }
        .navigationTitle(model.title)
    }
    
    private var validatorView: some View {
        ValidatorDelegationView(delegation: model.model)
    }
}
