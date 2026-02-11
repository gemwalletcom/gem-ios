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
                    model: model.headerViewModel,
                    isPrivacyEnabled: .constant(false),
                    balanceActionType: .none,
                    onHeaderAction: nil,
                    onInfoAction: nil
                )
                .padding(.top, .small)
            }
            .cleanListRow()

            Section {
                if let url = model.providerUrl {
                    SafariNavigationLink(url: url) {
                        ListItemView(title: model.providerTitle, subtitle: model.providerText)
                    }
                } else {
                    ListItemView(title: model.providerTitle, subtitle: model.providerText)
                }

                if model.showApr {
                    ListItemView(title: model.aprTitle, subtitle: model.aprText)
                }

                ListItemView(title: model.stateTitle, subtitle: model.stateText, subtitleStyle: model.stateTextStyle)

                if let title = model.completionDateTitle, let subtitle = model.completionDateText {
                    ListItemView(title: title, subtitle: subtitle)
                }
            }

            if let rewardsText = model.delegationModel.rewardsText {
                Section {
                    ListItemView(
                        title: model.rewardsTitle,
                        titleStyle: model.delegationModel.titleStyle,
                        subtitle: rewardsText,
                        subtitleStyle: model.delegationModel.subtitleStyle,
                        subtitleExtra: model.delegationModel.rewardsFiatValueText,
                        subtitleStyleExtra: model.delegationModel.subtitleExtraStyle,
                        imageStyle: model.assetImageStyle
                    )
                }
            }

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
            }
        }
        .navigationTitle(model.title)
        .listSectionSpacing(.compact)
    }
}
