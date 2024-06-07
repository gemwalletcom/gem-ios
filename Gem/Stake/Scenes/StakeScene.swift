// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import GRDB
import GRDBQuery
import Store
import Primitives
import Components
import Style

struct StakeScene: View {
    
    @Environment(\.db) private var DB
    @Environment(\.keystore) private var keystore
    @Environment(\.nodeService) private var nodeService
    @Environment(\.walletService) private var walletService
    @Environment(\.stakeService) private var stakeService

    @Query<StakeDelegationsRequest>
    var delegations: [Delegation]
    
    var delegationsModel: [StakeDelegationViewModel] {
        delegations.map { StakeDelegationViewModel(delegation: $0) }
    }
    
    let model: StakeViewModel
    
    @State var transferData: TransferData?
    @State var recipientData: AmountRecipientData?

    init(
        model: StakeViewModel
    ) {
        self.model = model
        _delegations = Query(model.request, in: \.db.dbQueue)
    }
    
    var body: some View {
        List {
            Section {
                NavigationCustomLink(with: ListItemView(title: Localized.Transfer.Stake.title)) {
                    self.recipientData = try? model.stakeRecipientData()
                }
                if model.showClaimRewards(delegations: delegations) {
                    NavigationCustomLink(
                        with: ListItemView(
                            title: Localized.Transfer.ClaimRewards.title,
                            subtitle: model.rewards(delegations: delegations)
                        )
                    ) {
                        self.transferData = model.claimRewardsTransferData(delegations: delegations)
                    }
                }
            }
            
            ForEach(delegationsModel) { delegation in
                NavigationLink(value: delegation.delegation) {
                    HStack {
                        ValidatorImageView(validator: delegation.delegation.validator)
                        ListItemView(
                            title: delegation.validatorText,
                            titleExtra: delegation.stateText,
                            titleStyleExtra: TextStyle(font: .footnote, color: delegation.stateTextColor),
                            subtitle: delegation.balanceText,
                            subtitleExtra: delegation.completionDateText,
                            subtitleStyleExtra: .footnote
                        )
                    }
                }
            }
            
            Section(model.assetText) {
                if let minAmountText = model.minAmountText {
                    ListItemView(title: Localized.Stake.minimumAmount, subtitle: minAmountText)
                }
                ListItemView(title: Localized.Stake.apr(""), subtitle: model.stakeAprText)
                ListItemView(title: Localized.Stake.lockTime, subtitle: model.lockTimeText)
            }
        }
        .refreshable {
            NSLog("StakeScene refreshable")
            Task {
                await model.fetch()
            }
        }
        .navigationDestination(for: $transferData) {
            ConfirmTransferScene(
                model: ConfirmTransferViewModel(
                    wallet: model.wallet,
                    keystore: keystore,
                    data: $0,
                    service: ChainServiceFactory(nodeProvider: nodeService)
                        .service(for: $0.recipientData.asset.chain),
                    walletService: walletService
                )
            )
        }
        .navigationDestination(for: $recipientData) {
            AmountScene(
                model: AmounViewModel(
                    amountRecipientData: $0,
                    wallet: model.wallet,
                    keystore: keystore,
                    walletService: walletService,
                    stakeService: stakeService,
                    currentValidator: model.recommendedCurrentValidator
                )
            )
        }
        .navigationDestination(for: Delegation.self) { value in
            StakeDetailScene(model: StakeDetailViewModel(
                wallet: model.wallet,
                model: StakeDelegationViewModel(delegation: value),
                service: model.service)
            )
        }
        .taskOnce {
            Task {
                await model.fetch()
            }
        }
        .navigationTitle(model.title)
    }
}
