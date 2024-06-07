// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import GRDBQuery
import Store
import Primitives
import Components
import QRScanner
import Style

struct ConnectionsScene: View {
    
    @Environment(\.db) private var DB
    @Environment(\.keystore) private var keystore
    @State private var isPresentingScanner: Bool = false
    @State private var isPresentingErrorMessage: String?
    
    @Query<ConnectionsRequest>
    var connections: [WalletConnection]
    
    var groupedByWallet: [Wallet: [Primitives.WalletConnection]] {
        Dictionary(grouping: connections, by: { $0.wallet })
    }

    var headers: [Wallet] {
        groupedByWallet.map({ $0.key })
    }
    
    let model: ConnectionsViewModel
    
    init(
        model: ConnectionsViewModel
    ) {
        self.model = model
        _connections = Query(ConnectionsRequest(), in: \.db.dbQueue)
    }
    
    var body: some View {
        List {
            Section {
                ButtonListItem(
                    title: Localized.Wallet.scanQrCode,
                    image: Image(systemName: SystemImage.qrCode),
                    action: onScan
                )
                ButtonListItem(
                    title: Localized.Common.paste,
                    image: Image(systemName: SystemImage.paste),
                    action: onPaste
                )
            }
            if headers.isEmpty {
                StateEmptyView(message: Localized.WalletConnect.noActiveConnections)
            } else {
                ForEach(headers, id: \.self) { header in
                    Section(
                        header: Text(header.name)
                    ) {
                        ForEach(groupedByWallet[header]!) { connection in
                            NavigationLink(value: connection) {
                                ConnectionView(model: WalletConnectionViewModel(connection: connection))
                            }
                        }
                    }
                }
            }
            
            #if DEBUG
//            Section("Pending") {
//                ForEach(connections.filter { $0.session.sessionId.isEmpty }) { connection in
//                    Text("Walelt: \(connection.wallet.name), ID: \(connection.session.id)")
//                }
//            }
            #endif
            
        }
        .navigationDestination(for: WalletConnection.self) { connection in
            ConnectionScene(
                model: ConnectionSceneViewModel(
                    model: WalletConnectionViewModel(connection: connection),
                    service: model.service
                )
            )
        }
        .sheet(isPresented: $isPresentingScanner) {
            ScanQRCodeNavigationStack(isPresenting: $isPresentingScanner) {
                onHandleScan(value: $0)
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button() {
                    isPresentingScanner = true
                } label: {
                    Image(systemName: SystemImage.qrCode)
                }
            }
        }
        .alert(item: $isPresentingErrorMessage) {
            Alert(title: Text(""), message: Text($0))
        }
        .navigationTitle(Localized.WalletConnect.title)
    }
    
    func connectURI(uri: String) async {
        do {
            try await model.addConnectionURI(uri: uri, wallet: keystore.currentWallet!)
        } catch {
            isPresentingErrorMessage = error.localizedDescription
            NSLog("connectURI error: \(error)")
        }
    }
}

// MARK: Actions

private extension ConnectionsScene {
    private func onHandleScan(value: String) {
        Task {
            await connectURI(uri: value)
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
