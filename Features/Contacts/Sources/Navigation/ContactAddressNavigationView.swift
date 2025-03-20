// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import Style
import ContactService
import Components
import PrimitivesComponents
import QRScanner

struct ContactAddressNavigationView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var isPresentingScanner: Bool = false
    @State private var model: ContactAddressViewModel
    @State private var navigationPath = NavigationPath()
    
    init(model: ContactAddressViewModel) {
        _model = State(wrappedValue: model)
    }
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            ContactAddressScene(
                model: model,
                isPresentingScanner: $isPresentingScanner
            )
            .navigationDestination(for: Scenes.NetworksSelector.self) { _ in
                SearchableSelectableListView(
                    model: $model.networksModel,
                    onFinishSelection: { value in
                        onFinishChainSelection(chains: value)
                        navigationPath.removeLast()
                    },
                    listContent: { ChainView(model: ChainViewModel(chain: $0)) }
                )
                .navigationTitle(model.title)
            }
            .sheet(isPresented: $isPresentingScanner) {
                ScanQRCodeNavigationStack() {
                    onHandleScan($0)
                }
            }
        }
    }
    
    private func onFinishChainSelection(chains: [Chain]) {
        model.input.set(chain: chains.first)
    }
    
    private func onHandleScan(_ result: String) {
        model.input.address.value = result
    }
    
}
