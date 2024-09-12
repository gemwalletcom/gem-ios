// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import Components
import Style

struct SelectAssetSceneNavigationStack: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.keystore) private var keystore
    @Environment(\.assetsService) private var assetsService
    @Environment(\.nodeService) private var nodeService
    @Environment(\.walletsService) private var walletsService

    @State private var isPresentingAddToken: Bool = false
    @State private var isPresentingFilteringView: Bool = false

    @State private var model: SelectAssetViewModel
    @State private var navigationPath = NavigationPath()

    init(model: SelectAssetViewModel) {
        _model = State(wrappedValue: model)
    }

    var body: some View {
        NavigationStack {
            SelectAssetScene(
                model: model,
                isPresentingAddToken: $isPresentingAddToken,
                navigationPath: $navigationPath
            )
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(Localized.Common.done) {
                            dismiss()
                        }
                        .bold()
                        .accessibilityIdentifier("cancel")
                    }
                    if model.showAddToken {
                        
                        if model.showFiltering {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button {
                                    isPresentingFilteringView = true
                                } label: {
                                    if model.filterModel.isCusomFilteringSpecified {
                                        Image(systemName: SystemImage.filterFill)
                                            .symbolRenderingMode(.palette)
                                            .foregroundStyle(Colors.whiteSolid, Colors.blue)
                                    } else {
                                        Image(systemName: SystemImage.filter)
                                            .foregroundStyle(.primary)
                                    }
                                }
                                .contentTransition(.symbolEffect(.replace))
                            }
                        }

                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button {
                                isPresentingAddToken = true
                            } label: {
                                Image(systemName: SystemImage.plus)
                            }
                        }
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $isPresentingAddToken) {
            AddTokenNavigationStack(
                wallet: model.wallet,
                isPresenting: $isPresentingAddToken,
                action: addAsset
            )
        }
        .sheet(isPresented: $isPresentingFilteringView) {
            NavigationStack {
                AssetsFilterScene(model: $model.filterModel)
            }
            .presentationDetents([.height(200)])
            .presentationDragIndicator(.visible)
        }
    }

    func addAsset(_ asset: Asset) {
        Task {
            try model.assetsService.addAsset(walletId: model.wallet.walletId, asset: asset)
        }
        dismiss()
    }
}
