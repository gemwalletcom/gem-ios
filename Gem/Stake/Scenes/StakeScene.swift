// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import GRDB
import GRDBQuery
import Store
import Primitives
import Components
import Style
import Localization
import ChainService
import Staking

struct StakeScene: View {
    @Environment(\.keystore) private var keystore
    @Environment(\.nodeService) private var nodeService
    @Environment(\.walletsService) private var walletsService
    @Environment(\.stakeService) private var stakeService

    @State private var model: StakeViewModel

    @Query<StakeDelegationsRequest>
    private var delegations: [Delegation]
    private var delegationsModel: [StakeDelegationViewModel] {
        delegations.map { StakeDelegationViewModel(delegation: $0) }
    }
    private let onComplete: VoidAction

    init(
        model: StakeViewModel,
        onComplete: VoidAction
    ) {
        _model = State(initialValue: model)
        _delegations = Query(model.request)
        self.onComplete = onComplete
    }
    
    var body: some View {
        List {
            stakeInfoSection
            stakeSection
            delegationsSection
        }
        .refreshable {
            await model.fetch()
        }
        .navigationTitle(model.title)
        .navigationDestination(for: TransferData.self) {
            ConfirmTransferScene(
                model: ConfirmTransferViewModel(
                    wallet: model.wallet,
                    keystore: keystore,
                    data: $0,
                    service: ChainServiceFactory(nodeProvider: nodeService)
                        .service(for: $0.recipientData.asset.chain),
                    walletsService: walletsService,
                    onComplete: onComplete
                )
            )
        }
        .taskOnce {
            Task {
                await fetch()
            }
        }
    }
}

// MARK: - UI Components

extension StakeScene {
    
    private var stakeSection: some View {
        Section(Localized.Common.manage) {
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
                ListItemLoadingView()
                    .id(UUID())
            case .loaded(let delegations):
                ForEach(delegations) { delegation in
                    NavigationLink(value: delegation.delegation) {
                        ValidatorDelegationView(delegation: delegation)
                    }
                }
            case .error(let error):
                ListItemErrorView(errorTitle: Localized.Errors.errorOccured, error: error)
            }
        }
    }

    private var stakeInfoSection: some View {
        Section(model.assetTitle) {
            if let minAmountValue = model.minAmountValue {
                ListItemView(title: model.minAmountTitle, subtitle: minAmountValue)
            }
            ListItemView(title: model.stakeAprTitle, subtitle: model.stakeAprValue)
            ListItemView(
                title: model.lockTimeTitle,
                subtitle: model.lockTimeValue,
                infoAction: onOpenLockTimeURL
            )
        }
    }
}

// MARK: - Actions

extension StakeScene {
    private func onSelectStake() {
        model.onSelectStake()
    }

    private func onSelectDelegations() {
        model.onSelectDelegations(delegations: delegations)
    }

    private func onOpenLockTimeURL() {
        model.onSelectLockTime()
    }
}

// MARK: - Effects

extension StakeScene {
    private func fetch() async {
        await model.fetch()
    }
}

// MARK: - Previwes

#Preview {
    NavigationStack {
        StakeScene(
            model: .init(
                wallet: .main,
                chain: .ethereum,
                stakeService: .main,
                onTransferAction: .none,
                onAmountInputAction: .none
            ),
            onComplete: {}
        )
        .navigationBarTitleDisplayMode(.inline)
    }
}
