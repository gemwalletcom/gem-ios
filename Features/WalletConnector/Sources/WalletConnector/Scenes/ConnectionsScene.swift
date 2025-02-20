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
    @State private var isPresentingErrorMessage: String?

    @Query<ConnectionsRequest>
    var connections: [WalletConnection]

    var groupedByWallet: [Wallet: [Primitives.WalletConnection]] {
        Dictionary(grouping: connections, by: { $0.wallet })
    }

    var headers: [Wallet] {
        groupedByWallet.map({ $0.key }).sorted { $0.order < $1.order }
    }

    let model: ConnectionsViewModel

    public init(model: ConnectionsViewModel) {
        self.model = model
        _connections = Query(constant: model.request)
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
            ForEach(headers, id: \.self) { header in
                Section(
                    header: Text(header.name)
                ) {
                    ForEach(groupedByWallet[header]!) { connection in
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
            }
        }
        .overlay {
            if headers.isEmpty {
                EmptyContentView(model: model.emptyContentModel)
            }
        }
        .navigationDestination(for: WalletConnection.self) { connection in
            ConnectionScene(model: model.connectionSceneModel(connection: connection))
        }
        .sheet(isPresented: $isPresentingScanner) {
            ScanQRCodeNavigationStack(action: onHandleScan(_:))
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button() {
                    isPresentingScanner = true
                } label: {
                    Images.System.qrCode
                }
            }
        }
        .alert("",
               isPresented: $isPresentingErrorMessage.mappedToBool(),
               actions: {},
               message: {
            Text(isPresentingErrorMessage ?? "")
        }
        )
        .navigationTitle(model.title)
    }

    private func connectURI(uri: String) async {
        do {
            try await model.addConnectionURI(uri: uri)
        } catch {
            isPresentingErrorMessage = error.localizedDescription
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
                isPresentingErrorMessage = error.localizedDescription
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
