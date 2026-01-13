// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Style
import Primitives

public struct YieldScene: View {
    @State private var model: YieldSceneViewModel

    public init(model: YieldSceneViewModel) {
        _model = State(initialValue: model)
    }

    public var body: some View {
        List {
            if model.isLoading {
                loadingView
            } else if model.hasError {
                errorView
            } else if model.hasOpportunities {
                if model.hasPosition {
                    positionSection
                }
                opportunitiesSection
            } else {
                emptyStateView
            }
        }
        .navigationTitle(model.title)
        .refreshable {
            await model.fetch()
        }
        .task {
            await model.fetch()
        }
    }
}

// MARK: - UI Components

extension YieldScene {
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
            if let position = model.position {
                VStack(alignment: .leading, spacing: Spacing.small) {
                    HStack {
                        VStack(alignment: .leading, spacing: Spacing.tiny) {
                            Text("Your Balance")
                                .font(.subheadline)
                                .foregroundStyle(Colors.gray)
                            Text("\(position.assetBalanceFormatted) \(model.assetSymbol)")
                                .font(.title2.bold())
                                .foregroundStyle(Colors.black)
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: Spacing.tiny) {
                            Text("APY")
                                .font(.subheadline)
                                .foregroundStyle(Colors.gray)
                            Text(position.apyText)
                                .font(.title3.bold())
                                .foregroundStyle(Colors.green)
                        }
                    }
                }
                .padding(.vertical, Spacing.small)
            }
        } header: {
            Text("Current Position")
        }
    }

    private var opportunitiesSection: some View {
        Section {
            ForEach(model.opportunities) { opportunity in
                YieldOpportunityView(
                    model: opportunity,
                    displayName: model.assetName
                ) {
                    model.onSelectOpportunity(opportunity)
                }
            }
        } header: {
            Text("Available for \(model.assetSymbol)")
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
                Image(systemName: "exclamationmark.triangle")
                    .font(.largeTitle)
                    .foregroundStyle(Colors.red)

                Text("Error loading yields")
                    .font(.headline)
                    .foregroundStyle(Colors.black)

                if let errorMessage = model.errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundStyle(Colors.gray)
                        .multilineTextAlignment(.center)
                }

                Button("Retry") {
                    Task {
                        await model.fetch()
                    }
                }
                .buttonStyle(.bordered)
                .padding(.top, Spacing.small)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.large)
        }
    }
}
