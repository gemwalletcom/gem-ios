// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import GRDBQuery
import Store
import Primitives
import Components
import Localization
import InfoSheet
import PrimitivesComponents

public struct StakeScene: View {
    @State private var model: StakeViewModel
    @State private var isPresentingInfoSheet: InfoSheetType? = .none

    @Query<StakeDelegationsRequest>
    private var delegations: [Delegation]
    private var delegationsModel: [StakeDelegationViewModel] {
        delegations.map { StakeDelegationViewModel(delegation: $0) }
    }

    public init(model: StakeViewModel) {
        _model = State(initialValue: model)
        _delegations = Query(model.request)
    }

    public var body: some View {
        List {
            stakeInfoSection
            if model.showManage {
                stakeSection
            }
            delegationsSection
        }
        .refreshable {
            await model.fetch()
        }
        .navigationTitle(model.title)
        .sheet(item: $isPresentingInfoSheet) {
            InfoSheetScene(model: InfoSheetViewModel(type: $0))
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
                EmptyContentView(model: model.emptyContentModel)
                    .cleanListRow()
            case .loading:
                ListItemLoadingView()
                    .id(UUID())
            case .data(let delegations):
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
                infoAction: onLockTimeAction
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

    private func onLockTimeAction() {
        isPresentingInfoSheet =  model.lockTimeInfoSheet
    }
}

// MARK: - Effects

extension StakeScene {
    private func fetch() async {
        await model.fetch()
    }
}
