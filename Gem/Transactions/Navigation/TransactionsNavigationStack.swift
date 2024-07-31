// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives

struct TransactionsNavigationStack: View {
    
    let model: TransactionsViewModel
    @Binding var navigationPath: NavigationPath
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            TransactionsScene(model: model)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
