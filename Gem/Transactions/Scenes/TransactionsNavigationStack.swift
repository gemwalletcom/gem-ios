// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives

struct TransactionsNavigationStack: View {
    
    let wallet: Wallet
    @Binding var navigationPath: NavigationPath
    
    @Environment(\.transactionsService) private var transactionsService
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            TransactionsScene(
                model: TransactionsViewModel(
                    wallet: wallet,
                    type: .all,
                    service: transactionsService
                )
            )
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
