// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import PrimitivesComponents

public struct DelegationDetailScene: View {
    private let model: DelegationDetailSceneViewModel

    public init(model: DelegationDetailSceneViewModel) {
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
            }

            if model.showManage {
                Section(model.manageTitle) {
                    ForEach(model.availableActions) { action in
                        NavigationCustomLink(with: ListItemView(title: model.actionTitle(action))) {
                            model.performAction(action)
                        }
                    }
                }
            }
        }
        .navigationTitle(model.title)
        .listSectionSpacing(.compact)
    }
}
