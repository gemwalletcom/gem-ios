// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Style
import Primitives
import Localization
import Store

public struct EarnProvidersScene: View {
    @State private var model: EarnProvidersSceneViewModel

    public init(model: EarnProvidersSceneViewModel) {
        _model = State(initialValue: model)
    }

    public var body: some View {
        List {
            if model.hasPosition {
                positionSection
            }
            providersStateView
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

extension EarnProvidersScene {
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

    private var providersSection: some View {
        Section {
            ForEach(model.providers) { provider in
                EarnProviderView(
                    model: provider,
                    displayName: model.assetName
                ) {
                    model.onSelectProvider(provider)
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

    private var providersStateView: some View {
        StateView(
            state: model.providersState,
            content: { _ in
                Group {
                    if model.hasProviders {
                        providersSection
                    } else if !model.hasPosition {
                        emptyStateView
                    }
                }
            },
            emptyView: {
                model.hasPosition ? AnyView(EmptyView()) : AnyView(emptyStateView)
            },
            noDataView: {
                model.hasPosition ? AnyView(EmptyView()) : AnyView(emptyStateView)
            },
            loadingView: {
                AnyView(loadingView)
            },
            errorView: {
                AnyView(errorView)
            }
        )
    }
}
