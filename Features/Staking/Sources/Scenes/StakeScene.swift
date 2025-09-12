// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Store
import Primitives
import Components
import Localization
import InfoSheet
import PrimitivesComponents

public struct StakeScene: View {
    private let model: StakeSceneViewModel

    public init(model: StakeSceneViewModel) {
        self.model = model
    }

    public var body: some View {
        List {
            stakeInfoSection
            if model.showManage {
                stakeSection
            }
            delegationsSection
        }
        .listSectionSpacing(.compact)
        .refreshable {
            await model.fetch()
        }
        .navigationTitle(model.title)
        .taskOnce {
            Task {
                await model.fetch()
            }
        }
    }
}

// MARK: - UI Components

extension StakeScene {
    private var stakeSection: some View {
        Section(Localized.Common.manage) {
            NavigationLink(value: model.stakeDestination) {
                ListItemView(title: model.stakeTitle)
            }

            if let claimRewardsDestination = model.claimRewardsDestination {
                NavigationLink(value: claimRewardsDestination) {
                    ListItemView(
                        title: model.claimRewardsTitle,
                        subtitle: model.claimRewardsText
                    )
                }
            }
        }
        .listRowInsets(.assetListRowInsets)
    }

    private var delegationsSection: some View {
        Section {
            switch model.delegationsState {
            case .noData:
                EmptyContentView(model: model.emptyContentModel)
                    .cleanListRow()
            case .loading:
                ListItemLoadingView()
                    .id(UUID())
            case .data(let delegations):
                ForEach(delegations) { delegation in
                    NavigationLink(value: delegation.navigationDestination) {
                        ValidatorDelegationView(delegation: delegation)
                    }
                }
            case .error(let error):
                ListItemErrorView(errorTitle: Localized.Errors.errorOccured, error: error)
            }
        }
        .listRowInsets(.assetListRowInsets)
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
                infoAction: model.onLockTimeInfo
            )
        }
        .listRowInsets(.assetListRowInsets)
    }
}


