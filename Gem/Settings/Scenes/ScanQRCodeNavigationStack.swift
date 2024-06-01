// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import QRScanner

struct ScanQRCodeNavigationStack: View {
    
    @State var isPresenting: Binding<Bool>
    var action: ((String) -> Void)?

    var body: some View {
        NavigationStack {
            QRScanner() {
                action?($0)
                isPresenting.wrappedValue = false
            }
            .navigationTitle(Localized.Wallet.scanQrCode)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(Localized.Common.cancel) {
                        isPresenting.wrappedValue = false
                    }
                }
            }
        }
    }
}
