// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import QRScanner

struct ScanQRCodeNavigationStack: View {
    var action: ((String) -> Void)

    var body: some View {
        NavigationStack {
            QRScannerView(action: action)
            .navigationTitle(Localized.Wallet.scanQrCode)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
