// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Style
import Primitives
import Localization
import Store
import Staking

public struct EarnScene: View {
    @State private var model: EarnSceneViewModel

    public init(model: EarnSceneViewModel) {
        _model = State(initialValue: model)
    }

    public var body: some View {
        List {
            infoSection
            if model.showDeposit {
                manageSection
            }
            if model.hasPositions {
                positionsSection
            }
        }
        .listSectionSpacing(.compact)
        .navigationTitle(model.title)
        .observeQuery(request: $model.positionsRequest, value: $model.positions)
        .observeQuery(request: $model.providersRequest, value: $model.providers)
        .refreshable {
            await model.fetch()
        }
        .taskOnce {
            Task {
                await model.fetch()
            }
        }
    }
}

// MARK: - UI Components

extension EarnScene {
    @ViewBuilder
    private var infoSection: some View {
        switch model.providersState {
        case .noData:
            Section {
                ListItemView(title: Localized.Errors.noDataAvailable)
            }
        case .loading:
            ListItemLoadingView()
                .id(UUID())
        case .data:
            Section(model.assetTitle) {
                ListItemView(
                    title: model.aprTitle,
                    subtitle: model.aprValue
                )
            }
        case .error(let error):
            ListItemErrorView(errorTitle: Localized.Errors.errorOccured, error: error)
        }
    }

    private var manageSection: some View {
        Section(Localized.Common.manage) {
            NavigationLink(value: model.depositDestination) {
                ListItemView(title: Localized.Wallet.deposit)
            }
        }
    }

    private var positionsSection: some View {
        Section(Localized.Perpetual.positions) {
            ForEach(model.positionModels) { delegation in
                NavigationLink(value: delegation.navigationDestination) {
                    StakeDelegationView(delegation: delegation)
                }
            }
            .listRowInsets(.assetListRowInsets)
        }
    }
}
