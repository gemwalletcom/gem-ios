// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI

public struct WalletSelectImageScene: View {

    let model: WalletSelectImageViewModel

    public init(model: WalletSelectImageViewModel) {
        self.model = model
    }

    public var body: some View {
        Text(model.wallet.name)
    }
}
