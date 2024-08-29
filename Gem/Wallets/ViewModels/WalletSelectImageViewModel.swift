// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import SwiftUI

class WalletSelectImageViewModel {

    @Binding var navigationPath: NavigationPath
    let wallet: Wallet

    init(
        navigationPath: Binding<NavigationPath>,
        wallet: Wallet
    ) {
        _navigationPath = navigationPath
        self.wallet = wallet
    }
}
