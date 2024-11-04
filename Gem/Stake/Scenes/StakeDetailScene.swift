// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Staking

struct StakeDetailScene: View {
    
    @Environment(\.keystore) private var keystore
    @Environment(\.walletsService) private var walletsService
    @Environment(\.stakeService) private var stakeService

    let model: StakeDetailViewModel

    var body: some View {
        List {
            Section {
                if let url = model.validatorUrl {
                    NavigationOpenLink(url: url, with: ListItemView(title: model.validatorTitle, subtitle: model.validatorText))
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
                ListItemView(title: model.title, subtitle: model.model.balanceText)
                if let rewardsText = model.model.rewardsText {
                    ListItemView(title: model.rewardsTitle, subtitle: rewardsText)
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
                            if let value = try? model.withdrawStakeRecipientData() {
                                model.onAmountInputAction?(value)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle(model.title)
    }
}

//#Preview {
//    StakeDetailScene()
//}
