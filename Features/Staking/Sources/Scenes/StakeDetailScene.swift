// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import PrimitivesComponents

public struct StakeDetailScene: View {
    private let model: StakeDetailSceneViewModel

    public init(model: StakeDetailSceneViewModel) {
        self.model = model
    }

    public var body: some View {
        List {
            Section { } header: {
                WalletHeaderView(
                    model: model.validatorHeaderViewModel,
                    isHideBalanceEnalbed: .constant(false),
                    onHeaderAction: nil,
                    onInfoAction: nil
                )
                .padding(.top, .small)
            }
            .cleanListRow()

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
            .listRowInsets(.assetListRowInsets)

            if let rewardsText = model.model.rewardsText {
                Section {
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
                .listRowInsets(.assetListRowInsets)
            }

            //TODO: Remove NavigationCustomLink usage in favor of NavigationLink()
            if model.showManage {
                Section(model.manageTitle) {
                    if model.isStakeAvailable {
                        NavigationCustomLink(with: ListItemView(title: model.title)) {
                            model.onStakeAmountAction()
                        }
                    }
                    if model.isUnstakeAvailable {
                        NavigationCustomLink(with: ListItemView(title: model.unstakeTitle)) {
                            model.onUnstakeAction()
                        }
                    }
                    if model.isRedelegateAvailable {
                        NavigationCustomLink(with: ListItemView(title: model.redelegateTitle)) {
                            model.onRedelegateAction()
                        }
                    }
                    if model.isWithdrawStakeAvailable {
                        NavigationCustomLink(with: ListItemView(title: model.withdrawTitle)) {
                            model.onWithdrawAction()
                        }
                    }
                }
                .listRowInsets(.assetListRowInsets)
            }
        }
        .navigationTitle(model.title)
        .listSectionSpacing(.compact)
    }
}
