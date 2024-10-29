// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI

public protocol InfoSheetModelViewable: Sendable {
    var title: String { get }
    var description: String { get }
    var buttonTitle: String { get }

    var url: URL? { get }
    var image: Image? { get }
}
