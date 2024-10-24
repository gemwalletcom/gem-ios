// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI

protocol InfoModel: Sendable {
    var title: String { get }
    var description: String { get }

    var url: URL? { get }
    var image: Image? { get }
}
