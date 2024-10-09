// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components

struct StakeDetailScene: View {
    
    @Environment(\.keystore) private var keystore
    @Environment(\.walletsService) private var walletsService
    @Environment(\.stakeService) private var stakeService

    let model: StakeDetailViewModel

    var body: some View {
        List {
            Section {
                ListItemView(title: Localized.Stake.validator, subtitle: model.validatorText)
                ListItemView(title: Localized.Stake.apr(""), subtitle: model.validatorAprText)
                ListItemView(title: Localized.Transaction.status, subtitle: model.stateText, subtitleStyle: model.stateTextStyle)
                
                if let title = model.completionDateTitle, let subtitle = model.completionDateText {
                    ListItemView(title: title, subtitle: subtitle)
                }
            }
            Section(Localized.Asset.balances) {
                ListItemView(title: Localized.Transfer.Stake.title, subtitle: model.model.balanceText)
                if let rewardsText = model.model.rewardsText {
                    ListItemView(title: Localized.Stake.rewards, subtitle: rewardsText)
                }
            }
            //TODO: Remove NavigationCustomLink usage in favor of NavigationLink()
            if model.showManage {
                Section(Localized.Common.manage) {
                    if model.isStakeAvailable {
                        NavigationCustomLink(with: ListItemView(title: Localized.Transfer.Stake.title)) {
                            if let value = try? model.stakeRecipientData() {
                                model.onAmountInputAction?(value)
                            }
                        }
                    }
                    if model.isUnstakeAvailable {
                        NavigationCustomLink(with: ListItemView(title: Localized.Transfer.Unstake.title)) {
                            if let value = try? model.unstakeRecipientData() {
                                model.onAmountInputAction?(value)
                            }
                        }
                    }
                    if model.isRedelegateAvailable {
                        NavigationCustomLink(with: ListItemView(title: Localized.Transfer.Redelegate.title)) {
                            if let value = try? model.redelegateRecipientData() {
                                model.onAmountInputAction?(value)
                            }
                        }
                    }
                    if model.isWithdrawStakeAvailable {
                        NavigationCustomLink(with: ListItemView(title: Localized.Transfer.Withdraw.title)) {
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
