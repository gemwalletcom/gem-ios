// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components

struct StakeDetailScene: View {
    
    @Environment(\.keystore) private var keystore
    @Environment(\.walletsService) private var walletsService
    @Environment(\.stakeService) private var stakeService

    let model: StakeDetailViewModel

    @State var amountInput: AmountInput?

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
            if model.showManage {
                Section(Localized.Common.manage) {
                    if model.isStakeAvailable {
                        NavigationCustomLink(with: ListItemView(title: Localized.Transfer.Stake.title)) {
                            self.amountInput = try? model.stakeRecipientData()
                        }
                    }
                    if model.isUnstakeAvailable {
                        NavigationCustomLink(with: ListItemView(title: Localized.Transfer.Unstake.title)) {
                            self.amountInput = try? model.unstakeRecipientData()
                        }
                    }
                    if model.isRedelegateAvailable {
                        NavigationCustomLink(with: ListItemView(title: Localized.Transfer.Redelegate.title)) {
                            self.amountInput = try? model.redelegateRecipientData()
                        }
                    }
                    if model.isWithdrawStakeAvailable {
                        NavigationCustomLink(with: ListItemView(title: Localized.Transfer.Withdraw.title)) {
                            self.amountInput = try? model.withdrawStakeRecipientData()
                        }
                    }
                }
            }
        }
        .listSectionSpacing(.compact)
        .navigationTitle(model.title)
        .navigationDestination(for: $amountInput) {
            AmountScene(
                model: AmounViewModel(
                    input: $0,
                    wallet: model.wallet,
                    keystore: keystore,
                    walletsService: walletsService,
                    stakeService: stakeService
                )
            )
        }
    }
}

//#Preview {
//    StakeDetailScene()
//}
