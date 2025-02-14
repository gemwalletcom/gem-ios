// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import SwiftUI

public class WalletSelectImageViewModel {

    @Binding var navigationPath: NavigationPath
    let wallet: Wallet

    public init(
        navigationPath: Binding<NavigationPath>,
        wallet: Wallet
    ) {
        _navigationPath = navigationPath
        self.wallet = wallet
    }
}
