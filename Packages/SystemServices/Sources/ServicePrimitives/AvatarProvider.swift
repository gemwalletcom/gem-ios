// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

protocol AvatarProvider: Sendable {
    func remove(for walletId: String) throws
}