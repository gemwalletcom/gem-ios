// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI

protocol InfoModel: Sendable {
    var image: Image? { get }
    var title: String { get }
    var description: String { get }

    var url: URL { get }
}
