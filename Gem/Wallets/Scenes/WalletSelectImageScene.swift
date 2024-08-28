// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI

struct WalletSelectImageScene: View {
    
    let model: WalletSelectImageViewModel

    init(model: WalletSelectImageViewModel) {
        self.model = model
    }

    var body: some View {
        Text(model.wallet.name)
    }
}
