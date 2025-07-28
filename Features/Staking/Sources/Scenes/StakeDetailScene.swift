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
                        ListItemView(title: model.validatorTitle, subtitle: model.validatorText)
                    }
                } else {
                    ListItemView(title: model.validatorTitle, subtitle: model.validatorText)
                }

                if model.showValidatorApr {
                    ListItemView(title: model.aprTitle, subtitle: model.validatorAprText)
                }

                ListItemView(title: model.stateTitle, subtitle: model.stateText, subtitleStyle: model.stateTextStyle)

                if let title = model.completionDateTitle, let subtitle = model.completionDateText {
                    ListItemView(title: title, subtitle: subtitle)
                }
            }
            Section(model.balancesTitle) {
                HStack {
                    ValidatorImageView(validator: model.validator)
                    ListItemView(
                        title: model.title,
                        subtitle: model.model.balanceText,
                        subtitleExtra: model.model.balanceFiatValueText
                    )
                }
                if let rewardsText = model.model.rewardsText {
                    ListItemView(
                        title: model.rewardsTitle,
                        subtitle: rewardsText,
                        subtitleExtra: model.model.rewardsFiatValueText,
                        imageStyle: model.assetImageStyle
                    )
                }
            }
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
            }
        }
        .navigationTitle(model.title)
    }
}
