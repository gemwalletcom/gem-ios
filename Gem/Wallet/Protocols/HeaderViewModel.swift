// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Components

protocol HeaderViewModel {
    var isWatchWallet: Bool { get }
    var assetImage: AssetImage? { get }
    var title: String { get }
    var subtitle: String? { get }
    var buttons: [HeaderButton] { get }
}
