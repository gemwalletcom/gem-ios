// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Style
import Primitives
import Localization
import Store

public struct EarnProtocolsScene: View {
    @State private var model: EarnProtocolsSceneViewModel

    public init(model: EarnProtocolsSceneViewModel) {
        _model = State(initialValue: model)
    }

    public var body: some View {
        List {
            if model.isLoading {
                loadingView
            } else if model.hasError {
                errorView
            } else if model.isEmpty && !model.hasPosition {
                emptyStateView
            } else {
                if model.hasPosition {
                    positionSection
                }
                if model.hasProtocols {
                    protocolsSection
                } else if !model.hasPosition {
                    emptyStateView
                }
            }
        }
        .navigationTitle(model.title)
        .observeQuery(request: $model.positionsRequest, value: $model.positions)
        .refreshable {
            await model.fetch()
        }
        .taskOnce(model.fetchOnce)
    }
}

// MARK: - UI Components

extension EarnProtocolsScene {
    private var loadingView: some View {
        Section {
            HStack {
                Spacer()
                ProgressView()
                Spacer()
            }
            .padding(.vertical, Spacing.medium)
        }
    }

    private var positionSection: some View {
        Section {
            ForEach(model.positionModels) { position in
                NavigationCustomLink(
                    with: HStack(spacing: Spacing.small) {
                        AssetImageView(assetImage: model.assetImage, size: 40)
                        Text(position.providerName)
                            .font(.body)
                            .foregroundStyle(Colors.black)
                        Spacer()
                        Text("\(position.assetBalanceFormatted) \(model.assetSymbol)")
                            .font(.callout)
                            .foregroundStyle(Colors.gray)
                    }
                ) {
                    model.onWithdraw(position)
                }
            }
        } header: {
            Text(Localized.Perpetual.positions)
        }
    }

    private var protocolsSection: some View {
        Section {
            ForEach(model.protocols) { `protocol` in
                EarnProtocolView(
                    model: `protocol`,
                    displayName: model.assetName
                ) {
                    model.onSelectProtocol(`protocol`)
                }
            }
        } header: {
            Text(Localized.Common.provider)
        }
    }

    private var emptyStateView: some View {
        Section {
            HStack {
                Spacer()
                Text(model.emptyStateTitle)
                    .font(.body)
                    .foregroundStyle(Colors.gray)
                Spacer()
            }
            .padding(.vertical, Spacing.large)
        }
    }

    private var errorView: some View {
        Section {
            VStack(spacing: Spacing.small) {
                if let error = model.error {
                    ListItemErrorView(
                        errorTitle: Localized.Errors.errorOccured,
                        error: error
                    )
                }

                Button(Localized.Common.tryAgain) {
                    Task {
                        await model.fetch()
                    }
                }
                .buttonStyle(.bordered)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.large)
        }
    }
}
