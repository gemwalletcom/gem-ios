// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Primitives
import Localization
import Store
import Components
import InfoSheet
import ExplorerService
import Style
import PrimitivesComponents

public struct TransactionNavigationView: View {
    @State private var model: TransactionSceneViewModel

    public init(model: TransactionSceneViewModel) {
        _model = State(initialValue: model)
    }

    public var body: some View {
        TransactionScene(
            model: model
        )
        .onChangeObserveQuery(
            request: $model.request,
            value: $model.transactionExtended,
            initial: true,
            action: model.onChangeTransaction
        )
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: model.onSelectShare) {
                    Images.System.share
                }
            }
        }
        .sheet(isPresented: $model.isPresentingShareSheet) {
            ShareSheet(activityItems: [model.explorerURL.absoluteString])
        }
        .sheet(item: $model.isPresentingInfoSheet) {
            InfoSheetScene(type: $0)
        }
        .sheet(isPresented: $model.isPresentingFeeDetails) {
            NavigationStack {
                NetworkFeeScene(model: model.feeDetailsViewModel)
                    .presentationDetents([.height(200)])
            }
        }
    }
}
