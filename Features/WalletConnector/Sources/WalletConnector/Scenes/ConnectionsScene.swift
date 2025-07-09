// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import GRDBQuery
import Store
import Primitives
import Components
import QRScanner
import Style
import PrimitivesComponents

public struct ConnectionsScene: View {
    @State private var isPresentingScanner: Bool = false
    @State private var isPresentingAlertMessage: AlertMessage?

    @State private var model: ConnectionsViewModel

    public init(model: ConnectionsViewModel) {
        self.model = model
    }

    public var body: some View {
        List {
            Section {
                ButtonListItem(
                    title: model.pasteButtonTitle,
                    image: Images.System.paste,
                    action: onPaste
                )
                ButtonListItem(
                    title: model.scanQRCodeButtonTitle,
                    image: Images.System.qrCode,
                    action: onScan
                )
            }
            .listRowInsets(.assetListRowInsets)
            
            ForEach(model.sections) { section in
                Section(section.title.or(.empty)) {
                    ForEach(section.values) { connection in
                        NavigationLink(value: connection) {
                            ConnectionView(model: WalletConnectionViewModel(connection: connection))
                                .swipeActions(edge: .trailing) {
                                    Button(
                                        model.disconnectTitle,
                                        role: .destructive,
                                        action: { onSelectDisconnect(connection) }
                                    )
                                    .tint(Colors.red)
                                }
                        }
                    }
                }
                .listRowInsets(.assetListRowInsets)
            }
        }
        .observeQuery(
            request: $model.request,
            value: $model.connections
        )
        .contentMargins(.top, .scene.top, for: .scrollContent)
        .overlay {
            if model.sections.isEmpty {
                EmptyContentView(model: model.emptyContentModel)
            }
        }
        .navigationDestination(for: WalletConnection.self) { connection in
            ConnectionScene(model: model.connectionSceneModel(connection: connection))
        }
        .sheet(isPresented: $isPresentingScanner) {
            ScanQRCodeNavigationStack(action: onHandleScan(_:))
        }
        .toolbarInfoButton(url: model.docsUrl)
        .alertSheet($isPresentingAlertMessage)
        .navigationTitle(model.title)
        .taskOnce { model.updateSessions() }
    }

    private func connectURI(uri: String) async {
        do {
            try await model.pair(uri: uri)
        } catch {
            isPresentingAlertMessage = AlertMessage(message: error.localizedDescription)
            NSLog("connectURI error: \(error)")
        }
    }
}

// MARK: Actions

private extension ConnectionsScene {

    private func onSelectDisconnect(_ connection: WalletConnection) {
        Task {
            do {
                try await model.disconnect(connection: connection)
            } catch {
                isPresentingAlertMessage = AlertMessage(message: error.localizedDescription)
                NSLog("disconnect error: \(error)")
            }
        }
    }

    private func onHandleScan(_ result: String) {
        Task {
            await connectURI(uri: result)
        }
    }

    private func onScan() {
        isPresentingScanner = true
    }

    private func onPaste() {
        guard let content = UIPasteboard.general.string else {
            return
        }

        Task {
            await connectURI(uri: content)
        }
    }
}
