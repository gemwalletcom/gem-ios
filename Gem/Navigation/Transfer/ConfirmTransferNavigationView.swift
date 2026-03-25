// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Style
import InfoSheet
import PrimitivesComponents
import FiatConnect
import Swap
import Perpetuals
import Transfer

struct ConfirmTransferNavigationView: View {
    @Environment(\.viewModelFactory) private var viewModelFactory

    @Bindable var model: ConfirmTransferSceneViewModel

    var body: some View {
        ConfirmTransferScene(model: model)
            .sheet(item: $model.isPresentingSheet) {
                switch $0 {
                case .info(let type):
                    InfoSheetScene(type: type)
                case .url(let url):
                    SFSafariView(url: url)
                case .networkFeeSelector:
                    NetworkFeeSheet(model: model.feeModel)
                case .payloadDetails:
                    NavigationStack {
                        SimulationPayloadDetailsScene(
                            primaryFields: model.primaryPayloadFields,
                            secondaryFields: model.secondaryPayloadFields,
                            fieldViewModel: model.payloadFieldViewModel(for:),
                            contextMenuItems: model.contextMenuItems(for:)
                        )
                        .presentationDetents([.large])
                        .presentationBackground(Colors.grayBackground)
                    }
                case .fiatConnect(let assetAddress, let wallet):
                    NavigationStack {
                        FiatConnectNavigationView(
                            model: viewModelFactory.fiatScene(assetAddress: assetAddress, wallet: wallet)
                        )
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbarDismissItem(type: .close, placement: .topBarLeading)
                    }
                case .swapDetails:
                    if case let .swapDetails(model) = model.detailsViewModel.itemModel {
                        NavigationStack {
                            SwapDetailsView(model: Bindable(model))
                                .presentationDetentsForCurrentDeviceSize(expandable: true)
                                .presentationBackground(Colors.grayBackground)
                        }
                    }
                case .perpetualDetails(let model):
                    NavigationStack {
                        PerpetualDetailsView(model: model)
                            .presentationDetentsForCurrentDeviceSize(expandable: true)
                            .presentationBackground(Colors.grayBackground)
                    }
                }
            }
    }
}
