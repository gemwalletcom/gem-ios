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

    @State private var model: StakeViewModel

    @Query<StakeDelegationsRequest>
    private var delegations: [Delegation]
    private var delegationsModel: [StakeDelegationViewModel] {
        delegations.map { StakeDelegationViewModel(delegation: $0) }
    }

    init(model: StakeViewModel) {
        _model = State(initialValue: model)
        _delegations = Query(model.request, in: \.db.dbQueue)
    }
    
    var body: some View {
        List {
            stakeSection
            delegationsSection
            stakeInfoSection
        }
        .refreshable {
            fetch()
        }
        .navigationTitle(model.title)
        .navigationDestination(for: $model.transferData) {
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
        .navigationDestination(for: $model.recipientData) {
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
                service: stakeService)
            )
        }
        .taskOnce {
            fetch()
        }
    }
}

// MARK: - UI Components

extension StakeScene {
    
    private var stakeSection: some View {
        Section {
            NavigationCustomLink(
                with: ListItemView(title: model.stakeTitle),
                action: onSelectStake
            )

            if model.showClaimRewards(delegations: delegations) {
                NavigationCustomLink(
                    with: ListItemView(
                        title: model.claimRewardsTitle,
                        subtitle: model.claimRewardsText(delegations: delegations)
                    ),
                    action: onSelectDelegations
                )
            }
        }
    }

    private var delegationsSection: some View {
        let state = model.stakeDelegateionState(delegationModels: delegationsModel)
        return Section {
            switch state {
            case .noData:
                StateEmptyView(title: model.emptyDelegationsTitle)
            case .loading:
                EmptyView()
            case .loaded:
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
            case .error(let error):
                ListItemErrorView(errorTitle: Localized.Errors.errorOccured, error: error)
            }
        } header: {
            if state.isLoading {
                HStack {
                    Spacer()
                    StateLoadingView()
                    Spacer()
                }
                .id(UUID())
            }
        }
    }

    private var stakeInfoSection: some View {
        Section(model.assetTitle) {
            if let minAmountValue = model.minAmountValue {
                ListItemView(title: model.minAmountTitle, subtitle: minAmountValue)
            }
            ListItemView(title: model.stakeAprTitle, subtitle: model.stakeAprValue)
            ListItemView(title: model.lockTimeTitle, subtitle: model.lockTimeValue)
        }
    }
}

// MARK: - Actions

extension StakeScene {
    private func onSelectStake() {
        model.recipientData = try? model.stakeRecipientData()
    }

    private func onSelectDelegations() {
        model.transferData = model.claimRewardsTransferData(delegations: delegations)
    }
}

// MARK: - Effects

extension StakeScene {
    private func fetch() {
        Task {
            await model.fetch()
        }
    }
}

// MARK: - Previwes

#Preview {
    return NavigationStack {
        StakeScene(model: .init(wallet: .main, chain: .ethereum, stakeService: .main))
            .navigationBarTitleDisplayMode(.inline)
    }
}
